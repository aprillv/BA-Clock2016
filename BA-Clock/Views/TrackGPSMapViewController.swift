//
//  TrackGPSMapViewController.swift
//  BA-Clock
//
//  Created by April Lv on 9/15/17.
//  Copyright © 2017 BuildersAccess. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

extension MKAnnotationView {
    
    func loadCustomLines(customLines: [String]) {
        let stackView = self.stackView()
        for line in customLines {
            let label = UILabel()
            label.text = line
            label.font = UIFont.init(name: "Helvetica Neue", size: 13.0)
            stackView.addArrangedSubview(label)
        }
        self.detailCalloutAccessoryView = stackView
    }
    
    
    
    private func stackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }
}
class TrackGPSMapViewController: BaseViewController, MKMapViewDelegate, MapFilterModalViewDelegate {
    
    
    var trackList: [TrackGPSDat]? {
        didSet{
            self.updateMap()
        }
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var mapview: MKMapView!
    
    private func updateMap(){
        if let map = self.mapview, let gpslist = trackList {
            map.removeAnnotations(map.annotations)
            var tt = [SFAnnotation]()
            for gps in gpslist {
                if ((CDouble(gps.latitude ?? "0") ?? 0) != 0 || (CDouble(gps.longitude ?? "0") ?? 0) != 0) {
                    let ctmp = CLLocationCoordinate2D.init(latitude: CDouble(gps.latitude ?? "0") ?? 0, longitude: CDouble(gps.longitude ?? "0") ?? 0)
                    //                    print(gps.latitude, ctmp.latitude)
                    let annotation : SFAnnotation = SFAnnotation()
                    annotation.coordinate = ctmp;
                    annotation.title = gps.name ?? ""
//                    annotation.coordinate = ctmp
//                    annotation.title = gps.username
                    annotation.subtitle = "Last GPS \(gps.lastgps ?? "")"
                    annotation.subtitle2 = gps.secondsago ?? ""
                    annotation.username = gps.username ?? "";
                    
                    tt.append(annotation)
                }
                
            }
            map.addAnnotations(tt)
            
            
            let region = map.regionThatFits(MKCoordinateRegion.init(
                center: CLLocationCoordinate2D.init(latitude: 29.7604, longitude: -95.3698)
                , span: MKCoordinateSpanMake(0.2, 0.2)
            ));
            map.setRegion(region, animated: true)
//            map.setVisibleMapRect(<#T##mapRect: MKMapRect##MKMapRect#>, animated: <#T##Bool#>)
        }
        
    }
    override func viewDidLoad() {
        self.updateMap()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        var annotationView : MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "CustomAnnotation") as? MKPinAnnotationView
//        if annotationView == nil {
//            annotationView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "CustomAnnotation")
//            annotationView?.canShowCallout = true
//            if let c = annotation as? CustomAnnotation {
//                annotationView?.loadCustomLines(customLines: [c.subtitle!, c.subtitle2!])
//            }
//            
            let rightButton: UIButton! = UIButton(type: .roundedRect)
            rightButton.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
            rightButton.layer.cornerRadius = 4.0
            rightButton.frame = CGRect.init(x: 0, y: 0, width: 50, height: 30)
            rightButton.setTitleColor(.white, for: .normal)
            rightButton.setTitle("View", for: .normal)
//
//            if let a = annotationView {
//                a.image = UIImage(named: "location0.png")
//            }
//            
//            
//            annotationView?.rightCalloutAccessoryView = rightButton
//
//        }
        
        let annotationView = SFAnnotation.createViewAnnotation(for: self.mapview, annotation: annotation)
        
                    if let c = annotation as? SFAnnotation {
                        annotationView?.loadCustomLines(customLines: [c.subtitle!, c.subtitle2!])
                    }
        
        // provide the annotation view's image
        annotationView?.image = UIImage(named:"marker_person");
        
        annotationView?.rightCalloutAccessoryView = rightButton
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let c = view.annotation as? SFAnnotation {
            self.performSegue(withIdentifier: "gotoperson", sender: c)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "gotofiltermodal" {
                if let vc = segue.destination as? MapFilterModalViewController {
                    vc.delegate = self;
                }
            }else if identifier == "gotoperson" {
                if let vc = segue.destination as? TrackPersonViewController
                    , let item = sender as? SFAnnotation {
                    vc.username = item.username
                    vc.title = item.title ?? ""
                }
            }
            
        }
    }
    
    func doRefresh(from: String, to: String) {
        self.dorefresh(fromDate: from, toDate: to)
    }
    
    func dorefresh(fromDate: String, toDate: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.labelText = CConstants.LoadingMsg
        
        // do login
        let userInfo = UserDefaults.standard
        if let token = userInfo.object(forKey: CConstants.UserInfoTokenKey) as? String,
            let tokenSecret = userInfo.object(forKey: CConstants.UserInfoTokenScretKey) as? String{
            let param = [
                "Token": token
                , "TokenSecret": tokenSecret
                , "from": fromDate
                , "to": toDate
            ]
            
            //                print(param)
            Alamofire.request(CConstants.ServerURL + "GetTrackGPSList.json"
                , method:.post
                , parameters: param
                ).responseJSON{ (response) -> Void in
                    hud?.hide(true)
//                    print(response.result.value)
                    //                    self.progressBar.dismissViewControllerAnimated(true){
                    if response.result.isSuccess {
                        
                        if let rtnValue = response.result.value as? [String: AnyObject]{
                            if (rtnValue ["validtoken"] as? String ?? "0") == "1" {
                                var tmp = [TrackGPSDat]();
                                if let items = rtnValue["itemlist"] as? [[String: AnyObject]]{
                                    for fitem in items {
                                        tmp.append(TrackGPSDat(dicInfo: fitem))
                                    }
                                }
                                self.trackList = tmp;
                            }
                            
                        }else{
                            self.PopServerError()
                        }
                    }else{
                        self.PopNetworkError()
                    }
                    
            }
        }
    }

}

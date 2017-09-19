//
//  TrackPersonViewController.swift
//  BA-Clock
//
//  Created by April Lv on 9/16/17.
//  Copyright © 2017 BuildersAccess. All rights reserved.
//

import UIKit
import Alamofire

class TrackPersonViewController: BaseViewController, MKMapViewDelegate, MapFilterModalViewDelegate {
    
    var username : String?;
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
            var i = 0;
            for gps in gpslist {
                if ((CDouble(gps.latitude ?? "0") ?? 0) != 0 || (CDouble(gps.longitude ?? "0") ?? 0) != 0) {
                    let ctmp = CLLocationCoordinate2D.init(latitude: CDouble(gps.latitude ?? "0") ?? 0, longitude: CDouble(gps.longitude ?? "0") ?? 0)
                    //                    print(gps.latitude, ctmp.latitude)
                    let annotation : SFAnnotation = SFAnnotation()
                    annotation.coordinate = ctmp;
                    i = i + 1
                    annotation.subtitle2 = "\(i)"
                    annotation.title = gps.status ?? ""
//                    print(gps.status ?? "")
                    //                    annotation.coordinate = ctmp
                    //                    annotation.title = gps.username
                    annotation.subtitle = gps.xcreadate ?? ""
                    
                    tt.append(annotation)
                    
                }
                
            }
            map.addAnnotations(tt)
            
            if tt.count == 0 {
                let region = map.regionThatFits(MKCoordinateRegion.init(
                    center: CLLocationCoordinate2D.init(latitude: 29.7604, longitude: -95.3698)
                    , span: MKCoordinateSpanMake(0.2, 0.2)
                ));
                map.setRegion(region, animated: true)
            }else{
                map.showAnnotations(tt, animated: true)
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dorefresh(fromDate: nil, toDate: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        let annotationView = SFAnnotation.createViewAnnotation(for: self.mapview, annotation: annotation)
        
        if let c = annotation as? SFAnnotation{
            let imgname = ((c.title ?? "") == "Clock In" || (c.title ?? "") == "Track" || (c.title ?? "") == "Come Back") ? "marker_green" : "marker_red"
            annotationView?.image = UIImage(named:"\(imgname)\(c.subtitle2 ?? "1")");
        }
        
        
        return annotationView
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "gotofiltermodal2" {
                if let vc = segue.destination as? MapFilterModalViewController {
                    vc.delegate = self;
                }
            }
            
        }
    }
    
    func doRefresh(from: String, to: String) {
        self.dorefresh(fromDate: from, toDate: to)
    }
    
    func dorefresh(fromDate: String?, toDate: String?) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.labelText = CConstants.LoadingMsg
        
        // do login
        let userInfo = UserDefaults.standard
        if let token = userInfo.object(forKey: CConstants.UserInfoTokenKey) as? String,
            let tokenSecret = userInfo.object(forKey: CConstants.UserInfoTokenScretKey) as? String{
            var param = [
                "Token": token
                , "TokenSecret": tokenSecret
                , "username": (username ?? "")
            ]
            if let f = fromDate {
                param["from"] = f;
            }
            if let f = toDate {
                param["to"] = f;
            }
            
                            print(param)
            Alamofire.request(CConstants.ServerURL + "GetTrackGPS.json"
                , method:.post
                , parameters: param
                ).responseJSON{ (response) -> Void in
                    hud?.hide(true)
                    print(response.result.value)
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

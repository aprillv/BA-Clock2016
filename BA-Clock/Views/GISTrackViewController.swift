//
//  GISTrackViewController.swift
//  BA-Clock
//
//  Created by April on 3/8/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit
import Alamofire
import MapKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class GISTrackViewController: BaseViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBAction func GoBackToMore(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet var clearItem: UIBarButtonItem!
   
    
    @IBOutlet weak var mapBack: UIView!
    //    @IBOutlet weak var textTable: UITableView!
  
    @IBOutlet weak var trackMap: MKMapView!{
        didSet{
            trackMap.showsUserLocation = true
            trackMap.delegate  = self
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        print0000(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
    }
    
//    Latitude = "36.70432856";
//    Longitude = "119.17911514";

    @IBOutlet weak var trackTable: UITableView!{
        didSet{
            refreshControl = UIRefreshControl()
            refreshControl!.addTarget(self, action: #selector(GISTrackViewController.refresh(_:)), for: .valueChanged)
            trackTable.addSubview(refreshControl!)
            //            trackTable.separatorColor = UIColor(red: 20/255, green: 72/255, blue: 116/255, alpha: 0.3)
        }
    }
    
    var refreshControl : UIRefreshControl?
    var firstrefreshControl : UIRefreshControl?
    
    func refresh(_ refreshControl: UIRefreshControl) {
        // Do your job, when done:
        self.getTrackList()
    }
    
    
    @IBAction func clearPINs() {
        self.trackMap.removeAnnotations(trackMap.annotations)
        //        UIView.animateWithDuration(0.3, delay: 0.0
        //            , options: UIViewAnimationOptions.CurveEaseOut
        //            , animations: { () -> Void in
        //            self.clearPinBtn.alpha = 0
        //            }) { (_) -> Void in
        //                self.clearPinBtn.hidden = true
        //        }
        
        self.clearItem.tag = 0
        UIView.animate(withDuration: 0.2, delay: 0.0
            , options: UIViewAnimationOptions.curveEaseOut
            , animations: { () -> Void in
                self.clearItem.tintColor = UIColor.clear
            }) { (_) -> Void in
                
        }
        
    }
    @IBOutlet var showhideBtn: UIButton!
    @IBAction func hideorshow(_ sender: AnyObject) {
        
        
        if let first = map_listContstraint.firstItem as? UIView,
            let second = map_listContstraint.secondItem as? UIView{
                mapBack.removeConstraint(map_listContstraint)
                var mul = -M_PI
                if first == trackTable || second == trackTable {
                    
                    map_listContstraint = NSLayoutConstraint(
                        item: trackMap
                        , attribute: NSLayoutAttribute.height
                        , relatedBy: NSLayoutRelation.equal
                        , toItem: mapBack
                        , attribute: NSLayoutAttribute.height
                        , multiplier: 1.0
                        , constant: 0)
                    mapBack.addConstraint(map_listContstraint)
                    //                    self.showhideBtn.setImage(UIImage(named: "show"), forState: .Normal)
                }else{
                    
                    map_listContstraint = NSLayoutConstraint(
                        item: trackMap
                        , attribute: NSLayoutAttribute.height
                        , relatedBy: NSLayoutRelation.equal
                        , toItem: trackTable
                        , attribute: NSLayoutAttribute.height
                        , multiplier: 1.0
                        , constant: 0)
                    mapBack.addConstraint(map_listContstraint)
                    mul = 0.0
                    //                    self.showhideBtn.setImage(UIImage(named: "hide"), forState: .Normal)
                    
                }
                //                print0000(self.showhideBtn.transform)
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.showhideBtn.transform = CGAffineTransform(rotationAngle: CGFloat(mul))
                    self.view.layoutIfNeeded()
                }) 
        }
        
    }
    @IBOutlet weak var map_listContstraint: NSLayoutConstraint!
    var CurrentScheduledInterval : Double?
    var locationTracker : CLocationManager?
    var locationUpdateTimer : Timer?
    var SyncTimer : Timer?
    var firstTime = false
    var currentRequest : Request?
   
    
    var trackDotList : [TrackDotItem]?
    
    
    var selectedItem : ScheduledDayItem?
    var isIn: Bool?;
    
    fileprivate struct constants{
        static let CellIdentifier : String = "clockMapCell"
        static let CellIdentifierTrack : String = "trackTableCell"
        //        static let UserInfoClockedKey : String = "ClockedIn"
        
        static let UserInfoScheduledFrom : String = "ScheduledFrom"
        static let UserInfoScheduledTo : String = "ScheduledTo"
        
        static let RightTopItemTitleMap : String = "List"
        static let RightTopItemTitleText : String = "GIS Track"
    }
    
    
    
    
    
 
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.setLastSubmitTime()
        //        self.navigationItem.leftBarButtonItem = nil
       
        locationTracker = CLocationManager.sharedInstance
        
        
        self.CurrentScheduledInterval = self.getCurrentInterval1()
        
//        checkUpate()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255.0, green: 72/255.0, blue: 116/255.0, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
       self.getTrackList()
        
        let userInfo = UserDefaults.standard
      
        title = userInfo.value(forKey: CConstants.UserFullName) as? String
        
    }
    
    
    
    
    
    
    
    
    func dismissProgress(){
//        self.clearNotice()
    }
    
    
    
    
    fileprivate func update1(){
        
        self.SyncTimer = Timer.scheduledTimer(timeInterval: 3600, target: self, selector: #selector(GISTrackViewController.syncFrequency), userInfo: nil, repeats: true)
        
        if let a = CurrentScheduledInterval {
            if a > 0 {
                self.locationUpdateTimer = Timer.scheduledTimer(timeInterval: CurrentScheduledInterval ?? 900, target: self, selector: #selector(GISTrackViewController.updateLocation), userInfo: nil, repeats: true)
            }
            
        }
    }
    
    
    func updateLocation(){
        let tl = Tool()
        if tl.getTime2() {
            
//            self.locationTracker?.getMyLocation222()
            self.callSubmitLocationService()
        }
        
    }
    
    func syncFrequency(){
        let userInfo = UserDefaults.standard
        if let token = userInfo.object(forKey: CConstants.UserInfoTokenKey) as? String{
            if let tokenSecret = userInfo.object(forKey: CConstants.UserInfoTokenScretKey) as? String {
                
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
                
                let param = [
                    "Token": token
                    , "TokenSecret": tokenSecret
                    , "ClientTime": loginRequiredInfo.ClientTime ?? ""
                    , "Email": loginRequiredInfo.Email ?? ""
                    , "Password": loginRequiredInfo.Password ?? ""]
                
                Alamofire.request(CConstants.ServerURL + CConstants.SyncScheduleIntervalURL
                    , method: .post
                    , parameters: param
                    ).responseJSON{ (response) -> Void in
                    if response.result.isSuccess {
                        //                        print0000("++++++++++++++++++++++++++++")
                        //                        print0000(response.result.value)
                        if let rtnValue = response.result.value as? [[String: AnyObject]]{
                            var rtn = [FrequencyItem]()
                            for item in rtnValue{
                                rtn.append(FrequencyItem(dicInfo: item))
                            }
                            let coreData = cl_coreData()
                            coreData.savedFrequencysToDB(rtn)
                            let newInterval = self.getCurrentInterval1()
                            if newInterval != self.CurrentScheduledInterval {
                                self.CurrentScheduledInterval = newInterval
                                self.locationUpdateTimer?.invalidate()
                                
                                
                                //                                let hasclocked = userInfo.valueForKey(constants.UserInfoClockedKey) as? String
                                //                                if hasclocked != nil && hasclocked == "1" {
                                
                                if let a = self.CurrentScheduledInterval {
                                    if a > 0 && self.getLastSubmitTime(){
                                        self.updateLocation()
                                        self.locationUpdateTimer = Timer.scheduledTimer(timeInterval: self.CurrentScheduledInterval ?? 900
                                            , target: self, selector: #selector(GISTrackViewController.updateLocation), userInfo: nil, repeats: true)
                                    }
                                    
                                }
                                //                                }else{
                                //
                                //                                }
                                
                                
                            }
                            
                        }else{
                            
                        }
                    }else{
                        
                        //                        self.PopNetworkError()
                    }
                }
            }
        }
        
    }
    
    fileprivate func getTime() -> TimeInterval{
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh"
        let nowHour = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss"
        for i in stride(from: 14, to: 60, by: 15) {
//        for var i = 14; i < 60; i += 15 {
            let now15 = dateFormatter.date(from: nowHour + ":\(i):59")
            let timeSpace = now15?.timeIntervalSince(date)
            if  timeSpace > 0 {
                return timeSpace!
            }
        }
        return 0
        
    }
    
    fileprivate func getCurrentInterval1() -> Double{
        let date = Date()
        //        print0000(date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy EEEE"
        
        dateFormatter.locale = Locale(identifier: "en_US")
         dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
//         dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        
        let today = dateFormatter.string(from: date)
        let index0 = today.startIndex
        let coreData = cl_coreData()
        
        var send = 900.0
        if let frequency = coreData.getFrequencyByWeekdayNm(today.substring(from: today.index(index0, offsetBy: 11))) {
            send = frequency.ScheduledInterval!.doubleValue * 60.0
        }
        return send
        
    }
    

    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
            return trackDotList?.count ?? 0
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        
            let cell = tableView.dequeueReusableCell(withIdentifier: constants.CellIdentifierTrack, for: indexPath)
            let item = self.trackDotList![indexPath.row]
            cell.textLabel?.text = item.Tag
            return cell
        
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == trackTable {
            if let list = trackDotList {
                let item : TrackDotItem = list[indexPath.row]
                var haveADD = false
                for ai in self.trackMap.annotations {
                    if let annotation = ai as? CustomAnnotation {
                        if annotation.index == indexPath.row{
                            trackMap.removeAnnotation(annotation)
                            trackMap.addAnnotation(annotation)
                            haveADD = true
                            let alist = trackMap.annotations(in: trackMap.visibleMapRect)
                            if !alist.contains(annotation) {
                                trackMap.setCenter(annotation.coordinate, animated: true)
                            }
                            break
                        }
                    }
                }
                if !haveADD {
                    let annotation : CustomAnnotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: item.Latitude!.doubleValue, longitude: item.Longitude!.doubleValue))
                    annotation.index = indexPath.row
                    trackMap.addAnnotation(annotation)
                    let alist = trackMap.annotations(in: trackMap.visibleMapRect)
                    if !alist.contains(annotation) {
                        trackMap.setCenter(annotation.coordinate, animated: true)
                    }
                    
                    
                }
                
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMapDetail" {
            if let item = self.selectedItem {
                if let dvc = segue.destination as? MapViewController {
                    //                    item.ClockInCoordinate?.Longitude
                    
                    if isIn! {
                        dvc.coordinate = CLLocationCoordinate2D(latitude: item.ClockInCoordinate!.Latitude!.doubleValue, longitude: item.ClockInCoordinate!.Longitude!.doubleValue)
                    }else{
                        dvc.coordinate = CLLocationCoordinate2D(latitude: item.ClockOutCoordinate!.Latitude!.doubleValue, longitude: item.ClockOutCoordinate!.Longitude!.doubleValue)
                    }
                    
                }
            }
        }
    }
    
   
    
    
    
    
    fileprivate var lastCallSubmitLocationService : Date?
    func callSubmitLocationService(){
        
        lastCallSubmitLocationService = Date()
        let submitRequired = SubmitLocationRequired()
        submitRequired.Latitude = "\(self.locationTracker?.currentLocation?.coordinate.latitude ?? 0)"
        submitRequired.Longitude = "\(self.locationTracker?.currentLocation?.coordinate.longitude ?? 0)"
        let OAuthToken = self.getUserToken()
        submitRequired.Token = OAuthToken.Token
        submitRequired.TokenSecret = OAuthToken.TokenSecret
//        print0000("background")
//                    print0000(submitRequired.getPropertieNamesAsDictionary())
//         print0000("background \(NSDate())")
        setLastSubmitTime()
        
        let param = [
            "Token": submitRequired.Token ?? ""
            , "TokenSecret": submitRequired.TokenSecret ?? ""
            , "Latitude": submitRequired.Latitude ?? ""
            , "Longitude": submitRequired.Longitude ?? ""
            , "ClientTime": submitRequired.ClientTime ?? ""
        ]
        
        currentRequest = Alamofire.request( CConstants.ServerURL + CConstants.SubmitLocationServiceURL
            , method:.post
            , parameters: param).responseJSON{ (response) -> Void in
//                            print0000("sfasdfa=======", response.result.value)
            if response.result.isSuccess {
            }else{
            }
        }
        
        //        }
        
        
    }
    
    fileprivate func setLastSubmitTime(){
        let userInfo = UserDefaults.standard
        userInfo.setValue(Date(), forKey: "LastSubmitLocationTime")
    }
    
    fileprivate func getLastSubmitTime() -> Bool{
        
        let userInfo = UserDefaults.standard
        if let lastTime = userInfo.value(forKey: "LastSubmitLocationTime") as? Date,
            let timeSpace = self.CurrentScheduledInterval {
                
                let date = Date()
                //                print0000("\( date.timeIntervalSinceDate(lastTime))")
                return date.timeIntervalSince(lastTime) > timeSpace
        }
        return false
    }
    
    fileprivate func getUserToken() -> OAuthTokenItem{
        let userInfo = UserDefaults.standard
        let userInfo1 = OAuthTokenItem(dicInfo: nil)
        userInfo1.Token = userInfo.object(forKey: CConstants.UserInfoTokenKey) as? String
        userInfo1.TokenSecret = userInfo.object(forKey: CConstants.UserInfoTokenScretKey) as? String
        return userInfo1
    }
    
  
    
  
    
  
    
    fileprivate func getTrackList(){
        
        
        let userInfo = UserDefaults.standard
        if let token = userInfo.object(forKey: CConstants.UserInfoTokenKey) as? String,
            let tokenSecret = userInfo.object(forKey: CConstants.UserInfoTokenScretKey) as? String {
                
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
                
                
                var showNoticie = true
                if let first = map_listContstraint.firstItem as? UIView,
                    let second = map_listContstraint.secondItem as? UIView{
                        if first == trackTable || second == trackTable {
                            showNoticie = false
                        }
                }
                var hud : MBProgressHUD?
                if showNoticie {
                    hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud!.labelText = CConstants.LoadingMsg
                    
//                    self.noticeOnlyText(CConstants.LoadingMsg)
                }
                
                self.refreshControl?.beginRefreshing()
                //                    print0000(self.refreshControl)
//            print(loginRequiredInfo.getPropertieNamesAsDictionary())
            
            let param = [
                "Token": token
                , "TokenSecret": tokenSecret
                , "ClientTime": loginRequiredInfo.ClientTime ?? ""
                , "Email": loginRequiredInfo.Email ?? ""
                , "Password": loginRequiredInfo.Password ?? ""]
            
            currentRequest = Alamofire.request( CConstants.ServerURL + CConstants.GetGISTrackURL
                , method:.post
                , parameters: param).responseJSON{ (response) -> Void in
                    
                    self.refreshControl?.endRefreshing()
                    
                    if showNoticie {
                        hud!.hide(true)
                        
                        //                    self.noticeOnlyText(CConstants.LoadingMsg)
                    }
                    
                    if let line = self.polyLine {
                        self.trackMap.remove(line)
//                        self.trackMap.removeOverlay(line)
                        self.trackMap.removeAnnotations(self.trackMap.annotations)
                    }
                    if response.result.isSuccess {
//                                                    print0000(response.result.value)
                        if let rtnValue = response.result.value as? [String: AnyObject]{
                            
                            if rtnValue["Status"]!.integerValue == 1 {
                                self.trackDotList = [TrackDotItem]()
                                for item in rtnValue["Coordinates"] as! [[String: AnyObject]]{
                                    self.trackDotList!.append(TrackDotItem(dicInfo: item))
                                }
                                self.drawTrackPath()
                                self.trackTable.reloadData()
                                if let a = rtnValue["polygons"] as? [[String: String]]{
                                    for it in a {
                                        for (ke, va) in it {
                                            self.drawPolygon(va)
                                            print(ke)
                                        }
                                    }
                                }
                            }else{
                                self.PopMsgWithJustOK(msg: rtnValue["Message"] as! String) {
                                    [weak self] (action : UIAlertAction) -> Void in
                                    CLocationManager.sharedInstance.stopUpdatingLocation()
                                    self?.popToRootLogin()
                                }
                            }
                            
                        }else{
                            
                        }
                    }else{
                        
                        self.PopNetworkError()
                    }
                    self.perform(#selector(GISTrackViewController.dismissProgress), with: nil, afterDelay: 0.2)
                }
        }
        
        
        
    }
    
    
    var polyLine : MKPolyline?
    fileprivate func drawTrackPath(){
        
        if let dots = self.trackDotList {
            var dotsArray = [CLLocationCoordinate2D]()
            for dot in dots {
                if let lat = dot.Latitude?.doubleValue,
                    let lng = dot.Longitude?.doubleValue {
                        dotsArray.append(CLLocationCoordinate2D(latitude: lat, longitude: lng))
                }
                
            }
            //            dotsArray.removeLast()
            if dotsArray.count > 0 {
                polyLine = MKPolyline(coordinates: &dotsArray, count: dotsArray.count)
                trackMap.setVisibleMapRect(polyLine!.boundingMapRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
                trackMap.add(polyLine!)
                
            }
        }
        
    }
    
    fileprivate func drawPolygon(_ p : String){
        let s = p.replacingOccurrences(of: "POLYGON ((", with: "").replacingOccurrences(of: "))", with: "")
        let alist = s.components(separatedBy: ", ")
        var dotsArray = [CLLocationCoordinate2D]()
        for al in alist {
            let c = al.components(separatedBy: " ")
            if c.count == 2 {
                if let lat = Double(c[1]),
                    let lng = Double(c[0]) {
//                    print(lat,lng)
                    
                    dotsArray.append(CLLocationCoordinate2D(latitude: lat, longitude: lng))
                }
            }
        }
        if dotsArray.count > 0 {
//           print(dotsArray)
//            trackMap.setVisibleMapRect(MKPolygon(coordinates: &dotsArray, count: dotsArray.count).boundingMapRect, edgePadding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
            trackMap.add(MKPolygon(coordinates: &dotsArray, count: dotsArray.count))
            
        }
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let pr = MKPolylineRenderer(overlay: overlay)
        //        pr.strokeColor = UIColor(red: 20/255.0, green: 72/255.0, blue: 116/255.0, alpha: 1)
        pr.strokeColor = UIColor.blue
        pr.lineWidth = 2
        return pr
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //        print0000(self.clearItem.tintColor)
        if mapView.annotations.count > 0 && (self.clearItem.tag == 0){
            //            self.clearPinBtn.hidden = false
            //            UIView.animateWithDuration(0.3, delay: 0.0
            //                , options: UIViewAnimationOptions.CurveEaseIn
            //                , animations: { () -> Void in
            //                    self.clearPinBtn.alpha = 1
            //                }) { (_) -> Void in
            //                    self.clearPinBtn.hidden = false
            //            }
            self.clearItem.tag == 1
            UIView.animate(withDuration: 0.3, delay: 0.0
                , options: UIViewAnimationOptions.curveEaseOut
                , animations: { () -> Void in
                    self.clearItem.tintColor = UIColor.white
                }) { (_) -> Void in
                    
            }
            
            
        }
        var annotationView : MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "April") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "April")
        }
        annotationView?.pinTintColor = UIColor.red
        annotationView?.animatesDrop = true
        return annotationView
        
    }
    
}


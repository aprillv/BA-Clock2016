//
//  ClockMapViewController.swift
//  BA-Clock
//
//  Created by April on 1/12/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit
import Alamofire
import MapKit

class ClockMapViewController: BaseViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
   

    @IBOutlet var clearItem: UIBarButtonItem!
    @IBOutlet weak var clockInSpinner: UIActivityIndicatorView!
    @IBOutlet weak var clockOutSpinner: UIActivityIndicatorView!
    @IBOutlet weak var switchItem: UIBarButtonItem!
    @IBOutlet weak var mapTable: UITableView!{
        didSet{
//            firstrefreshControl = UIRefreshControl()
//            firstrefreshControl!.addTarget(self, action: "refreshfirst:", forControlEvents: .ValueChanged)
//            mapTable.addSubview(firstrefreshControl!)
            //            trackTable.separatorColor = UIColor(red: 20/255, green: 72/255, blue: 116/255, alpha: 0.3)
        }
    }
    
    @IBOutlet weak var mapBack: UIView!
//    @IBOutlet weak var textTable: UITableView!
    @IBOutlet weak var clockInBtn: UIButton!
    @IBOutlet weak var clockOutBtn: UIButton!
    @IBOutlet weak var trackMap: MKMapView!
    @IBOutlet weak var trackTable: UITableView!{
        didSet{
            refreshControl = UIRefreshControl()
            refreshControl!.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
            trackTable.addSubview(refreshControl!)
//            trackTable.separatorColor = UIColor(red: 20/255, green: 72/255, blue: 116/255, alpha: 0.3)
        }
    }
    
    var refreshControl : UIRefreshControl?
    var firstrefreshControl : UIRefreshControl?
    
    func refresh(refreshControl: UIRefreshControl) {
        // Do your job, when done:
        self.getTrackList()
    }
    
    func refreshfirst(refreshControl: UIRefreshControl) {
        // Do your job, when done:
        firstTime = true
        self.callGetList()
    }
    
    
//    @IBOutlet var clearPinBtn: UIButton!{
//        didSet{
//            clearPinBtn.alpha = 0
//            clearPinBtn.layer.cornerRadius = 8
//            clearPinBtn.backgroundColor = UIColor(red: 20/255.0, green: 72/255.0, blue: 116/255.0, alpha: 0.85)
//        }
//    }
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
                UIView.animateWithDuration(0.2, delay: 0.0
                    , options: UIViewAnimationOptions.CurveEaseOut
                    , animations: { () -> Void in
                    self.clearItem.tintColor = UIColor.clearColor()
                    }) { (_) -> Void in
                        
                }
        
    }
    @IBOutlet var showhideBtn: UIButton!
    @IBAction func hideorshow(sender: AnyObject) {
        
        
        if let first = map_listContstraint.firstItem as? UIView,
            let second = map_listContstraint.secondItem as? UIView{
                mapBack.removeConstraint(map_listContstraint)
                var mul = -M_PI
                if first == trackTable || second == trackTable {
                    
                    map_listContstraint = NSLayoutConstraint(
                        item: trackMap
                        , attribute: NSLayoutAttribute.Height
                        , relatedBy: NSLayoutRelation.Equal
                        , toItem: mapBack
                        , attribute: NSLayoutAttribute.Height
                        , multiplier: 1.0
                        , constant: 0)
                    mapBack.addConstraint(map_listContstraint)
//                    self.showhideBtn.setImage(UIImage(named: "show"), forState: .Normal)
                }else{
                    
                    map_listContstraint = NSLayoutConstraint(
                        item: trackMap
                        , attribute: NSLayoutAttribute.Height
                        , relatedBy: NSLayoutRelation.Equal
                        , toItem: trackTable
                        , attribute: NSLayoutAttribute.Height
                        , multiplier: 1.0
                        , constant: 0)
                    mapBack.addConstraint(map_listContstraint)
                    mul = 0.0
//                    self.showhideBtn.setImage(UIImage(named: "hide"), forState: .Normal)
                   
                }
//                print(self.showhideBtn.transform)
                UIView.animateWithDuration(0.5) {
                    
                    self.showhideBtn.transform = CGAffineTransformMakeRotation(CGFloat(mul))
                    self.view.layoutIfNeeded()
                }
        }
        
    }
    @IBOutlet weak var map_listContstraint: NSLayoutConstraint!
    var CurrentScheduledInterval : Double?
    var locationTracker : LocationTracker?
    var locationUpdateTimer : NSTimer?
    var SyncTimer : NSTimer?
    var firstTime = false
    var currentRequest : Request?
    var clockDataList : [ScheduledDayItem]?{
        didSet{
            
            self.mapTable?.reloadData()
//            self.textTable?.reloadData()
            
            if clockDataList != nil && clockDataList?.count > 0 {
                scrollToBottom()
            }
            
        }
    }
    
    var trackDotList : [TrackDotItem]?
    
    
    var selectedItem : ScheduledDayItem?
    var isIn: Bool?;
    
    private struct constants{
        static let CellIdentifier : String = "clockMapCell"
        static let CellIdentifierTrack : String = "trackTableCell"
//        static let UserInfoClockedKey : String = "ClockedIn"
        
        static let UserInfoScheduledFrom : String = "ScheduledFrom"
        static let UserInfoScheduledTo : String = "ScheduledTo"
        
        static let RightTopItemTitleMap : String = "List"
        static let RightTopItemTitleText : String = "GIS Track"
    }
    
    
   
    
    private func scrollToBottom(){
//        print(mapTable?.contentSize.height)
        if (mapTable?.contentSize.height ?? 10) - (mapTable?.frame.size.height ?? 10) > 10 {
            mapTable.setContentOffset(CGPoint(x: 0, y: (mapTable?.contentSize.height ?? 0) - (mapTable?.frame.size.height ?? 0)), animated: true)
            
        }
    }
    
    
    @IBAction func switchTo(sender: UIBarButtonItem) {
        switch sender.title!{
        case constants.RightTopItemTitleText:
//            self.navigationItem.leftBarButtonItem = hideItem
            sender.title = constants.RightTopItemTitleMap
            self.trackTable.setContentOffset(CGPoint(x: 0, y: -(self.refreshControl?.frame.size.height ?? 0)), animated: true)
        
            UIView.transitionFromView(mapTable, toView: mapBack, duration: 0.8, options: [.TransitionFlipFromRight, .ShowHideTransitionViews], completion: { (_) -> Void in
//                self.getTrackList()
                
                self.getTrackList()
                self.view.bringSubviewToFront(self.mapBack)
            })
            
            
            break
        default:
//            self.navigationItem.leftBarButtonItem = nil
            if let line = self.polyLine {
                trackMap.removeOverlay(line)
                trackMap.removeAnnotations(trackMap.annotations)
//                clearPinBtn.hidden = true
//                clearPinBtn.alpha = 0
                clearItem.tintColor = UIColor.clearColor()
                self.clearItem.tag = 0
            }
            sender.title = constants.RightTopItemTitleText
            UIView.transitionFromView(mapBack, toView: mapTable, duration: 0.8, options: [.TransitionFlipFromLeft, .ShowHideTransitionViews], completion: { (_) -> Void in
                self.view.bringSubviewToFront(self.mapTable)
            })
            
            
            break
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setLastSubmitTime()
//        self.navigationItem.leftBarButtonItem = nil
        if locationTracker == nil {
            locationTracker = LocationTracker()
        }
        locationTracker?.startLocationTracking()
        
        
        self.CurrentScheduledInterval = self.getCurrentInterval1()
        
        checkUpate()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255.0, green: 72/255.0, blue: 116/255.0, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        if self.clockDataList == nil {
            firstTime = true
            Tool.saveDeviceTokenToSever()
//            self.mapTable?.setContentOffset(CGPoint(x: 0, y: -(self.firstrefreshControl?.frame.size.height ?? 0)), animated: true)
//            firstrefreshControl?.beginRefreshing()
            self.callGetList()
            self.syncFrequency()
        }else{
            firstTime = true
        }
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        view.bringSubviewToFront(mapTable)
        title = userInfo.valueForKey(CConstants.UserFullName) as? String
        
    }
    
   
    
    
    
    
    private func callGetList(){
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        if let token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String{
            if let tokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String {
                
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
//                self.firstrefreshControl?.beginRefreshing()
                self.noticeOnlyText(CConstants.LoadingMsg)
                currentRequest = Alamofire.request(.POST, CConstants.ServerURL + CConstants.GetScheduledDataURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                    self.firstrefreshControl?.endRefreshing()
                    if response.result.isSuccess {
//                        print(response.result.value)
                        if let rtnValue = response.result.value as? [String: AnyObject]{
                            
                            if rtnValue["Status"]!.integerValue == 1 {
                                self.clockDataList = [ScheduledDayItem]()
                                for item in rtnValue["ScheduledDay"] as! [[String: AnyObject]]{
                                    self.clockDataList!.append(ScheduledDayItem(dicInfo: item))
                                }
                                
                                self.update1()
                                if let a = self.CurrentScheduledInterval {
                                    if a > 0 && self.getLastSubmitTime(){
                                        self.updateLocation()
                                    }
                                }
                            }else{
                                self.PopMsgWithJustOK(msg: rtnValue["Message"] as! String) {
                                    (action : UIAlertAction) -> Void in
                                    
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    if let login = storyboard.instantiateViewControllerWithIdentifier("LoginStart") as? LoginViewController {
                                        var va : [UIViewController]? = self.navigationController?.viewControllers
                                        if va != nil {
                                            va!.insert(login, atIndex: 0)
                                            self.navigationController?.viewControllers = va!
                                            self.navigationController?.popToRootViewControllerAnimated(true)
                                        }
                                    }
                                }
                            }
                            
                        }else{
                            
                        }
                    }else{
                        
                        self.PopNetworkError()
                    }
                    self.performSelector("dismissProgress", withObject: nil, afterDelay: 0.1)
                }
            }
        }
        
        
    }
    
    func dismissProgress(){
        self.clearNotice()
    }
    
    
    
    
    private func update1(){
        
        self.SyncTimer = NSTimer.scheduledTimerWithTimeInterval(3600, target: self, selector: "syncFrequency", userInfo: nil, repeats: true)
        
        if let a = CurrentScheduledInterval {
            if a > 0 {
                self.locationUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(CurrentScheduledInterval ?? 900, target: self, selector: "updateLocation", userInfo: nil, repeats: true)
            }
        
        }
    }
    
    
    func updateLocation(){
        if getTime2() {
            self.locationTracker?.getMyLocation222()
            self.callSubmitLocationService()
        }
        
    }
    
    func syncFrequency(){
        let userInfo = NSUserDefaults.standardUserDefaults()
        if let token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String{
            if let tokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String {
                
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
                currentRequest = Alamofire.request(.POST, CConstants.ServerURL + CConstants.SyncScheduleIntervalURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                    if response.result.isSuccess {
//                        print("++++++++++++++++++++++++++++")
//                        print(response.result.value)
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
                                            self.locationUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(self.CurrentScheduledInterval ?? 900, target: self, selector: "updateLocation", userInfo: nil, repeats: true)
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
    
    private func getTime() -> NSTimeInterval{
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh"
        let nowHour = dateFormatter.stringFromDate(date)
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss"
        for var i = 14; i < 60; i += 15 {
            let now15 = dateFormatter.dateFromString(nowHour + ":\(i):59")
            let timeSpace = now15?.timeIntervalSinceDate(date)
            if  timeSpace > 0 {
                return timeSpace!
            }
        }
        return 0
        
    }
    
    private func getCurrentInterval1() -> Double{
        let date = NSDate()
        //        print(date)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy EEEE"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        
        
        
        let today = dateFormatter.stringFromDate(date)
        let index0 = today.startIndex
        let coreData = cl_coreData()
        
        var send = 900.0
        if let frequency = coreData.getFrequencyByWeekdayNm(today.substringFromIndex(index0.advancedBy(11))) {
           send = frequency.ScheduledInterval!.doubleValue * 60.0
        }
        return send
        
    }
    
    private func getTime2() -> Bool{
        let date = NSDate()
//        print(date)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy EEEE"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        
        
        
        let today = dateFormatter.stringFromDate(date)
        let index0 = today.startIndex
        let todayDay = today.substringToIndex(index0.advancedBy(10))
        let coreData = cl_coreData()
        
        var send = false
        if let frequency = coreData.getFrequencyByWeekdayNm(today.substringFromIndex(index0.advancedBy(11))) {
//        if let frequency = coreData.getFrequencyByWeekdayNm("Monday") {
//            print(todayDay + " " + frequency.ScheduledFrom!)
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
//            print(dateFormatter.dateFromString(todayDay + " " + frequency.ScheduledFrom!))
            if let fromTime = dateFormatter.dateFromString(todayDay + " " + frequency.ScheduledFrom!) {
//                print(fromTime)
                if date.timeIntervalSinceDate(fromTime) > 0 {
                    if let toTime = dateFormatter.dateFromString(todayDay + " " + frequency.ScheduledTo!) {
                        send = (toTime.timeIntervalSinceDate(date) > 0)
                    }
                }
                
            }
        }
        return send
        
    }
    
    
    
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == mapTable {
            return clockDataList?.count ?? 0
        }else{
            return trackDotList?.count ?? 0
        }
        
    }
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       
        
        if tableView == mapTable {
             let list = clockDataList!
            let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifier, forIndexPath: indexPath)
            if let cellitem = cell as? ClockMapCell {
                cellitem.superActionView = self
                if let item : ScheduledDayItem = list[indexPath.row] {
                    cellitem.clockInfo = item
                }
                cell.contentView.tag = indexPath.row
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifierTrack, forIndexPath: indexPath)
            let item = self.trackDotList![indexPath.row]
            cell.textLabel?.text = item.Tag
            return cell
        }
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == mapTable{
//            print(firstTime)
            if(firstTime && indexPath.row == tableView.indexPathsForVisibleRows?.last?.row){
                firstTime = false
                self.scrollToBottom()
            }
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
                            let alist = trackMap.annotationsInMapRect(trackMap.visibleMapRect)
                            if !alist.contains(annotation) {
                                trackMap.setCenterCoordinate(annotation.coordinate, animated: true)
                            }
                            break
                        }
                    }
                }
                if !haveADD {
                    let annotation : CustomAnnotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: item.Latitude!.doubleValue, longitude: item.Longitude!.doubleValue))
                    annotation.index = indexPath.row
                    trackMap.addAnnotation(annotation)
                    let alist = trackMap.annotationsInMapRect(trackMap.visibleMapRect)
                    if !alist.contains(annotation) {
                        trackMap.setCenterCoordinate(annotation.coordinate, animated: true)
                    }
                    
                   
                }
                
            }
            
        }
        
    }
    
    func clockInTapped(tap : UITapGestureRecognizer){
//        print("sfsdf \(tap.view?.superview?.tag)  \(tap.view?.layer.valueForKey("lng"))")
        showMap(true,tap: tap)
    }
    
    func clockOutTapped(tap : UITapGestureRecognizer){
//         print("out sfsdf \(tap.view?.layer.valueForKey("lat"))  \(tap.view?.layer.valueForKey("lng"))")
        showMap(false,tap: tap)
    }
    
    private func showMap(isIn: Bool, tap : UITapGestureRecognizer) {
        self.isIn = isIn
        if let tag = tap.view?.superview?.tag {
//            print("tag" + "\(tag)")
            let list = clockDataList!
            if let item : ScheduledDayItem = list[tag] {
                self.selectedItem = item
                self.performSegueWithIdentifier("showMapDetail", sender: nil)
            }
        }
    
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMapDetail" {
            if let item = self.selectedItem {
                if let dvc = segue.destinationViewController as? MapViewController {
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
    
    @IBAction func doClockIn(sender: UIButton) {
        self.locationTracker?.getMyLocation222()
        self.callClockService(isClockIn: true)
    }
    @IBAction func doClockOut(sender: UIButton) {
        
        self.locationTracker?.getMyLocation222()
        self.callClockService(isClockIn: false)
    }
    
    
    
    
    
    
    
    private var lastCallSubmitLocationService : NSDate?
    private func callSubmitLocationService(){
            
            lastCallSubmitLocationService = NSDate()
            let submitRequired = SubmitLocationRequired()
            submitRequired.Latitude = "\(self.locationTracker?.myLastLocation.latitude ?? 0)"
            submitRequired.Longitude = "\(self.locationTracker?.myLastLocation.longitude ?? 0)"
            let OAuthToken = self.getUserToken()
            submitRequired.Token = OAuthToken.Token
            submitRequired.TokenSecret = OAuthToken.TokenSecret
//            print(submitRequired.getPropertieNamesAsDictionary())
    setLastSubmitTime()
            currentRequest = Alamofire.request(.POST, CConstants.ServerURL + CConstants.SubmitLocationServiceURL, parameters: submitRequired.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
//                print(response.result.value)
                if response.result.isSuccess {
                }else{
                }
            }
            
//        }
        
        
    }
    
    private func setLastSubmitTime(){
        let userInfo = NSUserDefaults.standardUserDefaults()
        userInfo.setValue(NSDate(), forKey: "LastSubmitLocationTime")
    }
    
    private func getLastSubmitTime() -> Bool{
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        if let lastTime = userInfo.valueForKey("LastSubmitLocationTime") as? NSDate,
            let timeSpace = self.CurrentScheduledInterval {
            
            let date = NSDate()
//                print("\( date.timeIntervalSinceDate(lastTime))")
            return date.timeIntervalSinceDate(lastTime) > timeSpace * 60.0
        }
        return false
    }
    
    private func getUserToken() -> OAuthTokenItem{
        let userInfo = NSUserDefaults.standardUserDefaults()
        let userInfo1 = OAuthTokenItem(dicInfo: nil)
        userInfo1.Token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String
        userInfo1.TokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String
        return userInfo1
    }
    
    private func toEablePageControlColockOut(){
        self.clockOutSpinner.stopAnimating()
        self.clockOutBtn.setTitle("Clock Out", forState: .Normal)
        self.view.userInteractionEnabled = true
    }
    
    private func disableEablePageControlColockOut(){
        
        self.clockOutSpinner.startAnimating()
        self.clockOutBtn.setTitle("", forState: .Normal)
        self.view.userInteractionEnabled = false
    }
    
    private func toEablePageControlColockIn(){
        self.clockInSpinner.stopAnimating()
        self.clockInBtn.setTitle("Clock In", forState: .Normal)
        self.view.userInteractionEnabled = true
    }
    
    private func disableEablePageControlColockIn(){
        
        self.clockInSpinner.startAnimating()
        self.clockInBtn.setTitle("", forState: .Normal)
        self.view.userInteractionEnabled = false
    }
    
    private func callClockService(isClockIn isClockIn: Bool){
        currentRequest?.cancel()
//        print(CConstants.ServerURL + (isClockIn ? CConstants.ClockInServiceURL: CConstants.ClockOutServiceURL))
//        let userInfo = NSUserDefaults.standardUserDefaults()
        let clockOutRequiredInfo = ClockOutRequired()
        clockOutRequiredInfo.Latitude = "\(self.locationTracker?.myLastLocation.latitude ?? 0)"
        clockOutRequiredInfo.Longitude = "\(self.locationTracker?.myLastLocation.longitude ?? 0)"
        clockOutRequiredInfo.HostName = UIDevice.currentDevice().name
        let tl = Tool()
        clockOutRequiredInfo.IPAddress = tl.getWiFiAddress()
        let OAuthToken = self.getUserToken()
        clockOutRequiredInfo.Token = OAuthToken.Token!
//        clockOutRequiredInfo.Token = "asdfaasdf"
        clockOutRequiredInfo.TokenSecret = OAuthToken.TokenSecret!
        
//        print(clockOutRequiredInfo.getPropertieNamesAsDictionary())
        
      
        if isClockIn {
            disableEablePageControlColockIn()
        }else{
            disableEablePageControlColockOut()
        }
        
        currentRequest = Alamofire.request(.POST, CConstants.ServerURL + (isClockIn ? CConstants.ClockInServiceURL: CConstants.ClockOutServiceURL), parameters: clockOutRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
            if response.result.isSuccess {
//                print(response.result.value)
                if let rtnValue = response.result.value as? [String: AnyObject]{
                    let rtn = ClockResponse(dicInfo: rtnValue)
                    if Int(rtn.Status!) <= 0 {
                        if rtn.Message != "" {
                            self.PopMsgWithJustOK(msg: rtn.Message!) {
                                 (action : UIAlertAction) -> Void in
                                if rtn.Status == -4 {
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    if let login = storyboard.instantiateViewControllerWithIdentifier("LoginStart") as? LoginViewController {
                                        var va : [UIViewController]? = self.navigationController?.viewControllers
                                        if va != nil {
                                            va!.insert(login, atIndex: 0)
                                            self.navigationController?.viewControllers = va!
                                            self.navigationController?.popToRootViewControllerAnimated(true)
                                        }
                                        
                                    }
                                }
                                    
                                
                            }
                        }
                        
                       
                    }else{
                        if isClockIn {
                            
                                let item = ScheduledDayItem(dicInfo: nil)
                                item.ClockIn = rtn.ClockedInTime
                                item.ClockInCoordinate = rtn.Coordinate
                                item.ClockOut = ""
                                item.ClockInDay = rtn.Day
                                item.ClockInDayFullName = rtn.DayFullName
                                item.ClockInDayOfWeek = rtn.DayOfWeek
                                //                                    item.Hours = rtn
                                item.ClockInDayName = rtn.DayName
                                self.clockDataList!.append(item)
                            
                                self.mapTable.reloadData()
                                self.scrollToBottom()
                                self.update1()
                            
                        }else{
                            if let item = self.clockDataList?[self.clockDataList!.count-1] {
                                
                                item.ClockOut = rtn.ClockedOutTime
                                item.ClockOutCoordinate = rtn.Coordinate
                                
                                item.ClockOutDay = rtn.Day
                                item.ClockOutDayFullName = rtn.DayFullName
                                item.ClockOutDayOfWeek = rtn.DayOfWeek
                                item.ClockOutDayName = rtn.DayName
                                
                                self.mapTable.reloadData()
                                self.scrollToBottom()
                            }
                            self.locationUpdateTimer?.invalidate()
                            self.locationUpdateTimer = nil
                        }
                        
//                        let userInfo = NSUserDefaults.standardUserDefaults()
//                        userInfo.setValue(isClockIn ? "1":"0", forKey: constants.UserInfoClockedKey)
                    }
                }else{
                    self.PopServerError()
                }
                if isClockIn {
                    self.toEablePageControlColockIn()
                }else {
                    self.toEablePageControlColockOut()
                }
                
            }else{
                self.PopNetworkError()
                if isClockIn {
                    self.toEablePageControlColockIn()
                }else {
                    self.toEablePageControlColockOut()
                }
            }
        }
    }
    
    private func getTrackList(){
        
            
            let userInfo = NSUserDefaults.standardUserDefaults()
            if let token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String,
                 let tokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String {
                    
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
                    if showNoticie {
                        self.noticeOnlyText(CConstants.LoadingMsg)
                    }
                    
                    self.refreshControl?.beginRefreshing()
//                    print(self.refreshControl)
                    currentRequest = Alamofire.request(.POST, CConstants.ServerURL + CConstants.GetGISTrackURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                        
                        self.refreshControl?.endRefreshing()
                        if let line = self.polyLine {
                            self.trackMap.removeOverlay(line)
                            self.trackMap.removeAnnotations(self.trackMap.annotations)
                        }
                        if response.result.isSuccess {
//                            print(response.result.value)
                            if let rtnValue = response.result.value as? [String: AnyObject]{
                                
                                if rtnValue["Status"]!.integerValue == 1 {
                                    self.trackDotList = [TrackDotItem]()
                                    for item in rtnValue["Coordinates"] as! [[String: AnyObject]]{
                                        self.trackDotList!.append(TrackDotItem(dicInfo: item))
                                    }
                                    self.drawTrackPath()
                                    self.trackTable.reloadData()
                                }else{
                                    self.PopMsgWithJustOK(msg: rtnValue["Message"] as! String) {
                                        (action : UIAlertAction) -> Void in
                                        
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        if let login = storyboard.instantiateViewControllerWithIdentifier("LoginStart") as? LoginViewController {
                                            var va : [UIViewController]? = self.navigationController?.viewControllers
                                            if va != nil {
                                                va!.insert(login, atIndex: 0)
                                                self.navigationController?.viewControllers = va!
                                                self.navigationController?.popToRootViewControllerAnimated(true)
                                            }
                                        }
                                    }
                                }
                                
                            }else{
                                
                            }
                        }else{
                            
                            self.PopNetworkError()
                        }
                        self.performSelector("dismissProgress", withObject: nil, afterDelay: 0.2)
                    }
                }
            
            
            
        }
    
    
    var polyLine : MKPolyline?
    private func drawTrackPath(){
        
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
                trackMap.addOverlay(polyLine!)
                
            }
        }
    
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let pr = MKPolylineRenderer(overlay: overlay)
//        pr.strokeColor = UIColor(red: 20/255.0, green: 72/255.0, blue: 116/255.0, alpha: 1)
        pr.strokeColor = UIColor.blueColor()
        pr.lineWidth = 2
        return pr
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        print(self.clearItem.tintColor)
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
            UIView.animateWithDuration(0.3, delay: 0.0
                , options: UIViewAnimationOptions.CurveEaseOut
                , animations: { () -> Void in
                    self.clearItem.tintColor = UIColor.whiteColor()
                }) { (_) -> Void in
                    
            }
            

        }
        var annotationView : MKPinAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier("April") as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "April")
        }
        annotationView?.pinTintColor = UIColor.redColor()
        annotationView?.animatesDrop = true
        return annotationView
        
    }
   
}

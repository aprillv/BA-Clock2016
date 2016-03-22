//
//  ClockMapViewController.swift
//  BA-Clock
//
//  Created by April on 1/12/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit
import Alamofire

class ClockMapViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate {
   

    @IBOutlet var tabbar: UITabBar!{
        didSet{
            for item in tabbar.items! {
                item.image = item.image?.imageWithRenderingMode(.AlwaysOriginal)
            }
            
//            tabbar.barTintColor = UIColor.whiteColor()
        }
    }
    @IBOutlet var clearItem: UIBarButtonItem!
//    @IBOutlet weak var clockInSpinner: UIActivityIndicatorView!
//    @IBOutlet weak var clockOutSpinner: UIActivityIndicatorView!
    @IBOutlet weak var switchItem: UIBarButtonItem!
    @IBOutlet weak var mapTable: UITableView!{
        didSet{
//            firstrefreshControl = UIRefreshControl()
//            firstrefreshControl!.addTarget(self, action: "refreshfirst:", forControlEvents: .ValueChanged)
//            mapTable.addSubview(firstrefreshControl!)
            //            trackTable.separatorColor = UIColor(red: 20/255, green: 72/255, blue: 116/255, alpha: 0.3)
        }
    }
  
    
    var refreshControl : UIRefreshControl?
    var firstrefreshControl : UIRefreshControl?
    
    
    
    func refreshfirst(refreshControl: UIRefreshControl) {
        // Do your job, when done:
        firstTime = true
        self.callGetList()
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
        static let CellTextIdentifier : String = "clockTextCell"
        static let CellIdentifierTrack : String = "trackTableCell"
//        static let UserInfoClockedKey : String = "ClockedIn"
        
        static let UserInfoScheduledFrom : String = "ScheduledFrom"
        static let UserInfoScheduledTo : String = "ScheduledTo"
        
        static let RightTopItemTitleMap : String = "List"
        static let RightTopItemTitleText : String = "GIS Track"
        
        static let SegueToMoreController = "More"
        
    }
    
    
   
    
    private func scrollToBottom(){
//        print(mapTable?.contentSize.height)
        if (mapTable?.contentSize.height ?? 10) - (mapTable?.frame.size.height ?? 10) > 10 {
            mapTable.setContentOffset(CGPoint(x: 0, y: (mapTable?.contentSize.height ?? 0) - (mapTable?.frame.size.height ?? 0)), animated: true)
            
        }
    }
    
    
  
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeList", name: "beginTracking", object: nil)
        self.callGetList()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "beginTracking", object: nil)
    }
    
    func changeList(){
        if let list = self.clockDataList {
            var i : ScheduledDayItem?
            for item in list {
                if item.ClockIn == "-1" {
                    i = item
                    break
                }
            }
            if let item = i {
                if let index = list.indexOf(item) {
                    self.clockDataList!.removeAtIndex(index)
                    
//                    let indexpath = NSIndexPath(forRow: index, inSection: 0)
//                    self.mapTable.beginUpdates()
//                    self.mapTable.deleteRowsAtIndexPaths([indexpath], withRowAnimation: .None)
//                    self.mapTable.endUpdates()
                }
               
            }
            
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
//            self.callGetList()
            self.syncFrequency()
        }else{
            firstTime = true
        }
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        view.bringSubviewToFront(mapTable)
        title = userInfo.valueForKey(CConstants.UserFullName) as? String
        
    }
    
   
    
    
    
    
    private func callGetList(){
//        print("+++++++++++++")
        let userInfo = NSUserDefaults.standardUserDefaults()
        if let token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String{
            if let tokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String {
                
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
//                self.firstrefreshControl?.beginRefreshing()
                var hud : MBProgressHUD?
                if self.clockDataList == nil {
//                    self.noticeOnlyText(CConstants.LoadingMsg)
                    hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    hud!.labelText = CConstants.LoadingMsg
                }
                currentRequest = Alamofire.request(.POST, CConstants.ServerURL + CConstants.GetScheduledDataURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                    self.firstrefreshControl?.endRefreshing()
                    if self.clockDataList == nil {
                    hud!.hide(true)
                    }
                    if response.result.isSuccess {
//                        print(response.result.value)
                        if let rtnValue = response.result.value as? [String: AnyObject]{
                            
                            if rtnValue["Status"]!.integerValue == 1 {
                                if self.clockDataList != nil {
//                                    var changed = false
                                    if let list = rtnValue["ScheduledDay"] as? [[String: AnyObject]] {
                                        for item in list{
                                            let info = ScheduledDayItem(dicInfo: item)
                                            
                                            if self.clockDataList!.filter(
                                                { $0.ClockIn == info.ClockIn && $0.ClockOut == info.ClockOut}
                                                ).count > 0 {
                                            } else {
                                                let listtmp = self.clockDataList!.filter(
                                                    { $0.ClockIn == info.ClockIn}
                                                )
                                                if listtmp.count > 0 {
                                                     self.mapTable.beginUpdates()
                                                    let ind = self.clockDataList!.indexOf(listtmp[0])
//                                                    self.clockDataList?.removeAtIndex(ind!)
                                                    let s = ind?.distanceTo(self.clockDataList!.indexOf(self.clockDataList![0])!)
                                                    
                                                    let p = NSIndexPath(forRow: -s!, inSection: 0)
                                                    self.clockDataList![-s!] = info
                                                    
                                                    self.mapTable.reloadRowsAtIndexPaths([p], withRowAnimation: .None)
                                                    self.mapTable.endUpdates()
                                                }else{
                                                    self.mapTable.beginUpdates()
                                                    let h = self.clockDataList!.count
                                                    self.clockDataList?.insert(info, atIndex: h)
                                                    let p = NSIndexPath(forRow: h, inSection: 0)
                                                    self.mapTable.insertRowsAtIndexPaths([p], withRowAnimation: .Top)
                                                    self.mapTable.endUpdates()
//                                                    self.scrollToBottom()
                                                }
//                                                changed = true
                                                
                                                
                                            }
                                            
                                        }
                                    }
//                                    if changed {
//                                        self.mapTable?.reloadData()
//                                        self.scrollToBottom()
//                                        
//                                    }
                                }else{
                                    self.clockDataList = [ScheduledDayItem]()
                                    for item in rtnValue["ScheduledDay"] as! [[String: AnyObject]]{
                                        self.clockDataList!.append(ScheduledDayItem(dicInfo: item))
                                    }
                                    let tl = Tool()
                                    let (isTime, timespace) = tl.getTimeInter()
                                    
                                    if !isTime {
                                        self.clockDataList!.append(ScheduledDayItem(dicInfo: ["ClockIn" : "-1", "ClockOut":"-1"]))
                                        if timespace > 0 {
                                            self.performSelector("beginTracking", withObject: nil, afterDelay: timespace)
                                        }
                                    }
                                    self.update1()
                                    if let a = self.CurrentScheduledInterval {
                                        if a > 0 && self.getLastSubmitTime(){
                                            self.updateLocation()
                                        }
                                    }
                                }
                               
                                
                                
                            }else{
                                self.PopMsgWithJustOK(msg: rtnValue["Message"] as! String) {
                                    (action : UIAlertAction) -> Void in
                                    
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    if let login = storyboard.instantiateViewControllerWithIdentifier("LoginStart") as? LoginViewController {
                                        
                                        var va : [UIViewController]? = self.navigationController?.viewControllers
                                        if va != nil {
                                            self.locationTracker?.stopLocationTracking()
                                            self.locationTracker = nil
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
                    
                }
            }
        }
        
        
    }
    
    
    func beginTracking(){
    NSNotificationCenter.defaultCenter().postNotificationName("beginTracking", object: nil)
    }
   
    
    
    
    
    private func update1(){
        
        self.SyncTimer = NSTimer.scheduledTimerWithTimeInterval(3600, target: self, selector: "syncFrequency", userInfo: nil, repeats: true)
        
        if let a = CurrentScheduledInterval {
            if a > 0 {
                self.locationUpdateTimer?.invalidate()
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
                                            self.locationUpdateTimer?.invalidate()
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
//        return 60
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
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item = self.clockDataList![indexPath.row]
        if (item.ClockIn! != "-1"){
            return 189
        }else{
            return 50
        }
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
            if let item : ScheduledDayItem = list[indexPath.row] {
                if item.ClockIn != "-1" {
                    let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifier, forIndexPath: indexPath)
                    if let cellitem = cell as? ClockMapCell {
                        cellitem.superActionView = self
                        cellitem.clockInfo = item
                        
                        cell.contentView.tag = indexPath.row
                    }
                    return cell
                }else{
//                    UIImage(named: "clockin.png")?.stretchableImageWithLeftCapWidth(20, topCapHeight: 26)
                    let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellTextIdentifier, forIndexPath: indexPath)
                    if let cell1 = cell as? TextTableViewCell{
                        if let img2 = UIImage(named: "clockin3"){
//                            image2.size.width*0.5 topCapHeight:image2.size.width*0.8
//                            let a : CGFloat = 0.5
                            cell1.img.image = img2.stretchableImageWithLeftCapWidth(20, topCapHeight: Int(img2.size.width*0.4))
                        }
                    
                        if item.ClockOut == "-1" {
                            let date = NSDate()
                            //        print(date)
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "MM/dd/yy hh:mm a"
                            
                            dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
                            cell1.lbl?.text = "You are not being track at \(dateFormatter.stringFromDate(date))."
//                            cell1.lbl.textColor = UIColor.whiteColor()
                        }else{
                            cell1.lbl?.text = "You are being track at this time."
                        }
                        
                    }
                    
                    return cell
                }
            }
            
            
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
        }else if segue.identifier == constants.SegueToMoreController {
            if let dvc = segue.destinationViewController as? MoreViewController {
                dvc.locationTracker = self.locationTracker
                
            }
        }
    }
    
    @IBAction func doClockIn() {
        self.locationTracker?.getMyLocation222()
        self.callClockService(isClockIn: true)
    }
    @IBAction func doClockOut() {
        
        self.locationTracker?.getMyLocation222()
        self.callClockService(isClockIn: false)
    }
    
    
    
    
    
    
    
    private var lastCallSubmitLocationService : NSDate?
    private func callSubmitLocationService(){
//            print("april")
            lastCallSubmitLocationService = NSDate()
            let submitRequired = SubmitLocationRequired()
            submitRequired.Latitude = "\(self.locationTracker?.myLastLocation.latitude ?? 0)"
            submitRequired.Longitude = "\(self.locationTracker?.myLastLocation.longitude ?? 0)"
            let OAuthToken = self.getUserToken()
            submitRequired.Token = OAuthToken.Token
            submitRequired.TokenSecret = OAuthToken.TokenSecret
            print(submitRequired.getPropertieNamesAsDictionary())
    setLastSubmitTime()
            currentRequest = Alamofire.request(.POST, CConstants.ServerURL + CConstants.SubmitLocationServiceURL, parameters: submitRequired.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                print(response.result.value)
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
            return date.timeIntervalSinceDate(lastTime) > timeSpace
        }
        return true
    }
    
    private func getUserToken() -> OAuthTokenItem{
        let userInfo = NSUserDefaults.standardUserDefaults()
        let userInfo1 = OAuthTokenItem(dicInfo: nil)
        userInfo1.Token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String
        userInfo1.TokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String
        return userInfo1
    }
    
    private func toEablePageControlColockOut(){
//        self.clockOutSpinner.stopAnimating()
//        self.clockOutBtn.setTitle("Clock Out", forState: .Normal)
        self.view.userInteractionEnabled = true
    }
    
    private func disableEablePageControlColockOut(){
        
//        self.clockOutSpinner.startAnimating()
//        self.clockOutBtn.setTitle("", forState: .Normal)
        self.view.userInteractionEnabled = false
    }
    
    private func toEablePageControlColockIn(){
//        self.clockInSpinner.stopAnimating()
//        self.clockInBtn.setTitle("Clock In", forState: .Normal)
        self.view.userInteractionEnabled = true
    }
    
    private func disableEablePageControlColockIn(){
        
//        self.clockInSpinner.startAnimating()
//        self.clockInBtn.setTitle("", forState: .Normal)
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
    
    
     func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem){
        switch item.title! {
        case "Clock In":
            doClockIn()
        case "Clock Out":
            doClockOut()
        default:
            self.performSegueWithIdentifier(constants.SegueToMoreController, sender: nil)
        }
    }
    
    
   
}

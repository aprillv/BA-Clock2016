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
        }
    }
    
//    var a : sche
    @IBOutlet var clearItem: UIBarButtonItem!
    @IBOutlet weak var switchItem: UIBarButtonItem!
    @IBOutlet weak var mapTable: UITableView!
  
    
    var refreshControl : UIRefreshControl?
    var firstrefreshControl : UIRefreshControl?
    
    
    var locationManager : CLocationManager?
    
    
    func refreshfirst(refreshControl: UIRefreshControl) {
        // Do your job, when done:
        firstTime = true
        self.callGetList()
    }
    
   
    @IBOutlet weak var map_listContstraint: NSLayoutConstraint!
   
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
        
        
        self.callGetList()
    }
    
  
    
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
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
                }
               
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLocationManager.sharedInstance
        locationManager?.startUpdatingLocation()
        // for test notification
        locationManager?.setNotComeBackNotification(NSDate())
        
        checkUpate()
        
             
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255.0, green: 72/255.0, blue: 116/255.0, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
//        if self.clockDataList == nil {
        firstTime = true
        Tool.saveDeviceTokenToSever()
        let tl = Tool()
        tl.syncFrequency()
//        }else{
//            firstTime = true
//        }
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        view.bringSubviewToFront(mapTable)
        title = userInfo.valueForKey(CConstants.UserFullName) as? String
        
    }
    
   
    
    
    
    
    private func callGetList(){
//        print("+++++++++++++")
        let userInfo = NSUserDefaults.standardUserDefaults()
        if let token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String{
            if let tokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String {
                let tl = Tool()
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
                loginRequiredInfo.ClientTime = tl.getClientTime()
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
                                                }
                                                
                                                
                                            }
                                            
                                        }
                                        self.scrollToBottom()
                                    }
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
//                                            self.locationTracker?.stopLocationTracking()
//                                            self.locationTracker = nil
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
    
    
    
    func updateLocation(){
//      print(NSRunLoop.currentRunLoop().ismai)
        
        let tl = Tool()
        if tl.getTime2() {
        }else{
            let log = cl_log()
            log.savedLogToDB(NSDate(), xtype: true, lat: "updateLocation")
        }
        
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
    
    @IBAction func gotoLog(sender: AnyObject) {
        if self.title == "April" || self.title == "april Lv" || self.title == "jack fan" {
            self.performSegueWithIdentifier("showLog", sender: nil)
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
//        if segue.identifier == "showMapDetail" {
//            if let item = self.selectedItem {
//                if let dvc = segue.destinationViewController as? MapViewController {
////                    item.ClockInCoordinate?.Longitude
//                    
//                    if isIn! {
//                    dvc.coordinate = CLLocationCoordinate2D(latitude: item.ClockInCoordinate!.Latitude!.doubleValue, longitude: item.ClockInCoordinate!.Longitude!.doubleValue)
//                    }else{
//                    dvc.coordinate = CLLocationCoordinate2D(latitude: item.ClockOutCoordinate!.Latitude!.doubleValue, longitude: item.ClockOutCoordinate!.Longitude!.doubleValue)
//                    }
//                    
//                }
//            }
//        }else if segue.identifier == constants.SegueToMoreController {
//            if let dvc = segue.destinationViewController as? MoreViewController {
//                dvc.locationTracker = self.locationTracker
//                
//            }
//        }
    }
    
    @IBAction func doClockIn() {
//        self.locationTracker?.getMyLocation222()
        self.callClockService(isClockIn: true)
    }
    @IBAction func doClockOut() {
        
//        self.locationTracker?.getMyLocation222()
        self.callClockService(isClockIn: false)
    }
    
    
    
    
    
    
    
    private var lastCallSubmitLocationService : NSDate?
       
   
    
    private func callClockService(isClockIn isClockIn: Bool){
        currentRequest?.cancel()
//        print(CConstants.ServerURL + (isClockIn ? CConstants.ClockInServiceURL: CConstants.ClockOutServiceURL))
//        let userInfo = NSUserDefaults.standardUserDefaults()
        let clockOutRequiredInfo = ClockOutRequired()
        
        clockOutRequiredInfo.Latitude = "\(self.locationManager?.currentLocation?.coordinate.latitude ?? 0)"
        clockOutRequiredInfo.Longitude = "\(self.locationManager?.currentLocation?.coordinate.longitude ?? 0)"
        clockOutRequiredInfo.HostName = UIDevice.currentDevice().name
        let tl = Tool()
        clockOutRequiredInfo.IPAddress = tl.getWiFiAddress()
        clockOutRequiredInfo.ClientTime = tl.getClientTime()
        
        let OAuthToken = tl.getUserToken()
        clockOutRequiredInfo.Token = OAuthToken.Token!
//        clockOutRequiredInfo.Token = "asdfaasdf"
        clockOutRequiredInfo.TokenSecret = OAuthToken.TokenSecret!
        
//        print(clockOutRequiredInfo.getPropertieNamesAsDictionary())
        
      
        self.view.userInteractionEnabled = false
       
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
                        }
                    }
                }else{
                    let cl = cl_submitData()
                    cl.savedSubmitDataToDB(clockOutRequiredInfo.ClientTime ?? ""
                        , lat: self.locationManager?.currentLocation?.coordinate.latitude ?? 0.0
                        , lng: self.locationManager?.currentLocation?.coordinate.longitude ?? 0.0
                        , xtype: Int(isClockIn ? CConstants.ClockInType : CConstants.ClockOutType))
                    self.PopServerError()
                }
               self.view.userInteractionEnabled = true
                
            }else{
                let cl = cl_submitData()
                cl.savedSubmitDataToDB(clockOutRequiredInfo.ClientTime ?? ""
                    , lat: self.locationManager?.currentLocation?.coordinate.latitude ?? 0.0
                    , lng: self.locationManager?.currentLocation?.coordinate.longitude ?? 0.0
                    , xtype: Int(isClockIn ? CConstants.ClockInType : CConstants.ClockOutType))
//                self.PopNetworkError()
                self.view.userInteractionEnabled = true
            }
        }
    }
    
    
     func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem){
        tabBar.selectedItem = nil
        switch item.title! {
        case "Clock In":
            doClockIn()
        case "Clock Out":
            doClockOut()
        case "Come Back":
            doComeBack()
        default:
            self.performSegueWithIdentifier(constants.SegueToMoreController, sender: nil)
        }
    }
    
    private func doComeBack(){
//        self.locationTracker?.getMyLocation222()
//        currentRequest?.cancel()
        //        print(CConstants.ServerURL + (isClockIn ? CConstants.ClockInServiceURL: CConstants.ClockOutServiceURL))
        //        let userInfo = NSUserDefaults.standardUserDefaults()
        let clockOutRequiredInfo = ClockOutRequired()
        clockOutRequiredInfo.Latitude = "\(self.locationManager?.currentLocation?.coordinate.latitude ?? 0)"
        clockOutRequiredInfo.Longitude = "\(self.locationManager?.currentLocation?.coordinate.longitude ?? 0)"
        clockOutRequiredInfo.HostName = UIDevice.currentDevice().name
        let tl = Tool()
        clockOutRequiredInfo.IPAddress = tl.getWiFiAddress()
        
        let OAuthToken = tl.getUserToken()
        clockOutRequiredInfo.Token = OAuthToken.Token!
        clockOutRequiredInfo.TokenSecret = OAuthToken.TokenSecret!
        clockOutRequiredInfo.ClientTime = tl.getClientTime()
        var param = clockOutRequiredInfo.getPropertieNamesAsDictionary()
        param["ActionType"] = "Come Back"
        //        print(clockOutRequiredInfo.getPropertieNamesAsDictionary())
        
        
        var hud : MBProgressHUD?
        hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud!.labelText = "Saving to server..."
        
        Alamofire.request(.POST, CConstants.ServerURL + "ComeBack.json", parameters: param).responseJSON{ (response) -> Void in
            hud?.hide(true)
            if response.result.isSuccess {
//                print(response.result.value)
                UIApplication.sharedApplication().cancelAllLocalNotifications()
                self.callGetList()
            }else{
                let cl = cl_submitData()
                cl.savedSubmitDataToDB(clockOutRequiredInfo.ClientTime ?? ""
                    , lat: self.locationManager?.currentLocation?.coordinate.latitude ?? 0.0
                    , lng: self.locationManager?.currentLocation?.coordinate.longitude ?? 0.0
                    , xtype: CConstants.ComeBackType)
//                self.PopNetworkError()
                
            }
        }
    }

    
   
}

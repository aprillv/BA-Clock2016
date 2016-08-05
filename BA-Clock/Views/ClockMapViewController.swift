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
            let userInfo = NSUserDefaults.standardUserDefaults()
            if userInfo.integerForKey(CConstants.ShowClockInAndOut) ?? 1 == 0 {
                tabbar.items?.removeFirst()
                tabbar.items?.removeFirst()
            }
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
//            if oldValue == nil {
//                lastDataCount = clockDataList?.count ?? 0
//            }
//            print(clockDataList)
//            self.mapTable?.reloadData()
//            self.textTable?.reloadData()
//            self.clockDataList222 = self.clockDataList?.filter({$0.})
//            var tmp  = [ScheduledDayItem]()
            
            
            if clockDataList != nil && clockDataList?.count > 0 {
//                scrollToBottom()
                self.updateLastSyncDateTime()
                
                
                var beginAdd = false
                let dateFormatter = NSDateFormatter()
                
                dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
                
                
                if let logineddate = NSUserDefaults.standardUserDefaults().valueForKey(CConstants.LoginedDate) as? NSDate {
                    
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    let today = dateFormatter.stringFromDate(logineddate)
                    
                    
                    let todayday = dateFormatter.dateFromString(today)
                    
                    dateFormatter.dateFormat = "MM/dd/yyyyhh:mm:ss a"
                    
                    
                   var tmp  = [ScheduledDayItem]()
                    for h in clockDataList! {
                        let h0 = h
                        if !beginAdd {
//                            print((h.clockInDateDay ?? "") + (h.ClockIn ?? ""))
//                            if (h.clockOutDateDay ?? "00").containsString("1900") {
//                                h0.ClockInName = ""
//                                beginAdd = true
//                            }else{
//                            print((h.clockOutDateDay ?? "") + (h.ClockOut ?? ""),
//                                  dateFormatter.dateFromString((h.clockOutDateDay ?? "") + (h.ClockOut ?? "")),
//                                  today)
                                if let dates = dateFormatter.dateFromString((h.clockInDateDay ?? "") + (h.ClockIn ?? "")) {
                                    if dates.timeIntervalSinceDate(todayday!) > 0 {
                                        beginAdd = true
                                    }
                                }
                            
                            if !beginAdd{
                                if let dates2 = dateFormatter.dateFromString((h.clockOutDateDay ?? "") + (h.ClockOut ?? "")) {
                                    print(todayday)
                                    if dates2.timeIntervalSinceDate(todayday!) > 0 {
                                        beginAdd = true
                                    }
                                }
                            }
//                            }
//                            if let dates = dateFormatter.dateFromString((h.clockInDateDay ?? "") + (h.ClockIn ?? "")) {
//                                if dates.timeIntervalSinceDate(logineddate) > 0 {
//                                    beginAdd = true
//                                }
//                            }else if let dates = dateFormatter.dateFromString((h.clockOutDateDay ?? "") + (h.ClockOut ?? "")) {
//                                if dates.timeIntervalSinceDate(logineddate) > 0 {
//                                    beginAdd = true
//                                    h0 = ScheduledDayItem(dicInfo: nil)
//                                    h0.ClockIn = ""
//                                    h0.ClockOut = h.ClockOut
//                                    h0.clockOutDateDay = h.clockOutDateDay
//                                    h0.ClockOutName = h.ClockOutName
//                                    h0.ClockOutDayName = h.ClockOutDayName
//                                    h0.ClockOutDay = h.ClockOutDay
//                                    h0.ClockOutDayOfWeek = h.ClockOutDayOfWeek
//                                    h0.ClockOutCoordinate = h.ClockInCoordinate
//                                    h0.ClockOutDayFullName = h.ClockOutDayFullName
//                                }
//                            }
                        }
                        if beginAdd {
                            tmp.append(h0)
                        }
                    }
                    self.clockDataList222 = tmp
                }else{
                    self.clockDataList222 = self.clockDataList
                }
                
                
            }
            
//            if lastDataCount != -1 {
//                if lastDataCount == 0 {
//                    self.clockDataList222 = self.clockDataList
//                }else{
//                    if self.clockDataList?.count ?? 0 > lastDataCount {
//                        self.clockDataList222 = Array(self.clockDataList![lastDataCount...((self.clockDataList?.count ?? 1)-1)])
//                    }else{
//                        self.clockDataList222 = [ScheduledDayItem]()
//                    }
//                    
//                }
//            }
        }
    }
    
    var lastDataCount  = -1
    var clockDataList222 : [ScheduledDayItem]?{
        didSet{
            //            print(clockDataList)
            self.mapTable?.reloadData()
            //            self.textTable?.reloadData()
            
            if clockDataList222 != nil && clockDataList222?.count > 0 {
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
        
        
//        let ss = cl_showSchedule()
//        let rtn = ss.getScheduledList()
//        if rtn.count == 0 {
        if gotoOutPage {
            gotoOutPage = false
            self.callGetList()
        }
        
//        }else{
//            self.clockDataList = rtn
        
            
//            let net = NetworkReachabilityManager()
//            if net?.isReachable ?? false {
//                self.callGetList()
//            }
            
//        }
        
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
    
    func checkUpate2(){
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"]
        let parameter = ["version": (version == nil ?  "" : version!), "appid": "iphone_ClockIn"]
        
        Alamofire.request(.POST,
            CConstants.ServerVersionURL + CConstants.CheckUpdateServiceURL,
            parameters: parameter).responseJSON{ (response) -> Void in
                if response.result.isSuccess {
                    
                    if let rtnValue = response.result.value{
                        
                        if rtnValue.integerValue == 1 {
                            
                        }else{
                            if let url = NSURL(string: CConstants.InstallAppLink){
                                
                                UIApplication.sharedApplication().openURL(url)
                            }else{
                                
                            }
                        }
                    }else{
                        
                    }
                }else{
                    
                }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("for test ", self.navigationController?.viewControllers.count)
        checkUpate2()
        
        locationManager = CLocationManager.sharedInstance
        locationManager?.startUpdatingLocation()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255.0, green: 72/255.0, blue: 116/255.0, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
//        if self.clockDataList == nil {
        firstTime = true
        Tool.saveDeviceTokenToSever()
        let tl = Tool()
        tl.syncFrequency()
        
        
        let userInfo = NSUserDefaults.standardUserDefaults()
//        userInfo.setValue(NSDate(), forKey: CConstants.LoginedDate)
        view.bringSubviewToFront(mapTable)
        title = userInfo.valueForKey(CConstants.UserFullName) as? String
        self.callGetList()
    }
    
    func updateLastSyncDateTime() {
        if self.clockDataList?.count ?? 0 == 0 {
        self.updateLastSyncDateTime0()
        }else{
        let tl = Tool()
        let userInfo = NSUserDefaults.standardUserDefaults()
    
        if let h = self.clockDataList?.filter({$0.ClockInName == "Clock In"}).last {
//             print("a", i++)
            let lastClockIn = "\(h.clockInDateDay!) \(h.ClockIn!)"
            let ld = tl.getDateFromString(lastClockIn)
            userInfo.setValue(ld, forKey: CConstants.LastClockInTime)
           
        }
        if let h = self.clockDataList?.filter({$0.ClockOutName == "Clock Out" && $0.ClockOut != ""}).last {
            
                let lastClockOut = "\(h.clockOutDateDay!) \(h.ClockOut!)"
                let ld = tl.getDateFromString(lastClockOut)
                userInfo.setValue(ld, forKey: CConstants.LastClockOutTime)
//            print("b")
            //                print(h.ClockIn, h.ClockInDay, h.ClockOutDayFullName)
        }
    
        if let h = self.clockDataList?.filter({$0.ClockInName == "Come Back"}).last {
            let lastClockIn = "\(h.clockInDateDay!) \(h.ClockIn!)"
            let ld = tl.getDateFromString(lastClockIn)
            userInfo.setValue(ld, forKey: CConstants.LastComeBackTime)
//            print("c")
        }
    
        if let h = self.clockDataList?.filter({
            $0.ClockOutName != "Clock Out"
                && $0.ClockOut != ""
                && $0.ClockIn != "-1"}).last {
//            print(h.ClockOutName)
//            if h.ClockIn ?? "-1" == "-1" && h.ClockOut  ?? "-1" == -1 {
//                if self.clockDataList?.count > 1 {
//                    let h0 = self.
//                }
//            }else{
                if let out = h.clockOutDateDay, let out0 = h.ClockOut {
                    let lastClockOut = "\(out) \(out0)"
                    let ld = tl.getDateFromString(lastClockOut)
                    userInfo.setValue(ld, forKey: CConstants.LastGoOutTime)
                }
//            }
            
//            let lastClockOut = "\(h.clockOutDateDay!) \(h.ClockOut!)"
//                let ld = tl.getDateFromString(lastClockOut)
//                userInfo.setValue(ld, forKey: CConstants.LastGoOutTime)
            
//            print("d")
            //                print(h.ClockIn, h.ClockInDay, h.ClockOutDayFullName)
        }
        }
    }
    func updateLastSyncDateTime0() {
//        let tl = Tool()
        let userInfo = NSUserDefaults.standardUserDefaults()
        userInfo.removeObjectForKey(CConstants.LastClockInTime)
        userInfo.removeObjectForKey(CConstants.LastClockOutTime)
        userInfo.removeObjectForKey(CConstants.LastComeBackTime)
        userInfo.removeObjectForKey(CConstants.LastGoOutTime)
        
    }
   
    
    
    
    
    private func callGetList(){
//        print("+++++++++++++")
        let userInfo = NSUserDefaults.standardUserDefaults()
        if let token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String{
            if let tokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String,
            email = userInfo.valueForKey(CConstants.UserInfoEmail) as? String,
            pwd = userInfo.valueForKey(CConstants.UserInfoPwd) as? String{
                let tl = Tool()
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Email = email
                loginRequiredInfo.Password = tl.md5(string: pwd)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
                let now = NSDate()
                loginRequiredInfo.ClientTime = tl.getClientTime(now)
//                self.firstrefreshControl?.beginRefreshing()
                var hud : MBProgressHUD?
                if self.clockDataList == nil {
//                    self.noticeOnlyText(CConstants.LoadingMsg)
                    hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    hud!.labelText = CConstants.LoadingMsg
                    hud?.userInteractionEnabled = false
                }
                
//                userInfo.setObject(email, forKey: CConstants.UserInfoEmail)
//                userInfo.setObject(password, forKey: CConstants.UserInfoPwd)
//                
//                print(loginRequiredInfo.getPropertieNamesAsDictionary())
                currentRequest = Alamofire.request(.POST, CConstants.ServerURL + CConstants.GetScheduledDataURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                    self.firstrefreshControl?.endRefreshing()
                     hud?.userInteractionEnabled = true
                    if self.clockDataList == nil {
                        hud!.hide(true)
                    }
                    if response.result.isSuccess {
                        print(response.result.value)
                        if let rtnValue = response.result.value as? [String: AnyObject]{
                            
                            if rtnValue["Status"]!.integerValue == 1 {
//                                print(rtnValue["ClockYN"])
                                if let a = rtnValue["ClockYN"] as? Bool {
//                                    print(a)
                                    if !a {
                                        if self.tabbar.items?.count ?? 0 == 4 {
                                            self.tabbar.items?.removeFirst()
                                            self.tabbar.items?.removeFirst()
                                        }
                                    }
                                }
                                let serverTime = rtnValue["ServerTime"] as! String
                                tl.SetNextCallTime(serverTime)
                                
                                if self.clockDataList != nil && self.clockDataList?.count > 0{
//                                    if let lastItem = self.clockDataList?.last{
//                                        if let list = rtnValue["ScheduledDay"] as? [[String: AnyObject]] {
//                                            if let lastItem1 = list.last {
//                                                let info = ScheduledDayItem(dicInfo: lastItem1)
//                                                let date0 = tl.getDateFromString("\(lastItem.clockInDateDay!) \(lastItem.ClockIn!)")
//                                                let date1 = tl.getDateFromString("\(info.clockInDateDay!) \(info.ClockIn!)")
//                                                if date1.timeIntervalSinceDate(date0) > 0 {
////                                                let msg = "We detect  use this app with anoter device, "
//                                                }
//                                            }
//                                        }
//                                    }
                                }else{
                                    var tmpaaaa =  [ScheduledDayItem]()
                                    
                                    let ss = cl_showSchedule()
                                    for item in rtnValue["ScheduledDay"] as! [[String: AnyObject]]{
                                        let info = ScheduledDayItem(dicInfo: item)
                                        tmpaaaa.append(info)
                                        ss.savedSubmitDataToDB(info)
                                    }
                                    self.clockDataList = tmpaaaa
//                                    self.updateLastSyncDateTime()
                                }
                                
//                                return
//                                if self.clockDataList != nil {
////                                    var changed = false
////                                    if let list = rtnValue["ScheduledDay"] as? [[String: AnyObject]] {
////                                        for item in list{
////                                            let info = ScheduledDayItem(dicInfo: item)
////                                            
////                                            
////                                            if self.clockDataList!.filter(
////                                                { $0.ClockIn == info.ClockIn && $0.ClockOut == info.ClockOut}
////                                                ).count > 0 {
////                                            } else {
////                                                let listtmp = self.clockDataList!.filter(
////                                                    { $0.ClockIn == info.ClockIn}
////                                                )
////                                                if listtmp.count > 0 {
////                                                     self.mapTable.beginUpdates()
////                                                    let ind = self.clockDataList!.indexOf(listtmp[0])
////                                                    let s = ind?.distanceTo(self.clockDataList!.indexOf(self.clockDataList![0])!)
////                                                    
////                                                    let p = NSIndexPath(forRow: -s!, inSection: 0)
////                                                    self.clockDataList![-s!] = info
////                                                    
////                                                    self.mapTable.reloadRowsAtIndexPaths([p], withRowAnimation: .None)
////                                                    self.mapTable.endUpdates()
////                                                }else{
////                                                    self.mapTable.beginUpdates()
////                                                    let h = self.clockDataList!.count
////                                                    self.clockDataList?.insert(info, atIndex: h)
////                                                    let p = NSIndexPath(forRow: h, inSection: 0)
////                                                    self.mapTable.insertRowsAtIndexPaths([p], withRowAnimation: .Top)
////                                                    self.mapTable.endUpdates()
////                                                }
////                                                
////                                                
////                                            }
////                                            
////                                        }
////                                        
////                                        var toshow = true
////                                        if let h = self.clockDataList?.last {
////                                            if h.ClockIn == "-1" {
////                                               toshow = false
////                                            }
////                                        }
////                                        if toshow {
////                                            let tl = Tool()
////                                            let (isTime, timespace) = tl.getTimeInter()
////                                            
////                                            if !isTime {
////                                                self.clockDataList!.append(ScheduledDayItem(dicInfo: ["ClockIn" : "-1", "ClockOut":"-1"]))
////                                                if timespace > 0 {
////                                                    
////                                                }
////                                            }
////                                        }
////                                        
////                                        self.scrollToBottom()
////                                    }
//                                    
//                                }else{
                                    var tmpaaaa =  [ScheduledDayItem]()
                                    let ss = cl_showSchedule()
                                    for item in rtnValue["ScheduledDay"] as! [[String: AnyObject]]{
                                        let info = ScheduledDayItem(dicInfo: item)
                                        tmpaaaa.append(info)
                                        ss.savedSubmitDataToDB(info)
                                    }
                                    self.clockDataList = tmpaaaa
//                                    self.updateLastSyncDateTime()
                                
                                    
                                    var toshow = true
                                    if let h = self.clockDataList?.last {
                                        if h.ClockIn == "-1" {
                                            toshow = false
                                        }
                                    }
                                    if toshow {
                                        let tl = Tool()
                                        let (isTime, timespace) = tl.getTimeInter()
                                        
                                        if !isTime {
                                            self.clockDataList!.append(ScheduledDayItem(dicInfo: ["ClockIn" : "-1", "ClockOut":"-1"]))
                                            if timespace > 0 {
                                                
                                            }
                                        }
                                    }
                                    
//                                }
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
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let item = self.clockDataList![indexPath.row]
//        if (item.ClockIn ?? "-1" != "-1"){
            return 100
//        }else{
//            return 50
//        }
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == mapTable {
            return clockDataList222?.count ?? 0
        }else{
            return clockDataList222?.count ?? 0
        }
        
    }
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       
        
        if tableView == mapTable {
             let list = clockDataList222!
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
//                            image2.size.width * 0.5 topCapHeight: image2.size.width * 0.8
//                            let a : CGFloat = 0.5
                            cell1.img.image = img2.stretchableImageWithLeftCapWidth(20, topCapHeight: Int(img2.size.width*0.4))
                        }
                    
                        if item.ClockOut == "-1" {
                            let date = NSDate()
                            //        print(date)
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "MM/dd/yy hh:mm a"
                            dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
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
//        if self.title == "April" || self.title == "april Lv" || self.title == "jack fan" || self.title == "Bob Xia" || self.title == "Apple"{
//            self.performSegueWithIdentifier("showLog", sender: nil)
//        }
    }

    
    func clockInTapped(tap : UIButton){
//        print("sfsdf \(tap.view?.superview?.tag)  \(tap.view?.layer.valueForKey("lng"))")
        showMap(true,tap: tap)
    }
    
    func clockOutTapped(tap : UIButton){
//         print("out sfsdf \(tap.view?.layer.valueForKey("lat"))  \(tap.view?.layer.valueForKey("lng"))")
        showMap(false,tap: tap)
    }
    
    private func showMap(isIn: Bool, tap : UIButton) {
        self.isIn = isIn
         let tag = tap.tag 
//            print("tag" + "\(tag)")
            let list = clockDataList!
            if let item : ScheduledDayItem = list[tag] {
                self.selectedItem = item
                self.performSegueWithIdentifier("showMapDetail", sender: nil)
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
        
        let lat = self.locationManager?.currentLocation?.coordinate.latitude ?? 0
        let lng = self.locationManager?.currentLocation?.coordinate.longitude ?? 0
        clockOutRequiredInfo.Latitude = "\(lat)"
        clockOutRequiredInfo.Longitude = "\(lng)"
        clockOutRequiredInfo.HostName = UIDevice.currentDevice().name
        let tl = Tool()
        clockOutRequiredInfo.IPAddress = tl.getWiFiAddress()
        let now = NSDate()
        clockOutRequiredInfo.ClientTime = tl.getClientTime(now)
        
        let OAuthToken = tl.getUserToken()
        clockOutRequiredInfo.Token = OAuthToken.Token!
//        clockOutRequiredInfo.Token = "asdfaasdf"
        clockOutRequiredInfo.TokenSecret = OAuthToken.TokenSecret!
        
//        print(clockOutRequiredInfo.getPropertieNamesAsDictionary())
        
      
//        self.view.userInteractionEnabled = false
       
        let userInfo = NSUserDefaults.standardUserDefaults()
        if let lastGoOutTime = userInfo.valueForKey(CConstants.LastGoOutTime) as? NSDate {
            let calendar = NSCalendar.currentCalendar()
            var components = calendar.components([.Day ], fromDate: lastGoOutTime)
            let lastGoOutTimeday = components.day
            
            components = calendar.components([.Day ], fromDate: NSDate())
            let todayday = components.day
//            if lastGoOutTimeday == todayday {
//                
//                if let lastComeBackTime = userInfo.valueForKey(CConstants.LastComeBackTime) as? NSDate {
//                    if lastComeBackTime.timeIntervalSinceDate(lastGoOutTime) < 0 {
//                        let msg = "In order to \(isClockIn ? "clock in" : "clock out"), you have to come back first."
//                        self.PopMsgWithJustOK(msg: msg, txtField: nil)
//                        self.view.userInteractionEnabled = true
//                        return
//                    }
//                    
//                    if now.timeIntervalSinceDate(lastComeBackTime) < 60  && !isClockIn{
//                        let msg = "You cannot clock out within come back 1 minute. Last come back @\(tl.getClockMsgFormatedTime(lastComeBackTime))"
//                        self.PopMsgWithJustOK(msg: msg, txtField: nil)
//                        self.view.userInteractionEnabled = true
//                        return
//                    }
//                    
//                }else{
//                    if let lastClockIn = userInfo.valueForKey(CConstants.LastClockInTime) as? NSDate{
//                        if NSDate().timeIntervalSinceDate(lastClockIn) < 60 * 60 * 12 {
//                            let msg = "In order to \(isClockIn ? "clock in" : "clock out"), you have to come back first."
//                            self.PopMsgWithJustOK(msg: msg, txtField: nil)
//                            self.view.userInteractionEnabled = true
//                            return
//                        }
//                    }
//                    
//                }
//            }
            
            
        }
        
        if isClockIn {
            if let lastClockOutTime = userInfo.valueForKey(CConstants.LastClockOutTime) as? NSDate {
                
                let calendar = NSCalendar.currentCalendar()
                var components = calendar.components([.Day ], fromDate: lastClockOutTime)
                let lastGoOutTimeday = components.day
                
                components = calendar.components([.Day ], fromDate: NSDate())
                let todayday = components.day
//                if lastGoOutTimeday == todayday {
//                    let now = NSDate()
//                    let h = now.timeIntervalSinceDate(lastClockOutTime)
//                    if h < 60 {
//                        let msg = "Please wait 1 minute to clock in. Last clock out @\(tl.getClockMsgFormatedTime(lastClockOutTime))"
//                        self.PopMsgWithJustOK(msg: msg, txtField: nil)
//                        self.view.userInteractionEnabled = true
//                        return
//                    }
//                    
//                    if let lastClockInTime = userInfo.valueForKey(CConstants.LastClockInTime) as? NSDate {
//                        if lastClockInTime.timeIntervalSinceDate(lastClockInTime) > 0 {
//                            let h = now.timeIntervalSinceDate(lastClockInTime)
//                            if h < 12 * 60 * 60 {
//                                let msg = "You cannot clock in without clocking out. Last clock in @\(tl.getClockMsgFormatedTime(lastClockInTime))"
//                                self.PopMsgWithJustOK(msg: msg, txtField: nil)
//                                self.view.userInteractionEnabled = true
//                                return
//                            }
//                        }
//                    }
//                }
                
                
            }
            
        }else{
//            if let lastClockInTime = userInfo.valueForKey(CConstants.LastClockInTime) as? NSDate {
//                if let lastClockOutTime = userInfo.valueForKey(CConstants.LastClockOutTime) as? NSDate {
//                    let h = lastClockInTime.timeIntervalSinceDate(lastClockOutTime)
//                    if h < 0 {
//                        let msg = "In order to clock out, you have to clock in first."
//                        self.PopMsgWithJustOK(msg: msg, txtField: nil)
//                        self.view.userInteractionEnabled = true
//                        return
//                    }
//                }
//                let now = NSDate()
//                let h = now.timeIntervalSinceDate(lastClockInTime)
//                if h < 60 && h > 0  {
//                    let msg = "You cannot clock out within clock in 1 minute. Last clock in @\(tl.getClockMsgFormatedTime(lastClockInTime))"
//                    self.PopMsgWithJustOK(msg: msg, txtField: nil)
//                    self.view.userInteractionEnabled = true
//                    return
//                }
//            }else{
//                let msg = "In order to clock out, you have to clock in first."
//                self.PopMsgWithJustOK(msg: msg, txtField: nil)
//                self.view.userInteractionEnabled = true
//                return
//            }
            
        }
        
        
        
//        tl.saveClockDataToLocalDB(isClockIn: isClockIn, clockOutRequiredInfo: clockOutRequiredInfo)
        self.view.userInteractionEnabled = true
        
        
        
        let net = NetworkReachabilityManager()
        if net?.isReachable ?? false {
            
//            let submitData = cl_submitData()
//            submitData.resubmit(nil)
//            
//            let userInfo = NSUserDefaults.standardUserDefaults()
//            userInfo.setValue(NSDate(), forKey: (isClockIn ? CConstants.LastClockInTime : CConstants.LastClockOutTime))
            
            currentRequest = Alamofire.request(.POST, CConstants.ServerURL + (isClockIn ? CConstants.ClockInServiceURL: CConstants.ClockOutServiceURL), parameters: clockOutRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                if response.result.isSuccess {
                    //                print(response.result.value)
                    if let rtnValue = response.result.value as? [String: AnyObject]{
                        let rtn = ClockResponse(dicInfo: rtnValue)
                        if Int(rtn.Status!) <= 0 {
                            if rtn.Message != "" {
                                var msg = rtn.Message
                                if (rtn.Message ?? "").containsString("within clock in 1") {
                                    msg = msg?.stringByReplacingOccurrencesOfString("clock in", withString: "clock in or come back")
                                }
                                self.PopMsgWithJustOK(msg: msg ?? "") {
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
                                userInfo.setValue(NSDate(), forKey: CConstants.LastClockInTime)
                            }else{
                                userInfo.setValue(NSDate(), forKey: CConstants.LastClockOutTime)
                            }
                            self.callGetList()
//                            if isClockIn {
//                                
//                                let item = ScheduledDayItem(dicInfo: nil)
//                                item.ClockIn = rtn.ClockedInTime
//                                item.ClockInCoordinate = rtn.Coordinate
//                                item.ClockOut = ""
//                                item.ClockInDay = rtn.Day
//                                item.ClockInDayFullName = rtn.DayFullName
//                                item.ClockInDayOfWeek = rtn.DayOfWeek
//                                //                                    item.Hours = rtn
//                                item.ClockInDayName = rtn.DayName
//                                self.clockDataList!.append(item)
//                                
//                                self.mapTable.reloadData()
//                                self.scrollToBottom()
//                                
//                            }else{
//                                if let item = self.clockDataList?[self.clockDataList!.count-1] {
//                                    
//                                    item.ClockOut = rtn.ClockedOutTime
//                                    item.ClockOutCoordinate = rtn.Coordinate
//                                    
//                                    item.ClockOutDay = rtn.Day
//                                    item.ClockOutDayFullName = rtn.DayFullName
//                                    item.ClockOutDayOfWeek = rtn.DayOfWeek
//                                    item.ClockOutDayName = rtn.DayName
//                                    
//                                    self.mapTable.reloadData()
//                                    self.scrollToBottom()
//                                }
//                            }
                        }
                    }else{
//                        tl.saveClockDataToLocalDB(isClockIn: isClockIn, clockOutRequiredInfo: clockOutRequiredInfo)
                        
                        self.PopServerError()
                        
                    }
                    self.view.userInteractionEnabled = true
                    
                }else{
//                    tl.saveClockDataToLocalDB(isClockIn: isClockIn, clockOutRequiredInfo: clockOutRequiredInfo)
                      self.PopNetworkError()
                    self.view.userInteractionEnabled = true
                }
            }
        }else{
             self.PopNetworkError()
            userInfo.setValue(NSDate(), forKey: CConstants.LastClockOutTime)
            tl.saveClockDataToLocalDB(isClockIn: isClockIn, clockOutRequiredInfo: clockOutRequiredInfo)
            self.view.userInteractionEnabled = true
        }
        
        
        
        
    }
    
    
     func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem){
//        let (isTime, timespace) = Tool().getTimeInter()
//        
//        if !isTime {
//            self.PopMsgWithJustOK(msg: "You are being track at this time.", action1: <#T##(action: UIAlertAction) -> Void#>)
//            return;
//        }

        tabBar.selectedItem = nil
        switch item.title! {
        case "Clock In":
            doClockIn()
        case "Clock Out":
            doClockOut()
        case "Come Back":
            doComeBack()
        default:
            gotoOutPage = true
            self.performSegueWithIdentifier(constants.SegueToMoreController, sender: nil)
        }
    }
    
    var gotoOutPage = false
    
    private func doComeBack(){
        let clockOutRequiredInfo = ClockOutRequired()
//        let lat = self.locationManager?.currentLocation?.coordinate.latitude ?? 0
//        let lng = self.locationManager?.currentLocation?.coordinate.longitude ?? 0
        clockOutRequiredInfo.Latitude = "\(self.locationManager?.currentLocation?.coordinate.latitude ?? 0)"
        clockOutRequiredInfo.Longitude = "\(self.locationManager?.currentLocation?.coordinate.longitude ?? 0)"
        clockOutRequiredInfo.HostName = UIDevice.currentDevice().name
        let tl = Tool()
        clockOutRequiredInfo.IPAddress = tl.getWiFiAddress()
        
        let OAuthToken = tl.getUserToken()
        clockOutRequiredInfo.Token = OAuthToken.Token!
        clockOutRequiredInfo.TokenSecret = OAuthToken.TokenSecret!
        let now = NSDate()
        clockOutRequiredInfo.ClientTime = tl.getClientTime(now)
        var param = clockOutRequiredInfo.getPropertieNamesAsDictionary()
        param["ActionType"] = "Come Back"
        //        print(clockOutRequiredInfo.getPropertieNamesAsDictionary())
        
        
        if let list = UIApplication.sharedApplication().scheduledLocalNotifications {
            for no in list {
                UIApplication.sharedApplication().cancelLocalNotification(no)
            }
        }
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        
            if let lastGoOut = userInfo.valueForKey(CConstants.LastGoOutTime) as? NSDate {
//                print("aaaa", userInfo.valueForKey(CConstants.LastGoOutTime))
                if let lastComeBack = userInfo.valueForKey(CConstants.LastComeBackTime) as? NSDate {
                    if lastComeBack.timeIntervalSinceDate(lastGoOut) > 0 {
                        let msg = "In order to come back, you have to go out first."
                        self.PopMsgWithJustOK(msg: msg, txtField: nil)
                        return
                    }
                }
            }else{
                let msg = "In order to come back, you have to go out first."
                self.PopMsgWithJustOK(msg: msg, txtField: nil)
                return
            }
        
        
        
//        let submitData = cl_submitData()
//        submitData.savedSubmitDataToDB(clockOutRequiredInfo.ClientTime ?? ""
//            , lat: self.locationManager?.currentLocation?.coordinate.latitude ?? 0.0
//            , lng: self.locationManager?.currentLocation?.coordinate.longitude ?? 0.0
//            , xtype: CConstants.ComeBackType)
//        
//        submitData.resubmit(nil)
//        
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
//         dateFormatter.timeZone = NSTimeZone.localTimeZone()
//        dateFormatter.locale = NSLocale(localeIdentifier : "en_US")
//        dateFormatter.dateFormat =  "hh:mm:ss a"
//        let nowHour = dateFormatter.stringFromDate(now)
//        dateFormatter.dateFormat = "EEE, MMM dd"
//        let nowDay = dateFormatter.stringFromDate(now)
//        dateFormatter.dateFormat = "EEEE"
//        let nowFullWeekName = dateFormatter.stringFromDate(now)
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        let nowFullDateName = dateFormatter.stringFromDate(now)
//        
//        //        let userInfo = NSUserDefaults.standardUserDefaults()
//        userInfo.setValue(NSDate(), forKey:  CConstants.LastComeBackTime)
//        
//       userInfo.setValue("", forKey: CConstants.LastGoOutTimeStartEnd)
//        
//            
//            let item = ScheduledDayItem(dicInfo: nil)
//            item.ClockInCoordinate = CoordinateObject(dicInfo: nil)
//            item.ClockIn = nowHour
//            item.ClockInCoordinate?.Latitude = lat
//            item.ClockInCoordinate?.Longitude = lng
//            item.ClockOut = ""
//        
//        item.ClockInName = "Come Back"
//            item.ClockInDay = nowDay
//            item.ClockInDayFullName = nowFullWeekName
//            item.clockInDateDay = nowFullDateName
//            //            item.ClockInDayOfWeek = rtn.DayOfWeek
//            //                                    item.Hours = rtn
//            item.ClockInDayName = nowDay.substringToIndex(nowDay.startIndex.advancedBy(2))
//            
//            let ss = cl_showSchedule()
//            ss.savedSubmitDataToDB(item)
//            
//            self.clockDataList!.append(item)
//            
//            self.mapTable.reloadData()
//            self.scrollToBottom()
//            
//       
//        return
        
        
        let net = NetworkReachabilityManager()
        if net?.isReachable ?? false {
            
//            let submitData = cl_submitData()
//            submitData.resubmit(nil)
            
            let userInfo = NSUserDefaults.standardUserDefaults()
            userInfo.setValue(NSDate(), forKey: CConstants.LastComeBackTime)
            userInfo.setValue("", forKey: CConstants.LastGoOutTimeStartEnd)
            
            var hud : MBProgressHUD?
            hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            hud!.labelText = CConstants.SavingMsg
            
            Alamofire.request(.POST, CConstants.ServerURL + "ComeBack.json", parameters: param).responseJSON{ (response) -> Void in
                hud?.hide(true)
                if response.result.isSuccess {
                    //                print(response.result.value)
                    UIApplication.sharedApplication().cancelAllLocalNotifications()
                    self.callGetList()
                }else{
//                    let cl = cl_submitData()
//                    cl.savedSubmitDataToDB(clockOutRequiredInfo.ClientTime ?? ""
//                        , lat: self.locationManager?.currentLocation?.coordinate.latitude ?? 0.0
//                        , lng: self.locationManager?.currentLocation?.coordinate.longitude ?? 0.0
//                        , xtype: CConstants.ComeBackType)
                                    self.PopNetworkError()
                    
                }
            }
        }else{
            
             self.PopNetworkError()
            
//            userInfo.setValue(NSDate(), forKey: CConstants.LastComeBackTime)
//            let cl = cl_submitData()
//            cl.savedSubmitDataToDB(clockOutRequiredInfo.ClientTime ?? ""
//                , lat: self.locationManager?.currentLocation?.coordinate.latitude ?? 0.0
//                , lng: self.locationManager?.currentLocation?.coordinate.longitude ?? 0.0
//                , xtype: CConstants.ComeBackType)
        }
        
    }

    
   
}


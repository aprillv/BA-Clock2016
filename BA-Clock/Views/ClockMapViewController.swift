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


class ClockMapViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var trackGPS: UIBarButtonItem!
    @IBAction func openTrackGPS(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "trackGps", sender: nil)
        
    }

//    @IBOutlet var hidmap: MKMapView!{
//        didSet{
////            hidmap.showsUserLocation = true
////            hidmap.delegate = self
//////            36.7047370224665 119.184943323601
////            hidmap.hidden = true
////          updateLocaiton0()
//            
//        }
//    }
//    
////    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
////        print0000(userLocation.coordinate.latitude,userLocation.coordinate.longitude, "ddd")
////       
////        
////    }
//    func updateLocaiton0 ()  {
//        hidmap.showsUserLocation = true
//        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(updateLocaiton), userInfo: nil, repeats: false)
//        NSTimer.scheduledTimerWithTimeInterval(302, target: self, selector: #selector(updateLocaiton0), userInfo: nil, repeats: false)
//    }
//    func updateLocaiton ()  {
//        
//        
//        let dateFormatter = NSDateFormatter()
//        
//        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"
//        let ClientTime = dateFormatter.stringFromDate(NSDate())
//        locationManager?.callSubmitLocationService(hidmap.userLocation.coordinate.latitude, longitude1: hidmap.userLocation.coordinate.longitude, time: ClientTime)
//        hidmap.showsUserLocation = false
//    }
    
    @IBOutlet var tabbar: UITabBar!{
        didSet{
            let userInfo = UserDefaults.standard
            if userInfo.integer(forKey: CConstants.ShowClockInAndOut) ?? 1 == 0 {
                tabbar.items?.removeFirst()
                tabbar.items?.removeFirst()
            }
            for item in tabbar.items! {
                item.image = item.image?.withRenderingMode(.alwaysOriginal)
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
    
    
    func refreshfirst(_ refreshControl: UIRefreshControl) {
        // Do your job, when done:
        firstTime = true
        self.callGetList()
    }
    
   
    @IBOutlet weak var map_listContstraint: NSLayoutConstraint!
   
    var locationUpdateTimer : Timer?
    var SyncTimer : Timer?
    var firstTime = false
    var currentRequest : Request?
    var clockDataList : [ScheduledDayItem]?{
        didSet{
//            if oldValue == nil {
//                lastDataCount = clockDataList?.count ?? 0
//            }
//            print0000(clockDataList)
//            self.mapTable?.reloadData()
//            self.textTable?.reloadData()
//            self.clockDataList222 = self.clockDataList?.filter({$0.})
//            var tmp  = [ScheduledDayItem]()
            
            
            if clockDataList != nil && clockDataList?.count > 0 {
//                scrollToBottom()
                self.updateLastSyncDateTime()
                
                
                var beginAdd = false
                let dateFormatter = DateFormatter()
                
                dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
                dateFormatter.locale = Locale(identifier: "en_US")
                
                
                if let logineddate = UserDefaults.standard.value(forKey: CConstants.LoginedDate) as? Date {
                    
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    let today = dateFormatter.string(from: logineddate)
                    
                    
                    let todayday = dateFormatter.date(from: today)
                    
                    dateFormatter.dateFormat = "MM/dd/yyyyhh:mm:ss a"
                    
                    
                   var tmp  = [ScheduledDayItem]()
                    for h in clockDataList! {
                        let h0 = h
                        if !beginAdd {
//                            print0000((h.clockInDateDay ?? "") + (h.ClockIn ?? ""))
//                            if (h.clockOutDateDay ?? "00").contains("1900") {
//                                h0.ClockInName = ""
//                                beginAdd = true
//                            }else{
//                            print0000((h.clockOutDateDay ?? "") + (h.ClockOut ?? ""),
//                                  dateFormatter.dateFromString((h.clockOutDateDay ?? "") + (h.ClockOut ?? "")),
//                                  today)
                                if let dates = dateFormatter.date(from: (h.clockInDateDay ?? "") + (h.ClockIn ?? "")) {
                                    if dates.timeIntervalSince(todayday!) > 0 {
                                        beginAdd = true
                                    }
                                }
                            
                            if !beginAdd{
                                if let dates2 = dateFormatter.date(from: (h.clockOutDateDay ?? "") + (h.ClockOut ?? "")) {
//                                    print0000(todayday)
                                    if dates2.timeIntervalSince(todayday!) > 0 {
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
            //            print0000(clockDataList)
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
    
    fileprivate struct constants{
        static let CellIdentifier : String = "clockMapCell"
        static let CellTextIdentifier : String = "clockTextCell"
        static let CellIdentifierTrack : String = "trackTableCell"
        
        static let UserInfoScheduledFrom : String = "ScheduledFrom"
        static let UserInfoScheduledTo : String = "ScheduledTo"
        
        static let RightTopItemTitleMap : String = "List"
        static let RightTopItemTitleText : String = "GIS Track"
        
        static let SegueToMoreController = "More"
        
    }
    
    
   
    
    fileprivate func scrollToBottom(){
//        print0000(mapTable?.contentSize.height)
        if (mapTable?.contentSize.height ?? 10) - (mapTable?.frame.size.height ?? 10) > 10 {
            mapTable.setContentOffset(CGPoint(x: 0, y: (mapTable?.contentSize.height ?? 0) - (mapTable?.frame.size.height ?? 0)), animated: true)
            
        }
    }
    
    
//    func stopMapLoaction() {
//        self.hidmap.showsUserLocation = false
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        let userInfo = UserDefaults.standard
//        print(userInfo.string(forKey: CConstants.UserInfoIdDeptos) ?? "0")
        if (userInfo.string(forKey: CConstants.UserInfoIdDeptos) ?? "0") == "1" {
           self.navigationItem.leftBarButtonItem = trackGPS;
        }else{
            self.navigationItem.leftBarButtonItems = nil
        }
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(stopMapLoaction), name:CConstants.AppTerminal, object: nil)
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
    
  
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
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
                if let index = list.index(of: item) {
                    self.clockDataList!.remove(at: index)
                }
               
            }
            
        }
        
    }
    
    func checkUpate2(){
        let version = Bundle.main.infoDictionary?["CFBundleVersion"]
        let parameter = ["version": (version == nil ?  "" : version!), "appid": "iphone_ClockIn"]
        
        Alamofire.request(
            CConstants.ServerVersionURL + CConstants.CheckUpdateServiceURL, method:.post,
            parameters: parameter).responseJSON{ (response) -> Void in
                if response.result.isSuccess {
                    
                    if let rtnValue = response.result.value{
                        
                        if (rtnValue as? NSNumber ?? 0).intValue == 1 {
                            
                        }else{
                            if let url = URL(string: CConstants.InstallAppLink){
                                
                                UIApplication.shared.openURL(url)
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
//        print0000("for test ", self.navigationController?.viewControllers.count)
        checkUpate2()
        
        locationManager = CLocationManager.sharedInstance
        locationManager?.startUpdatingLocation()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255.0, green: 72/255.0, blue: 116/255.0, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
//        if self.clockDataList == nil {
        firstTime = true
        Tool.saveDeviceTokenToSever()
        let tl = Tool()
        tl.syncFrequency()
        
        
        let userInfo = UserDefaults.standard
//        userInfo.setValue(NSDate(), forKey: CConstants.LoginedDate)
        view.bringSubview(toFront: mapTable)
        title = userInfo.value(forKey: CConstants.UserFullName) as? String
        self.callGetList()
    }
    
    func updateLastSyncDateTime() {
        if self.clockDataList?.count ?? 0 == 0 {
        self.updateLastSyncDateTime0()
        }else{
        let tl = Tool()
        let userInfo = UserDefaults.standard
    
        if let h = self.clockDataList?.filter({$0.ClockInName == "Clock In"}).last {
//             print0000("a", i++)
            let lastClockIn = "\(h.clockInDateDay!) \(h.ClockIn!)"
            let ld = tl.getDateFromString(lastClockIn)
            userInfo.setValue(ld, forKey: CConstants.LastClockInTime)
           
        }
        if let h = self.clockDataList?.filter({$0.ClockOutName == "Clock Out" && $0.ClockOut != ""}).last {
            
                let lastClockOut = "\(h.clockOutDateDay!) \(h.ClockOut!)"
                let ld = tl.getDateFromString(lastClockOut)
                userInfo.setValue(ld, forKey: CConstants.LastClockOutTime)
//            print0000("b")
            //                print0000(h.ClockIn, h.ClockInDay, h.ClockOutDayFullName)
        }
    
        if let h = self.clockDataList?.filter({$0.ClockInName == "Come Back"}).last {
            let lastClockIn = "\(h.clockInDateDay!) \(h.ClockIn!)"
            let ld = tl.getDateFromString(lastClockIn)
            userInfo.setValue(ld, forKey: CConstants.LastComeBackTime)
//            print0000("c")
        }
    
        if let h = self.clockDataList?.filter({
            $0.ClockOutName != "Clock Out"
                && $0.ClockOut != ""
                && $0.ClockIn != "-1"}).last {
//            print0000(h.ClockOutName)
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
            
//            print0000("d")
            //                print0000(h.ClockIn, h.ClockInDay, h.ClockOutDayFullName)
        }
        }
    }
    func updateLastSyncDateTime0() {
//        let tl = Tool()
        let userInfo = UserDefaults.standard
        userInfo.removeObject(forKey: CConstants.LastClockInTime)
        userInfo.removeObject(forKey: CConstants.LastClockOutTime)
        userInfo.removeObject(forKey: CConstants.LastComeBackTime)
        userInfo.removeObject(forKey: CConstants.LastGoOutTime)
        
    }
   
    
    
    
    
    fileprivate func callGetList(){
//        print0000("+++++++++++++")
        let userInfo = UserDefaults.standard
        if let token = userInfo.object(forKey: CConstants.UserInfoTokenKey) as? String,
            let tokenSecret = userInfo.object(forKey: CConstants.UserInfoTokenScretKey) as? String,
            let email = userInfo.value(forKey: CConstants.UserInfoEmail) as? String,
            let pwd = userInfo.value(forKey: CConstants.UserInfoPwd) as? String{
                let tl = Tool()
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Email = email
                loginRequiredInfo.Password = tl.md5(string: pwd)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
                let now = Date()
                loginRequiredInfo.ClientTime = tl.getClientTime(now)
//                self.firstrefreshControl?.beginRefreshing()
                var hud : MBProgressHUD?
                if self.clockDataList == nil {
//                    self.noticeOnlyText(CConstants.LoadingMsg)
                    hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                    hud!.labelText = CConstants.LoadingMsg
                    hud?.isUserInteractionEnabled = false
                }
            
            let param = [
                "Token": loginRequiredInfo.Token ?? ""
                , "TokenSecret": loginRequiredInfo.TokenSecret ?? ""
                , "ClientTime": loginRequiredInfo.ClientTime ?? ""
                , "Email": loginRequiredInfo.Email ?? ""
                , "Password": loginRequiredInfo.Password ?? ""]
            
            
//                userInfo.setObject(email, forKey: CConstants.UserInfoEmail)
//                userInfo.setObject(password, forKey: CConstants.UserInfoPwd)
//                
//                print0000(loginRequiredInfo.getPropertieNamesAsDictionary())
                currentRequest = Alamofire.request( CConstants.ServerURL + CConstants.GetScheduledDataURL, method:.post, parameters: param).responseJSON{ (response) -> Void in
                    self.firstrefreshControl?.endRefreshing()
                     hud?.isUserInteractionEnabled = true
                    if self.clockDataList == nil {
                        hud!.hide(true)
                    }
//                    print(response.result)
                    if response.result.isSuccess {
//                        print(response.result.value)
                        if let rtnValue = response.result.value as? [String: AnyObject]{
                            
                            if rtnValue["Status"]!.integerValue == 1 {
//                                print0000(rtnValue["ClockYN"])
                                if let a = rtnValue["ClockYN"] as? Bool {
//                                    print0000(a)
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
//                                        print(item);
                                        let info = ScheduledDayItem(dicInfo: item)
                                        tmpaaaa.append(info)
                                        ss.savedSubmitDataToDB(info)
                                    }
                                    self.clockDataList = tmpaaaa
//                                    self.updateLastSyncDateTime()
                                }
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
                                            self.clockDataList!.append(ScheduledDayItem(dicInfo: ["ClockIn" : "-1" as AnyObject, "ClockOut":"-1" as AnyObject]))
                                            if timespace > 0 {
                                                
                                            }
                                        }
                                    }
                                    
//                                }
                            }else{
                                self.PopMsgWithJustOK(msg: rtnValue["Message"] as! String) {
                                    [weak self](action : UIAlertAction) -> Void in
                                    CLocationManager.sharedInstance.stopUpdatingLocation()
                                    self?.popToRootLogin()
                                }
                            }
                            
                        }else{
                            self.PopServerError()
                        }
                    }else{
                        self.PopNetworkError()
                    }
                    
                }
        }else{
            self.PopMsgWithJustOK(msg: "Token invalid, please re-login with your username and password.") {
                [weak self](action : UIAlertAction) -> Void in
                CLocationManager.sharedInstance.stopUpdatingLocation()
                self?.popToRootLogin()
            }
        }
        
        
    }
    
//    deinit {
//        print("remove from heap")
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == mapTable {
            return clockDataList222?.count ?? 0
        }else{
            return clockDataList222?.count ?? 0
        }
        
    }
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
        
        if tableView == mapTable {
             let list = clockDataList222!
            if let item : ScheduledDayItem = list[indexPath.row] {
                if item.ClockIn != "-1" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: constants.CellIdentifier, for: indexPath)
                    if let cellitem = cell as? ClockMapCell {
                        cellitem.superActionView = self
                        cellitem.clockInfo = item
                        
                        cell.contentView.tag = indexPath.row
                    }
                    return cell
                }else{
//                    UIImage(named: "clockin.png")?.stretchableImageWithLeftCapWidth(20, topCapHeight: 26)
                    let cell = tableView.dequeueReusableCell(withIdentifier: constants.CellTextIdentifier, for: indexPath)
                    if let cell1 = cell as? TextTableViewCell{
                        if let img2 = UIImage(named: "clockin3"){
//                            image2.size.width * 0.5 topCapHeight: image2.size.width * 0.8
//                            let a : CGFloat = 0.5
                            cell1.img.image = img2.stretchableImage(withLeftCapWidth: 20, topCapHeight: Int(img2.size.width*0.4))
                        }
                    
                        if item.ClockOut == "-1" {
                            let date = Date()
                            //        print0000(date)
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM/dd/yy hh:mm a"
                            dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
                            dateFormatter.locale = Locale(identifier: "en_US")
                            cell1.lbl?.text = "You are not being track at \(dateFormatter.string(from: date))."
//                            cell1.lbl.textColor = UIColor.whiteColor()
                        }else{
                            cell1.lbl?.text = "You are being track at this time."
                        }
                        
                    }
                    
                    return cell
                }
            }
            
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: constants.CellIdentifierTrack, for: indexPath)
            let item = self.trackDotList![indexPath.row]
            cell.textLabel?.text = item.Tag
            return cell
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == mapTable{
//            print0000(firstTime)
            if(firstTime && indexPath.row == tableView.indexPathsForVisibleRows?.last?.row){
                firstTime = false
                self.scrollToBottom()
            }
        }
        
    }
    
    @IBAction func gotoLog(_ sender: AnyObject) {
//        if self.title == "April" || self.title == "april Lv" || self.title == "jack fan" || self.title == "Bob Xia" || self.title == "Apple"{
//            self.performSegueWithIdentifier("showLog", sender: nil)
//        }
    }

    
    func clockInTapped(_ tap : UIButton){
//        print0000("sfsdf \(tap.view?.superview?.tag)  \(tap.view?.layer.valueForKey("lng"))")
        showMap(true,tap: tap)
    }
    
    func clockOutTapped(_ tap : UIButton){
//         print0000("out sfsdf \(tap.view?.layer.valueForKey("lat"))  \(tap.view?.layer.valueForKey("lng"))")
        showMap(false,tap: tap)
    }
    
    fileprivate func showMap(_ isIn: Bool, tap : UIButton) {
        self.isIn = isIn
         let tag = tap.tag 
//            print0000("tag" + "\(tag)")
            let list = clockDataList!
            if let item : ScheduledDayItem = list[tag] {
                self.selectedItem = item
                self.performSegue(withIdentifier: "showMapDetail", sender: nil)
            }
        
    
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
    
    
    
    
    
    
    
    fileprivate var lastCallSubmitLocationService : Date?
       
   
    
    fileprivate func callClockService(isClockIn: Bool){
        currentRequest?.cancel()
//        print0000(CConstants.ServerURL + (isClockIn ? CConstants.ClockInServiceURL: CConstants.ClockOutServiceURL))
//        let userInfo = UserDefaults.standard
        let clockOutRequiredInfo = ClockOutRequired()
        
        let lat = self.locationManager?.currentLocation?.coordinate.latitude ?? 0
        let lng = self.locationManager?.currentLocation?.coordinate.longitude ?? 0
        clockOutRequiredInfo.Latitude = "\(lat)"
        clockOutRequiredInfo.Longitude = "\(lng)"
        clockOutRequiredInfo.HostName = UIDevice.current.name
        let tl = Tool()
        clockOutRequiredInfo.IPAddress = tl.getWiFiAddress()
        let now = Date()
        clockOutRequiredInfo.ClientTime = tl.getClientTime(now)
        
        let OAuthToken = tl.getUserToken()
        clockOutRequiredInfo.Token = OAuthToken.Token!
//        clockOutRequiredInfo.Token = "asdfaasdf"
        clockOutRequiredInfo.TokenSecret = OAuthToken.TokenSecret!
        
//        print0000(clockOutRequiredInfo.getPropertieNamesAsDictionary())
        
      
//        self.view.isUserInteractionEnabled = false
       
        let userInfo = UserDefaults.standard
        
        self.view.isUserInteractionEnabled = true
        
        
        
        let net = NetworkReachabilityManager()
        if net?.isReachable ?? false {
            
//            let submitData = cl_submitData()
//            submitData.resubmit(nil)
//            
//            let userInfo = UserDefaults.standard
//            userInfo.setValue(NSDate(), forKey: (isClockIn ? CConstants.LastClockInTime : CConstants.LastClockOutTime))
            
//            var Token : String?
//            var TokenSecret : String?
//            var IPAddress : String?
//            var ClientTime : String?
//            var HostName : String?
//            var Latitude : String?
//            var Longitude : String?
            
            var param = [
                "Token": clockOutRequiredInfo.Token ?? ""
                , "TokenSecret": clockOutRequiredInfo.TokenSecret ?? ""
                , "IPAddress": clockOutRequiredInfo.IPAddress ?? ""
                , "ClientTime": clockOutRequiredInfo.ClientTime ?? ""
                , "HostName": clockOutRequiredInfo.HostName ?? ""
                , "Latitude": clockOutRequiredInfo.Latitude ?? ""
                , "Longitude": clockOutRequiredInfo.Longitude ?? ""
                
            ]
            
            currentRequest = Alamofire.request(CConstants.ServerURL + (isClockIn ? CConstants.ClockInServiceURL: CConstants.ClockOutServiceURL), method:.post, parameters: param).responseJSON{ (response) -> Void in
                if response.result.isSuccess {
                    //                print0000(response.result.value)
                    if let rtnValue = response.result.value as? [String: AnyObject]{
                        let rtn = ClockResponse(dicInfo: rtnValue)
                        if Int(rtn.Status!) <= 0 {
                            if rtn.Message != "" {
                                var msg = rtn.Message
                                if (rtn.Message ?? "").contains("within clock in 1") {
                                     msg = msg?.replacingOccurrences(of: "clock in", with: "clock in or come back")
//                                    msg = msg?.stringByReplacingOccurrencesOfString("clock in", withString: "clock in or come back")
                                }
                                self.PopMsgWithJustOK(msg: msg ?? "") {
                                    [weak self] (action : UIAlertAction) -> Void in
                                    if rtn.Status == -4 {
                                        CLocationManager.sharedInstance.stopUpdatingLocation()
                                        self?.popToRootLogin()
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
                        }
                    }else{
//                        tl.saveClockDataToLocalDB(isClockIn: isClockIn, clockOutRequiredInfo: clockOutRequiredInfo)
                        
                        self.PopServerError()
                        
                    }
                    self.view.isUserInteractionEnabled = true
                    
                }else{
//                    tl.saveClockDataToLocalDB(isClockIn: isClockIn, clockOutRequiredInfo: clockOutRequiredInfo)
                      self.PopNetworkError()
                    self.view.isUserInteractionEnabled = true
                }
            }
        }else{
             self.PopNetworkError()
            userInfo.setValue(Date(), forKey: CConstants.LastClockOutTime)
            tl.saveClockDataToLocalDB(isClockIn: isClockIn, clockOutRequiredInfo: clockOutRequiredInfo)
            self.view.isUserInteractionEnabled = true
        }
        
        
        
        
    }
    
    
     func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
//        let (isTime, _) = Tool().getTimeInter()
//        
//        if !isTime {
//            tabBar.selectedItem = nil
//            self.PopMsgWithJustOK(msg: "You are being track at this time.", txtField: nil)
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
            self.performSegue(withIdentifier: constants.SegueToMoreController, sender: nil)
        }
    }
    
    var gotoOutPage = false
    
    fileprivate func doComeBack(){
        let clockOutRequiredInfo = ClockOutRequired()
//        let lat = self.locationManager?.currentLocation?.coordinate.latitude ?? 0
//        let lng = self.locationManager?.currentLocation?.coordinate.longitude ?? 0
        clockOutRequiredInfo.Latitude = "\(self.locationManager?.currentLocation?.coordinate.latitude ?? 0)"
        clockOutRequiredInfo.Longitude = "\(self.locationManager?.currentLocation?.coordinate.longitude ?? 0)"
        clockOutRequiredInfo.HostName = UIDevice.current.name
        let tl = Tool()
        clockOutRequiredInfo.IPAddress = tl.getWiFiAddress()
        
        let OAuthToken = tl.getUserToken()
        clockOutRequiredInfo.Token = OAuthToken.Token!
        clockOutRequiredInfo.TokenSecret = OAuthToken.TokenSecret!
        let now = Date()
        clockOutRequiredInfo.ClientTime = tl.getClientTime(now)
        
        var param = [
            "Token": clockOutRequiredInfo.Token ?? ""
            , "TokenSecret": clockOutRequiredInfo.TokenSecret ?? ""
            , "IPAddress": clockOutRequiredInfo.IPAddress ?? ""
            , "ClientTime": clockOutRequiredInfo.ClientTime ?? ""
            , "HostName": clockOutRequiredInfo.HostName ?? ""
            , "Latitude": clockOutRequiredInfo.Latitude ?? ""
            , "Longitude": clockOutRequiredInfo.Longitude ?? ""
            
        ]
        param["ActionType"] = "Come Back"
        //        print0000(clockOutRequiredInfo.getPropertieNamesAsDictionary())
        
        
        if let list = UIApplication.shared.scheduledLocalNotifications {
            for no in list {
                UIApplication.shared.cancelLocalNotification(no)
            }
        }
        UIApplication.shared.cancelAllLocalNotifications()
        
        
        
        let net = NetworkReachabilityManager()
        if net?.isReachable ?? false {
            
//            let submitData = cl_submitData()
//            submitData.resubmit(nil)
            
            let userInfo = UserDefaults.standard
            userInfo.setValue(Date(), forKey: CConstants.LastComeBackTime)
            userInfo.setValue("", forKey: CConstants.LastGoOutTimeStartEnd)
            
            var hud : MBProgressHUD?
            hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud!.labelText = CConstants.SavingMsg
            
            Alamofire.request(CConstants.ServerURL + "ComeBack.json", method:.post, parameters: param).responseJSON{ (response) -> Void in
                hud?.hide(true)
                if response.result.isSuccess {
                    //                print0000(response.result.value)
                    UIApplication.shared.cancelAllLocalNotifications()
                    self.callGetList()
                }else{
                    self.callGetList()
                    self.PopNetworkError()
                    
                }
            }
        }else{
             self.PopNetworkError()
        }
        
    }
    
   
}


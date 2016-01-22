//
//  ClockMapViewController.swift
//  BA-Clock
//
//  Created by April on 1/12/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class ClockMapViewController: BaseViewController {
   
    @IBOutlet weak var clockInSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var clockOutSpinner: UIActivityIndicatorView!
    
    var currentRequest : Request?
    
    lazy var progressBar: UIAlertController = {
        let alert = UIAlertController(title: nil, message: CConstants.LoadingMsg, preferredStyle: .Alert)
        alert.view.addSubview(self.spinner)
        return alert
    }()
    
    lazy var spinner : UIActivityIndicatorView = {
        let spinner1 = UIActivityIndicatorView(frame: CGRect(x: 30, y: 9, width: 40, height: 40))
        spinner1.hidesWhenStopped = true
        spinner1.activityIndicatorViewStyle = .Gray
        return spinner1
    }()
    var clockInfo : LoginedInfo?{
        didSet{
            if let _ = clockInfo{
                //            print(clockInfo?.getPropertieNamesAsDictionary())
                if let clockList = clockInfo!.ScheduledDay {
                    tableSource = [String : [ScheduledDayItem]]()
                    var day = ""
                    var index = 0
                    for item in clockList {
                        if day != item.Day! {
                            tableSource!["\(index)"] = [ScheduledDayItem]()
                            day = item.Day!
                            index++
                            
                        }
                        tableSource!["\(index-1)"]?.append(item)
                        
                    }
                    
                    mapTable?.reloadData()
                    textTable?.reloadData()
                    
                   
                    scrollToBottom()
                    CurrentScheduledInterval = clockInfo!.CurrentScheduledInterval!.doubleValue * 60.0
                    
                }
            }
        }
    }
    
    private func scrollToBottom(){
        if (mapTable?.contentSize.height ?? 10) - (mapTable?.frame.size.height ?? 10) > 10 {
            mapTable?.contentOffset = CGPoint(x: 0, y: (mapTable?.contentSize.height ?? 0) - (mapTable?.frame.size.height ?? 0))
            textTable?.contentOffset = CGPoint(x: 0, y: (textTable?.contentSize.height ?? 0) - (textTable?.frame.size.height ?? 0))
        }
    }
    var CurrentScheduledInterval : Double?
    var tableSource : [String : [ScheduledDayItem]]?
    
    var latitude: NSNumber?
    var longitude: NSNumber?
    
    var timer: NSTimer?
    var timeIntervalClockIn : Double?
    
    @IBAction func switchTo(sender: UIBarButtonItem) {
        switch sender.title!{
        case "Text":
            sender.title = "Map"
            UIView.transitionFromView(mapTable, toView: textTable, duration: 1, options: [.TransitionFlipFromRight, .ShowHideTransitionViews], completion: { (_) -> Void in
                
                self.view.bringSubviewToFront(self.textTable)
            })
            
            
            break
        default:
            sender.title = "Text"
            UIView.transitionFromView(textTable, toView: mapTable, duration: 1, options: [.TransitionFlipFromLeft, .ShowHideTransitionViews], completion: { (_) -> Void in
                self.view.bringSubviewToFront(self.mapTable)
            })
            
            
            break
        }
    }
    
    @IBOutlet weak var switchItem: UIBarButtonItem!
    @IBOutlet weak var mapTable: UITableView!
    @IBOutlet weak var textTable: UITableView!
    
    @IBOutlet weak var clockInBtn: UIButton!{
        didSet{
            clockInBtn.layer.cornerRadius = 5.0
//            self.clockInBtn.enabled = false
//            self.clockInBtn.backgroundColor = UIColor.lightGrayColor()
        }
    }
    @IBOutlet weak var clockOutBtn: UIButton!{
        didSet{
            clockOutBtn.layer.cornerRadius = 5.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(self.clockInfo)
        checkUpate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255.0, green: 72/255.0, blue: 116/255.0, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        if self.clockInfo == nil {
            self.callGetList()
        }else{
            scrollToBottom()
        }
        if self.locationManager == nil{
            locationManager = CLLocationManager()
            locationManager?.delegate = self;
        }
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        view.bringSubviewToFront(mapTable)
        title = userInfo.valueForKey(CConstants.UserFullName) as? String
        
    }
    
    private func checkUpate(){
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
        //     NSString*   version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    }
    
    
    private func callGetList(){
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        if let pwd = userInfo.objectForKey(CConstants.UserInfoPwd) as? String{
            if let email = userInfo.objectForKey(CConstants.UserInfoEmail) as? String {
                
                
                self.presentViewController(self.progressBar, animated: true, completion: nil)
                self.spinner.startAnimating()
                
                let tl = Tool()
                
                let loginRequiredInfo : ClockInRequired = ClockInRequired()
                loginRequiredInfo.Email = email
                loginRequiredInfo.Password = tl.md5(string: pwd)
//                print(loginRequiredInfo.getPropertieNamesAsDictionary())
//                ["Latitude": "", "IPAddress": "", "Email": "roberto@buildersaccess.com", "Password": "a51831554f195cbd2cd91ad3ea738c89", "HostName": "", "Longitude": ""]
//                print(loginRequiredInfo.getPropertieNamesAsDictionary())
                currentRequest = Alamofire.request(.POST, CConstants.ServerURL + CConstants.LoginServiceURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                    if response.result.isSuccess {
                                                print(response.result.value)
                        if let rtnValue = response.result.value as? [String: AnyObject]{
                            self.clockInfo = LoginedInfo(dicInfo: rtnValue)
                            
                            let hasclocked = userInfo.valueForKey(constants.UserInfoClockedKey) as? String
                            if hasclocked != nil && hasclocked == "1" {
                                self.update1()
                            }else{
                                self.timeIntervalClockIn = 0
//                                print("==================4")
                                self.locationManager?.startUpdatingLocation()
                            }
                            
                        }else{
                            
                        }
                    }else{
                        
                        self.PopNetworkError()
                    }
                    self.performSelector("dismissProgress", withObject: nil, afterDelay: 0.5)
                }
            }
        }
        
        
    }
    
    func dismissProgress(){
        self.progressBar.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func callAutoUpdate(){
        let time = getTime()
        if time > 0 {
            self.performSelector("update1", withObject: nil, afterDelay: time)
        }else{
            update1()
        }
    }
    
    private func update1(){
        SubmitLocation()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(CurrentScheduledInterval ?? 900, target: self, selector: "SubmitLocation", userInfo: nil, repeats: true)
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
    
    private struct constants{
        static let CellIdentifier : String = "clockMapCell"
        static let CellIdentifierText : String = "clockItemCell"
        static let UserInfoClockedKey : String = "ClockedIn"
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableSource?.count ?? 0
    }

//    func table
    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
//        return 35
//    }
//    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
//        if let list = tableSource?["\(section)"]{
//            let lbl = UILabel(frame: CGRect(x: 0, y: 20, width: tableView.frame.size.width, height: 15))
//            lbl.text = list.first!.DayFullName! + ", " + list.first!.Day!
//            lbl.textAlignment = NSTextAlignment.Center
//            lbl.font = UIFont(name: "Helvetica Neue", size: 14)
//            lbl.backgroundColor = UIColor.whiteColor()
//            return lbl
//        }else{
//            return nil
//        }
//    
//    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSource?["\(section)"]?.count ?? 0
    }
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let list = tableSource?["\(indexPath.section)"]!
        
        if tableView == mapTable {
            let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifier, forIndexPath: indexPath)
            if let cellitem = cell as? ClockMapCell {
                if let item : ScheduledDayItem = list?[indexPath.row] {
                    cellitem.clockInfo = item
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifierText, forIndexPath: indexPath)
            if let cellitem = cell as? ClockTextCell {
                if let item : ScheduledDayItem = list?[indexPath.row] {
                    cellitem.clockInfo = item
                }
            }
            return cell
        }
    }
    @IBAction func doClockIn(sender: UIButton) {
        clockIn()
    }
    @IBAction func doClockOut(sender: UIButton) {
        self.timeIntervalClockIn = -1
        
       self.locationManager?.stopUpdatingLocation()
        self.locationManager?.startUpdatingLocation()
//        print("==================5")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            
        }else{
            self.latitude = 0
            self.longitude = 0
            self.PopMsgWithJustOK(msg: CConstants.TurnOnLocationServiceMsg, txtField: nil)
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        print(locations)
        let userLocation = locations.last
        if userLocation?.horizontalAccuracy < 0 {
            return
        }
        if userLocation?.timestamp.timeIntervalSinceNow < 30 {
            self.latitude = userLocation?.coordinate.latitude
            self.longitude = userLocation?.coordinate.longitude
            locationManager?.stopUpdatingLocation()
            
            if self.timeIntervalClockIn > 0 {
//                print("+++++++++++++++++++++++++")
                callSubmitLocationService()
                
            }else if self.timeIntervalClockIn == -1{
                self.timeIntervalClockIn = 15
                callClockService(isClockIn: false)
            }else if self.timeIntervalClockIn == -2{
                self.timeIntervalClockIn = 0
                callClockService(isClockIn: true)
                
                
            }
            
        }
        
        
    }
    
    
    
    func clockIn(){
        self.timeIntervalClockIn = -2
//        print("==================1")
        locationManager?.startUpdatingLocation()
    }
    
    func SubmitLocation(){
        self.timeIntervalClockIn = 15
//        print("==================2")
        locationManager?.startUpdatingLocation()
    }
    
    private var lastCallSubmitLocationService : NSDate?
    private func callSubmitLocationService(){
        print(currentRequest?.request?.URLString)
        
        var cando = currentRequest?.task.state != .Running
        if !cando {
            if let url = currentRequest?.request?.URLString {
                if url == CConstants.ServerURL + CConstants.SubmitLocationServiceURL {
                    if NSDate().timeIntervalSinceDate(lastCallSubmitLocationService!) >= self.CurrentScheduledInterval ?? 900 {
                        currentRequest?.cancel()
                        cando = true
                    }
                }
            }

        }
        if cando {
//            print("###################")
            lastCallSubmitLocationService = NSDate()
            let submitRequired = SubmitLocationRequired()
            submitRequired.Latitude = "\(self.latitude!)"
            submitRequired.Longitude = "\(self.longitude!)"
            submitRequired.Token = self.clockInfo?.OAuthToken?.Token
            submitRequired.TokenSecret = self.clockInfo?.OAuthToken?.TokenSecret
//            print(submitRequired.getPropertieNamesAsDictionary())
            currentRequest = Alamofire.request(.POST, CConstants.ServerURL + CConstants.SubmitLocationServiceURL, parameters: submitRequired.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                print(response.result.value)
                if response.result.isSuccess {
                    //                print("submit location information")
                    //                print(response.result.value)
                }else{
                }
            }
            
        }
        
        
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
        print(CConstants.ServerURL + (isClockIn ? CConstants.ClockInServiceURL: CConstants.ClockOutServiceURL))
//        let userInfo = NSUserDefaults.standardUserDefaults()
        let clockOutRequiredInfo = ClockOutRequired()
        clockOutRequiredInfo.Latitude = "\(self.latitude!)"
        clockOutRequiredInfo.Longitude = "\(self.longitude!)"
        clockOutRequiredInfo.HostName = UIDevice.currentDevice().name
        let tl = Tool()
        clockOutRequiredInfo.IPAddress = tl.getWiFiAddress()
        clockOutRequiredInfo.Token = self.clockInfo?.OAuthToken?.Token
        clockOutRequiredInfo.TokenSecret = self.clockInfo?.OAuthToken?.TokenSecret
        
//        print(clockOutRequiredInfo.getPropertieNamesAsDictionary())
        
        self.timeIntervalClockIn = 0
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
                            self.PopMsgWithJustOK(msg: rtn.Message!, txtField: nil)
                        }
                        if isClockIn {
                            self.timeIntervalClockIn = 0
                        }else {
                            self.timeIntervalClockIn = 15
                        }
                       
                    }else{
                        if isClockIn {
                            if let last = self.tableSource!["\(self.tableSource!.count-1)"] {
                                let item = ScheduledDayItem(dicInfo: nil)
                                item.ClockIn = rtn.ClockedInTime
                                item.ClockInCoordinate = rtn.Coordinate
                                item.ClockOut = ""
                                item.Day = rtn.Day
                                item.DayFullName = rtn.DayFullName
                                item.DayOfWeek = rtn.DayOfWeek
                                //                                    item.Hours = rtn
                                item.DayName = rtn.DayName
                                
                                if last.first!.Day! != rtn.Day! {
                                    self.tableSource!["\(self.tableSource!.count)"] = [ScheduledDayItem]()
                                }
                                self.tableSource!["\(self.tableSource!.count-1)"]?.append(item)
                                self.mapTable.reloadData()
                                self.textTable.reloadData()
                                self.scrollToBottom()
                            }
                            
                            
                            
                            self.update1()
                            
                        }else{
                            if let last = self.tableSource!["\(self.tableSource!.count-1)"] {
                                if last.first!.Day! == rtn.Day! {
                                    if let item = last.last {
                                        item.ClockOut = rtn.ClockedOutTime
                                        item.ClockOutCoordinate = rtn.Coordinate
                                        self.mapTable.reloadData()
                                        self.textTable.reloadData()
                                        self.scrollToBottom()
                                    }
                                }
                            }
                            self.timer?.invalidate()
                            self.timer = nil
                        }
                        
                        let userInfo = NSUserDefaults.standardUserDefaults()
                        userInfo.setValue(isClockIn ? "1":"0", forKey: constants.UserInfoClockedKey)
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
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.latitude = 0
        self.longitude = 0
        locationManager?.stopUpdatingLocation()
        locationManager?.startUpdatingLocation()
//        print("==================3")
    }
    
}

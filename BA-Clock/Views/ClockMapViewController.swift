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
    var clockInfo : LoginedInfo?{
        didSet{
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
                
                mapTable?.contentOffset = CGPoint(x: 0, y: (mapTable?.contentSize.height ?? 0) - (mapTable?.frame.size.height ?? 0))
                textTable?.contentOffset = CGPoint(x: 0, y: (textTable?.contentSize.height ?? 0) - (textTable?.frame.size.height ?? 0))
            }
            
        }
    }
    
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
        if self.clockInfo == nil {
            self.callGetList()
        }
        if self.locationManager == nil{
            locationManager = CLLocationManager()
            locationManager?.delegate = self;
        }
        self.timeIntervalClockIn = 0
        self.locationManager?.startUpdatingLocation()
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        view.bringSubviewToFront(mapTable)
        title = userInfo.valueForKey(CConstants.UserFullName) as? String
        
    }
    
    private func callGetList(){
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        if let pwd = userInfo.objectForKey(CConstants.UserInfoPwd) as? String{
            if let email = userInfo.objectForKey(CConstants.UserInfoEmail) as? String {
                let tl = Tool()
                
                let loginRequiredInfo : ClockInRequired = ClockInRequired()
                loginRequiredInfo.Email = email
                loginRequiredInfo.Password = tl.md5(string: pwd)
//                print(loginRequiredInfo.getPropertieNamesAsDictionary())
//                ["Latitude": "", "IPAddress": "", "Email": "roberto@buildersaccess.com", "Password": "a51831554f195cbd2cd91ad3ea738c89", "HostName": "", "Longitude": ""]
//                print(loginRequiredInfo.getPropertieNamesAsDictionary())
                Alamofire.request(.POST, CConstants.ServerURL + CConstants.LoginServiceURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                    if response.result.isSuccess {
                                                print(response.result.value)
                        if let rtnValue = response.result.value as? [String: AnyObject]{
                            self.clockInfo = LoginedInfo(dicInfo: rtnValue)
                            
                        }else{
                            
                        }
                    }else{
                        
                        self.PopNetworkError()
                    }
                }
            }
        }
        
        
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
        self.timer = NSTimer.scheduledTimerWithTimeInterval(900, target: self, selector: "SubmitLocation", userInfo: nil, repeats: true)
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
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableSource?.count ?? 0
    }

//    func table
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 35
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        if let list = tableSource?["\(section)"]{
            let lbl = UILabel(frame: CGRect(x: 0, y: 20, width: tableView.frame.size.width, height: 15))
            lbl.text = list.first!.DayFullName! + ", " + list.first!.Day!
            lbl.textAlignment = NSTextAlignment.Center
            lbl.font = UIFont(name: "Helvetica Neue", size: 14)
            lbl.backgroundColor = UIColor.whiteColor()
            return lbl
        }else{
            return nil
        }
    
    }
    
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
        }
        
        if self.timeIntervalClockIn > 0 {
            callSubmitLocationService()
        }else if self.timeIntervalClockIn == -1{
            callClockService(isClockIn: false)
        }else if self.timeIntervalClockIn == -2{
            callClockService(isClockIn: true)
            
            
        }
    }
    
    
    
    func clockIn(){
        self.timeIntervalClockIn = -2
        locationManager?.startUpdatingLocation()
    }
    
    func SubmitLocation(){
        locationManager?.startUpdatingLocation()
    }
    
    private func callSubmitLocationService(){
        let submitRequired = SubmitLocationRequired()
        submitRequired.Latitude = "\(self.latitude!)"
        submitRequired.Longitude = "\(self.longitude!)"
        submitRequired.Token = self.clockInfo?.OAuthToken?.Token
        submitRequired.TokenSecret = self.clockInfo?.OAuthToken?.TokenSecret
        //        print(submitRequired.getPropertieNamesAsDictionary())
        Alamofire.request(.POST, CConstants.ServerURL + CConstants.SubmitLocationServiceURL, parameters: submitRequired.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
            if response.result.isSuccess {
//                print("submit location information")
//                print(response.result.value)
            }else{
            }
        }
        
    }
    
    private func toEablePageControl(){
        self.clockInBtn.enabled = true
        self.clockOutBtn.enabled = true
        self.clockOutBtn.backgroundColor = UIColor.lightGrayColor()
        self.clockInBtn.backgroundColor = UIColor(red: 75/255.0, green: 215/255.0, blue: 99/255.0, alpha: 1)
        self.clockOutBtn.backgroundColor = UIColor(red: 75/255.0, green: 215/255.0, blue: 99/255.0, alpha: 1)
    }
    
    private func disableEablePageControl(){
        self.clockInBtn.enabled = false
        self.clockOutBtn.enabled = false
        self.clockOutBtn.backgroundColor = UIColor.lightGrayColor()
        self.clockInBtn.backgroundColor = UIColor.lightGrayColor()
    }
    private func callClockService(isClockIn isClockIn: Bool){
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
        
        disableEablePageControl()
        Alamofire.request(.POST, CConstants.ServerURL + (isClockIn ? CConstants.ClockInServiceURL: CConstants.ClockOutServiceURL), parameters: clockOutRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
            if response.result.isSuccess {
//                print(response.result.value)
                if let rtnValue = response.result.value as? [String: AnyObject]{
                    let rtn = ClockResponse(dicInfo: rtnValue)
                    if Int(rtn.Status!) <= 0 {
                        if rtn.Message != "" {
                            self.PopMsgWithJustOK(msg: rtn.Message!, txtField: nil)
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
                                    }
                                }
                            }
                            self.timer?.invalidate()
                            self.timer = nil
                        }
                    }
                }else{
                    self.PopServerError()
                }
                self.toEablePageControl()
//                print(isClockIn ? "Clock In" : "clock out")
//                print(response.result.value)
//                self.navigationController?.popViewControllerAnimated(true)
//                if isClockIn {
//                    self.clockOutBtn.enabled = false
//                    self.clockInBtn.enabled = true
//                    self.clockOutBtn.backgroundColor = UIColor.lightGrayColor()
//                    self.clockInBtn.backgroundColor = UIColor(red: 75/255.0, green: 215/255.0, blue: 99/255.0, alpha: 1)
//                }else{
//                    self.clockOutBtn.enabled = true
//                    self.clockInBtn.enabled = false
//                    self.clockInBtn.backgroundColor = UIColor.lightGrayColor()
//                    self.clockOutBtn.backgroundColor = UIColor(red: 75/255.0, green: 215/255.0, blue: 99/255.0, alpha: 1)
//                }
                
                
            }else{
                
                //                self.PopNetworkError()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.latitude = 0
        self.longitude = 0
        locationManager?.stopUpdatingLocation()
        locationManager?.startUpdatingLocation()
    }
    
}

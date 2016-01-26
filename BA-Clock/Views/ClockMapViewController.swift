//
//  ClockMapViewController.swift
//  BA-Clock
//
//  Created by April on 1/12/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit
import Alamofire

class ClockMapViewController: BaseViewController {
   
    @IBOutlet weak var clockInSpinner: UIActivityIndicatorView!
    @IBOutlet weak var clockOutSpinner: UIActivityIndicatorView!
    @IBOutlet weak var switchItem: UIBarButtonItem!
    @IBOutlet weak var mapTable: UITableView!
    @IBOutlet weak var textTable: UITableView!
    @IBOutlet weak var clockInBtn: UIButton!
    @IBOutlet weak var clockOutBtn: UIButton!
    
    var CurrentScheduledInterval : Double?
    var locationTracker : LocationTracker?
    var locationUpdateTimer : NSTimer?
    var SyncTimer : NSTimer?
    var firstTime = false
    var currentRequest : Request?
    var clockDataList : [ScheduledDayItem]?{
        didSet{
            
            self.mapTable?.reloadData()
            self.textTable?.reloadData()
            
            if clockDataList != nil && clockDataList?.count > 0 {
                scrollToBottom()
            }
            
        }
    }
    
    private struct constants{
        static let CellIdentifier : String = "clockMapCell"
        static let CellIdentifierText : String = "clockItemCell"
        static let UserInfoClockedKey : String = "ClockedIn"
        
        static let UserInfoScheduledFrom : String = "ScheduledFrom"
        static let UserInfoScheduledTo : String = "ScheduledTo"
        
        static let RightTopItemTitleMap : String = "Map"
        static let RightTopItemTitleText : String = "Text"
    }
    
    
   
    
    private func scrollToBottom(){
        if (mapTable?.contentSize.height ?? 10) - (mapTable?.frame.size.height ?? 10) > 10 {
            mapTable?.contentOffset = CGPoint(x: 0, y: (mapTable?.contentSize.height ?? 0) - (mapTable?.frame.size.height ?? 0))
            textTable?.contentOffset = CGPoint(x: 0, y: (textTable?.contentSize.height ?? 0) - (textTable?.frame.size.height ?? 0))
        }
    }
    
    
    @IBAction func switchTo(sender: UIBarButtonItem) {
        switch sender.title!{
        case constants.RightTopItemTitleText:
            sender.title = constants.RightTopItemTitleMap
            UIView.transitionFromView(mapTable, toView: textTable, duration: 1, options: [.TransitionFlipFromRight, .ShowHideTransitionViews], completion: { (_) -> Void in
                
                self.view.bringSubviewToFront(self.textTable)
            })
            
            
            break
        default:
            sender.title = constants.RightTopItemTitleText
            UIView.transitionFromView(textTable, toView: mapTable, duration: 1, options: [.TransitionFlipFromLeft, .ShowHideTransitionViews], completion: { (_) -> Void in
                self.view.bringSubviewToFront(self.mapTable)
            })
            
            
            break
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if locationTracker == nil {
            locationTracker = LocationTracker()
        }
        locationTracker?.startLocationTracking()
        
        
        self.CurrentScheduledInterval = self.getCurrentInterval1()
        
        checkUpate()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255.0, green: 72/255.0, blue: 116/255.0, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        if self.clockDataList == nil {
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
                
                self.noticeOnlyText(CConstants.LoadingMsg)
                currentRequest = Alamofire.request(.POST, CConstants.ServerURL + CConstants.GetScheduledDataURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                    if response.result.isSuccess {
                        
                        if let rtnValue = response.result.value as? [[String: AnyObject]]{
                            self.clockDataList = [ScheduledDayItem]()
                            for item in rtnValue{
                                self.clockDataList!.append(ScheduledDayItem(dicInfo: item))
                            }
                            let hasclocked = userInfo.valueForKey(constants.UserInfoClockedKey) as? String
                            if hasclocked != nil && hasclocked == "1" {
                                self.update1()
                                self.updateLocation()
                            }else{
                                
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
        
        
    }
    
    func dismissProgress(){
        self.clearNotice()
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
                                self.updateLocation()
                                 self.locationUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(self.CurrentScheduledInterval ?? 900, target: self, selector: "updateLocation", userInfo: nil, repeats: true)
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
        return clockDataList?.count ?? 0
    }
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let list = clockDataList!
        
        if tableView == mapTable {
            let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifier, forIndexPath: indexPath)
            if let cellitem = cell as? ClockMapCell {
                if let item : ScheduledDayItem = list[indexPath.row] {
                    cellitem.clockInfo = item
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifierText, forIndexPath: indexPath)
            if let cellitem = cell as? ClockTextCell {
                if let item : ScheduledDayItem = list[indexPath.row] {
                    cellitem.clockInfo = item
                }
            }
            return cell
        }
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if(firstTime && indexPath.row == tableView.indexPathsForVisibleRows?.last?.row){
            firstTime = false
            self.scrollToBottom()
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
//        print(currentRequest?.request?.URLString)
        
//        var cando = currentRequest?.task.state != .Running
//        if !cando {
//            if let url = currentRequest?.request?.URLString {
//                if url == CConstants.ServerURL + CConstants.SubmitLocationServiceURL {
//                    if NSDate().timeIntervalSinceDate(lastCallSubmitLocationService!) >= self.CurrentScheduledInterval ?? 900 {
//                        currentRequest?.cancel()
//                        cando = true
//                    }
//                }
//            }
//
//        }
//        if cando {
//            print("###################")
            
            lastCallSubmitLocationService = NSDate()
            let submitRequired = SubmitLocationRequired()
            submitRequired.Latitude = "\(self.locationTracker?.myLastLocation.latitude ?? 0)"
            submitRequired.Longitude = "\(self.locationTracker?.myLastLocation.longitude ?? 0)"
            let OAuthToken = self.getUserToken()
            submitRequired.Token = OAuthToken.Token
            submitRequired.TokenSecret = OAuthToken.TokenSecret
//            print(submitRequired.getPropertieNamesAsDictionary())
            currentRequest = Alamofire.request(.POST, CConstants.ServerURL + CConstants.SubmitLocationServiceURL, parameters: submitRequired.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
//                print(response.result.value)
                if response.result.isSuccess {
                    //                print("submit location information")
                    //                print(response.result.value)
                }else{
                }
            }
            
//        }
        
        
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
        clockOutRequiredInfo.Token = OAuthToken.Token
        clockOutRequiredInfo.TokenSecret = OAuthToken.TokenSecret
        
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
                            self.PopMsgWithJustOK(msg: rtn.Message!, txtField: nil)
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
                                self.textTable.reloadData()
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
                                self.textTable.reloadData()
                                self.scrollToBottom()
                            }
                            self.locationUpdateTimer?.invalidate()
                            self.locationUpdateTimer = nil
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
    
   
}

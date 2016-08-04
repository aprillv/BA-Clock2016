//
//  CLocationManager.swift
//  BA-Clock
//
//  Created by April on 5/5/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//


import Foundation
import CoreLocation
import Alamofire


class CLocationManager: NSObject, CLLocationManagerDelegate {
    class var sharedInstance: CLocationManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            
            static var instance: CLocationManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = CLocationManager()
        }
        return Static.instance!
    }
    
    var locationManager:CLLocationManager?
    var currentLocation:CLLocation?
    
    var SyncTimer: NSTimer?
    var ResetLocaitonAccurarcyTimer : NSTimer?
    
    var NoComeBackTimer: NSTimer?
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
//        self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        self.locationManager?.distanceFilter = 10
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        
    }
    
    func startUpdatingLocation() {
//        println("Starting Location Updates")
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.allowsBackgroundLocationUpdates = true
       
//        self.locationManager
        
        self.locationManager?.startMonitoringSignificantLocationChanges()
//        self.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
         self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        self.locationManager?.distanceFilter = 100
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        self.locationManager?.activityType = .OtherNavigation
        
        self.locationManager?.startUpdatingLocation()
        
        
        NSTimer.scheduledTimerWithTimeInterval(600, target: self, selector: #selector(CLocationManager.syncFrequency1), userInfo: nil, repeats: true)
        syncFrequency()
        
    }
    
    func syncFrequency1() {
        let log = cl_log()
        log.savedLogToDB(NSDate(), xtype: true, lat: "\(currentLocation?.coordinate.latitude ?? 0) \(currentLocation?.coordinate.longitude ?? 0)")
        
//        print("nstimer", NSDate())
    }
    func setNotComeBackNotification(endTime : NSDate) {
//        print(endTime)
       
        let info = UILocalNotification()
        info.fireDate = endTime.dateByAddingTimeInterval(10.0 * 60.0)
        info.timeZone = NSTimeZone.defaultTimeZone()
        info.alertBody = "You should click come back now. It is time out more than 10 minutes."
        info.soundName = UILocalNotificationDefaultSoundName
        info.applicationIconBadgeNumber = 1
        print(info.repeatInterval)
//        info.repeatInterval = .Second
        UIApplication.sharedApplication().scheduleLocalNotification(info)
        
        
    }
   
   
    
    
    var lastTimestamp  = NSDate()
//    var lastResubmitTimestamp  = NSDate()
    func stopUpdatingLocation() {
//        println("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    var timeInterval : NSTimeInterval = 0.0
    
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        //print("ccccc", error)
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("aaa", NSDate(), manager.desiredAccuracy)
        let location: CLLocation? = locations.last
//        self.locationManager?.allowDeferredLocationUpdatesUntilTraveled(CLLocationDistanceMax, timeout: 180)
        self.currentLocation = location
        
//        if NSDate().timeIntervalSinceDate(lastResubmitTimestamp) >= 60 {
//            lastResubmitTimestamp = NSDate()
//            let su = cl_submitData()
//            su.resubmit(nil)
//        }
      
        
        
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        if userInfo.boolForKey(CConstants.ToAddTrack) ?? true {
            
            syncFrequency()
            userInfo.setBool(false, forKey: CConstants.ToAddTrack)
            lastTimestamp = NSDate()
            NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: #selector(CLocationManager.updateLocation), userInfo: nil, repeats: false)
        }
    }
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
//        print("bbb", NSDate(), error)
        let su = cl_submitData()
        su.resubmit(nil)
        
//        if NSDate().timeIntervalSinceDate(lastTimestamp) >= random {
//            lastTimestamp = NSDate()
////            updateLocation()
//        }
        
//        manager.disallowDeferredLocationUpdates()
        manager.stopUpdatingHeading()
        manager.startUpdatingLocation()
        
//        let lg = cl_log()
//        lg.savedLogToDB(NSDate(), xtype: true, lat: "EE \(currentLocation?.coordinate.latitude ?? 0.0) -- \(currentLocation?.coordinate.longitude ?? 0.0)")
//        print("Update Location Error : \(error.description)")
    
    }
    
    func updateLocation(){
//        userInfo.setValue("\(rstart);\(rend)", forKey: CConstants.LastGoOutTimeStartEnd)
        let userInfo = NSUserDefaults.standardUserDefaults()
        
        if let s = userInfo.stringForKey(CConstants.LastGoOutTimeStartEnd) {
            if s.containsString(";") {
                let tl = Tool()
                let array = s.componentsSeparatedByString(";")
                let a = userInfo.doubleForKey(CConstants.SeverTimeSinceClienttime) ?? 0
                let sStart = tl.getDateFromStringClient(array[0]).dateByAddingTimeInterval(a)
                let sEnd = tl.getDateFromStringClient(array[1]).dateByAddingTimeInterval(a)
                let now = NSDate()
                if (now.timeIntervalSinceDate(sStart) < 0 || sEnd.timeIntervalSinceDate(now) < 0){
                    let h = sEnd.timeIntervalSinceDate(NSDate())
                    if h > 0 {
                        
                        self.doNextUpdateLoaction(h)
                    }
                    return
                }
            }
        }
//        syncFrequency()
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let dayFullName = dateFormatter.stringFromDate(now)
       
        let clfrequency = cl_coreData()
        if let item = clfrequency.getFrequencyByWeekdayNm(dayFullName) {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let nowdate = dateFormatter.stringFromDate(now)
            
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            let todayFrom = dateFormatter.dateFromString("\(nowdate) \(item.ScheduledFrom ?? "12:00 AM")")
            let todayTo = dateFormatter.dateFromString("\(nowdate) \(item.ScheduledTo ?? "11:59 PM")")
            if (now.timeIntervalSinceDate(todayFrom ?? now) < 0 || (todayTo ?? now).timeIntervalSinceDate(now) < 0){
                let interval = userInfo.doubleForKey(CConstants.SeverTimeSinceClienttime) ?? 0
                let nextInterval = self.getFirstQuauterTimeSpace(interval)
                self.doNextUpdateLoaction(nextInterval)
                return
            }
        }
        
//        let tl = Tool()
        let lat = currentLocation?.coordinate.latitude
        let lng = currentLocation?.coordinate.longitude
        if lat == 0.0 || lng == 0.0 {
           userInfo.setBool(true, forKey: CConstants.ToAddTrack)
        }
        
        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"
        let ClientTime = dateFormatter.stringFromDate(NSDate())
        
        self.callSubmitLocationService(lat, longitude1: lng, time: ClientTime)
    }
    
    
    func syncFrequency()  {
        let tl = Tool()
        tl.syncFrequency()
    }
    func saveLog(){
        
        self.performSelector(#selector(saveLog0), withObject: nil, afterDelay: Double(15 * 60))
       
        
    }
    
    func saveLog0(){
//        print(NSDate())
        updateLocation()
//        let lg = cl_log()
//        lg.savedLogToDB(NSDate(), xtype: true, lat: "\(currentLocation?.coordinate.latitude) -- \(currentLocation?.coordinate.longitude)")
        
    }
    
    var redoTimes = 0
    
    func doNextUpdateLoaction(interval : NSTimeInterval) {
        var h = interval
        if h == 0 {
            h = 900
        }
            if h >= 15 {
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
                NSTimer.scheduledTimerWithTimeInterval(h - 14, target: self, selector: #selector(CLocationManager.resetToHighAccuracy), userInfo: nil, repeats: false)
            }else{
                self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            }
            
            
            NSTimer.scheduledTimerWithTimeInterval(h, target: self, selector: #selector(CLocationManager.updateLocation), userInfo: nil, repeats: false)
        
        
    }
    func callSubmitLocationService(latitude : Double?, longitude1 : Double?, time: String){
        let submitRequired = SubmitLocationRequired()
        submitRequired.Latitude = "\(latitude ?? 0)"
        submitRequired.Longitude = "\(longitude1 ?? 0)"
        submitRequired.ClientTime = time
        
//        let log = cl_log()
        //        log.savedLogToDB(NSDate(), xtype: true, lat: "\(submitRequired.Latitude!) \(submitRequired.Longitude!)")
        let tl = Tool()
        let OAuthToken = tl.getUserToken()
        submitRequired.Token = OAuthToken.Token
        submitRequired.TokenSecret = OAuthToken.TokenSecret
        let param = submitRequired.getPropertieNamesAsDictionary()
//        print(param)
        Alamofire.request(.POST, CConstants.ServerURL + CConstants.SubmitLocationServiceURL, parameters: param).responseJSON{ (response) -> Void in
            //            print(submitRequired.getPropertieNamesAsDictionary(), response.result.value)
            if response.result.isSuccess {
                if let result = response.result.value as? [String: AnyObject] {
//                    print(result)
                    if let rtnValue = result["ScheduledDay"] as? [[String: AnyObject]] {
                        var rtn = [FrequencyItem]()
                        for item in rtnValue{
                            rtn.append(FrequencyItem(dicInfo: item))
                        }
                        let coreData = cl_coreData()
                        coreData.savedFrequencysToDB(rtn)
                    }
                    if ((result["Result"] as? Bool) ?? false) {
                        if !((result["GeoFenceyn"] as? Bool) ?? false) {
                            self.redoTimes += 1
                            if self.redoTimes < 3 {
                                self.doNextUpdateLoaction(60)
                            }else{
                                self.redoTimes = 0
                                let interval = tl.SetNextCallTime((result["ServerTime"] as? String) ?? "")
                                let nextInterval = self.getFirstQuauterTimeSpace(interval)
                                self.doNextUpdateLoaction(nextInterval)
                            }
                            
                        }else{
                            self.redoTimes = 0
                            let interval = tl.SetNextCallTime((result["ServerTime"] as? String) ?? "")
                            let nextInterval = self.getFirstQuauterTimeSpace(interval)
                            self.doNextUpdateLoaction(nextInterval)
                        }
                        
                    }else{
                        
                    }
                }else{
                    self.redoTimes += 1
                    if self.redoTimes < 3 {
                        self.doNextUpdateLoaction(60)
                    }else{
                        self.redoTimes = 0
                        
                        let interval = NSUserDefaults.standardUserDefaults().doubleForKey(CConstants.SeverTimeSinceClienttime) ?? 0
                        let nextInterval = self.getFirstQuauterTimeSpace(interval)
                        self.doNextUpdateLoaction(nextInterval)
                    }
                }
            }else{
                self.redoTimes += 1
                if self.redoTimes < 3 {
                    self.doNextUpdateLoaction(60)
                }else{
                    self.redoTimes = 0
                    let interval = NSUserDefaults.standardUserDefaults().doubleForKey(CConstants.SeverTimeSinceClienttime) ?? 0
                    let nextInterval = self.getFirstQuauterTimeSpace(interval)
                    self.doNextUpdateLoaction(nextInterval)
                }
            }
        }
    }
    
    func  resetToHighAccuracy (){
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    private func getFirstQuauterTimeSpace(interval: NSTimeInterval) -> NSTimeInterval{
//        print(NSDate.laterDate(NSDate()))
        let date = NSDate().dateByAddingTimeInterval(interval)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH"
        let nowHour = dateFormatter.stringFromDate(date)
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        var now15 = dateFormatter.dateFromString(nowHour + ":00:00")
        
        let now = date
        dateFormatter.dateFormat = "EEEE"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let dayFullName = dateFormatter.stringFromDate(now)
        
        let clfrequency = cl_coreData()
        if let item = clfrequency.getFrequencyByWeekdayNm(dayFullName) {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let nowdate = dateFormatter.stringFromDate(now)
            
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            let todayFrom = dateFormatter.dateFromString("\(nowdate) \(item.ScheduledFrom ?? "12:00 AM")")
            let todayTo = dateFormatter.dateFromString("\(nowdate) \(item.ScheduledTo ?? "11:59 PM")")
//            print(now.timeIntervalSinceDate(todayFrom ?? now), (todayTo ?? now).timeIntervalSinceDate(now))
            if (now.timeIntervalSinceDate(todayFrom ?? now) > 0 && (todayTo ?? now).timeIntervalSinceDate(now) > 0){
                
                for _ in 1...4 {
//                    if dos{
                        now15 = now15?.dateByAddingTimeInterval(15*60)
                        if let now1 = now15 {
                            if (now1.timeIntervalSinceDate(todayFrom ?? now1) > 0 && (todayTo ?? now1).timeIntervalSinceDate(now1) > 0){
                                let timeSpace = now1.timeIntervalSinceDate(date)
                                if  timeSpace > 0 {
                                    //                print("apirl", timeSpace ?? 0, i*15)
                                    return timeSpace
                                }
                                
                            }
                        }
//                    }
                    
                    
                    
                }
            }else{
                
                let now1 = NSDate()
                var h = now1.timeIntervalSinceDate(todayFrom ?? now1)
                if h < 0 {
                    return -h
                }
                h = (todayTo ?? now1).timeIntervalSinceDate(now1)
                if h < 0 {
                    let nextday = now.dateByAddingTimeInterval(60*60*24)
                    dateFormatter.dateFormat = "EEEE"
                    
                    let dayFullName = dateFormatter.stringFromDate(nextday)
                    
                    let clfrequency = cl_coreData()
                    if let item = clfrequency.getFrequencyByWeekdayNm(dayFullName) {
                        dateFormatter.dateFormat = "MM/dd/yyyy"
                        let nowdate = dateFormatter.stringFromDate(nextday)
                        
                        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
                        let todayFrom = dateFormatter.dateFromString("\(nowdate) \(item.ScheduledFrom ?? "12:00 AM")")
                        h = todayFrom?.timeIntervalSinceDate(NSDate()) ?? 0
                        if h > 0 {
                            return h
                        }
                    }
                }
                return 0
            }
        }
        
        
        return 15*60-5
        
    }
    
    
}
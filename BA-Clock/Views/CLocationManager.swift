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
    
    var hasfirstTrack = 0
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.activityType = .Fitness
        self.setHighLocationAccurcy()
        
    }
    
    func startUpdatingLocation() {
        
        self.locationManager?.allowsBackgroundLocationUpdates = true
        self.setHighLocationAccurcy()
        
        self.locationManager?.startUpdatingLocation()
        
        let nextInterval = self.getFirstQuauterTimeSpace(diffinterval)
        
        NSTimer.scheduledTimerWithTimeInterval(nextInterval, target: self, selector: #selector(CLocationManager.updateLocation99), userInfo: nil, repeats: false)
        
        
    }
    
    func setHighLocationAccurcy() {
        self.locationManager?.distanceFilter = 10
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    func setLowLocationAccurcy() {
        self.locationManager?.distanceFilter = 1000000
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    
    func setNotComeBackNotification(endTime : NSDate) {
       
        let info = UILocalNotification()
        info.fireDate = endTime.dateByAddingTimeInterval(10.0 * 60.0 + 1.0)
        info.timeZone = NSTimeZone.defaultTimeZone()
        info.alertBody = "You should click come back now. It is more than 10 minutes since you go out."
        info.soundName = UILocalNotificationDefaultSoundName
        info.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(info)
    }
   
   
    
    
    var lastTimestamp  = NSDate()
//    var lastResubmitTimestamp  = NSDate()
    func stopUpdatingLocation() {
//        println("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    var timeInterval : NSTimeInterval = 0.0
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != .AuthorizedAlways && status != .NotDetermined{
            NSNotificationCenter.defaultCenter().postNotificationName(CConstants.LocationServericeChanged, object: nil)
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let location: CLLocation? = locations.last
        self.currentLocation = location
        
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        if userInfo.boolForKey(CConstants.ToAddTrack) ?? true {
            userInfo.setBool(false, forKey: CConstants.ToAddTrack)
            lastTimestamp = NSDate()
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(CLocationManager.updateLocation), userInfo: nil, repeats: false)
        }
//        self.callSubmitLocationService(location?.coordinate.latitude, longitude1: location?.coordinate.longitude, time: self.getClientTime())
//        if (!deferringUpdates) {
//            let distance: CLLocationDistance = 100000
//            let time: NSTimeInterval = 5*60;
//            manager.allowDeferredLocationUpdatesUntilTraveled(distance, timeout:time)
//            deferringUpdates = true;
//        }
        
    }
    
//    var deferringUpdates = false
//    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
//        deferringUpdates = false
//    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        
        manager.stopUpdatingHeading()
        manager.startUpdatingLocation()
    
    }
    
    func updateLocation(){
        let userInfo = NSUserDefaults.standardUserDefaults()
        let lat = currentLocation?.coordinate.latitude
        let lng = currentLocation?.coordinate.longitude
        if lat == 0.0 || lng == 0.0 {
           userInfo.setBool(true, forKey: CConstants.ToAddTrack)
        }
        
        
        self.callSubmitLocationService(lat, longitude1: lng, time: self.getClientTime())
        if hasfirstTrack == 1 {
            hasfirstTrack = 2
           
        }
    }
    
    func updateLocation99(){
        hasfirstTrack = 2
        updateLocation()
        let nextInterval = self.getFirstQuauterTimeSpace(diffinterval)
        
        var h = nextInterval
        if h == 0 {
            h = 900
        }
        if h >= 10 {
            self.setLowLocationAccurcy()
            NSTimer.scheduledTimerWithTimeInterval(h - 9, target: self, selector: #selector(CLocationManager.setHighLocationAccurcy), userInfo: nil, repeats: false)
        }else{
            self.setHighLocationAccurcy()
        }
        
        NSTimer.scheduledTimerWithTimeInterval(nextInterval, target: self, selector: #selector(CLocationManager.updateLocation99), userInfo: nil, repeats: false)
        
    }
    
    func getClientTime() -> String {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"
        let ClientTime = dateFormatter.stringFromDate(NSDate())
        return ClientTime
    }
    
    
   
    
    
    
    
    var redoTimes = 0
    
    func doNextUpdateLoaction(interval : NSTimeInterval) {
        var h = interval
        if h == 0 {
            h = 900
        }
            if h >= 10 {
                self.setLowLocationAccurcy()
                NSTimer.scheduledTimerWithTimeInterval(h - 9, target: self, selector: #selector(CLocationManager.setHighLocationAccurcy), userInfo: nil, repeats: false)
            }else{
                self.setHighLocationAccurcy()
            }
            
            
            NSTimer.scheduledTimerWithTimeInterval(h, target: self, selector: #selector(CLocationManager.updateLocation), userInfo: nil, repeats: false)
        
        
    }
    func callSubmitLocationService(latitude : Double?, longitude1 : Double?, time: String){
        if hasfirstTrack == 0 {
            hasfirstTrack = 1
        }else {
            hasfirstTrack = 2
        }
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
//        print0000(param)
        Alamofire.request(.POST, CConstants.ServerURL + CConstants.SubmitLocationServiceURL, parameters: param).responseJSON{ (response) -> Void in
            //            print0000(submitRequired.getPropertieNamesAsDictionary(), response.result.value)
            if response.result.isSuccess {
                if let result = response.result.value as? [String: AnyObject] {
//                    print0000(result)
                    if let rtnValue = result["ScheduledDay"] as? [[String: AnyObject]] {
                        var rtn = [FrequencyItem]()
                        for item in rtnValue{
                            rtn.append(FrequencyItem(dicInfo: item))
                        }
//                        let coreData = cl_coreData()
//                        coreData.savedFrequencysToDB(rtn)
                    }
                    if ((result["Result"] as? Bool) ?? false) {
                        if !((result["GeoFenceyn"] as? Bool) ?? false) {
                            self.redoTimes += 1
                            if self.redoTimes < 3 {
                                self.doNextUpdateLoaction(60)
                            }else{
                                self.redoTimes = 0
                                self.diffinterval = tl.SetNextCallTime((result["ServerTime"] as? String) ?? "")
                                
                            }
                            
                        }else{
                            self.redoTimes = 0
                            self.diffinterval = tl.SetNextCallTime((result["ServerTime"] as? String) ?? "")
                        }
                        
                    }else{
                        self.redoTimes = 0
                        self.diffinterval = tl.SetNextCallTime((result["ServerTime"] as? String) ?? "")
                    }
                }else{
                    self.redoTimes += 1
                    if self.redoTimes < 3 {
                        self.doNextUpdateLoaction(60)
                    }else{
                        self.redoTimes = 0
                        
                        self.diffinterval = NSUserDefaults.standardUserDefaults().doubleForKey(CConstants.SeverTimeSinceClienttime) ?? 0
                    }
                }
            }else{
                self.redoTimes += 1
                if self.redoTimes < 3 {
                    self.doNextUpdateLoaction(60)
                }else{
                    self.redoTimes = 0
                    self.diffinterval = NSUserDefaults.standardUserDefaults().doubleForKey(CConstants.SeverTimeSinceClienttime) ?? 0
                }
            }
        }
    }
    
    var diffinterval: NSTimeInterval = 0.0
    
    private func getFirstQuauterTimeSpace(interval: NSTimeInterval) -> NSTimeInterval{
        
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
//            print0000(now.timeIntervalSinceDate(todayFrom ?? now), (todayTo ?? now).timeIntervalSinceDate(now))
            if (now.timeIntervalSinceDate(todayFrom ?? now) > 0 && (todayTo ?? now).timeIntervalSinceDate(now) > 0){
                
                for _ in 1...4 {
//                    if dos{
                        now15 = now15?.dateByAddingTimeInterval(15*60)
                        if let now1 = now15 {
                            if (now1.timeIntervalSinceDate(todayFrom ?? now1) > 0 && (todayTo ?? now1).timeIntervalSinceDate(now1) > 0){
                                let timeSpace = now1.timeIntervalSinceDate(date)
                                if  timeSpace > 0 {
                                    //                print0000("apirl", timeSpace ?? 0, i*15)
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

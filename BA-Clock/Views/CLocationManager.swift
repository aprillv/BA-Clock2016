//
//  CLocationManager.swift
//  BA-Clock
//
//  Created by April on 5/5/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//


import Foundation
import CoreLocation


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
    var NoComeBackTimer: NSTimer?
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        self.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        self.locationManager?.distanceFilter = 10
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        
    }
    
    func startUpdatingLocation() {
//        println("Starting Location Updates")
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.allowsBackgroundLocationUpdates = true
//        self.locationManager
        self.locationManager?.startUpdatingLocation()
        
//        let tl = Tool()
//        let firstInterval = tl.getFirstQuauterTimeSpace()
//        NSTimer.scheduledTimerWithTimeInterval(firstInterval, target: self, selector: #selector(CLocationManager.CircleSubmitLocation), userInfo: nil, repeats: false)
        
        
//        NSTimer.scheduledTimerWithTimeInterval(60*60, target: self, selector: #selector(CLocationManager.syncFrequency), userInfo: nil, repeats: false)
        lastResubmitTimestamp = NSDate().dateByAddingTimeInterval(-60)
        syncFrequency()
        
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
        
//        let a = endTime.dateByAddingTimeInterval(60)
//        
//        
//        let info = UILocalNotification()
//        info.fireDate = a
//        info.timeZone = NSTimeZone.defaultTimeZone()
//        info.alertBody = "april88"
//        info.soundName = UILocalNotificationDefaultSoundName
//        info.applicationIconBadgeNumber = 1
//        info.repeatInterval = .Minute
//        UIApplication.sharedApplication().scheduleLocalNotification(info)
        
    }
   
    
    func CircleSubmitLocation() {
        saveLog0()
        let tl = Tool()
        let interval = tl.getCurrentInterval1()
        if interval > 0 {
//            self.SyncTimer
            self.SyncTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(CLocationManager.saveLog), userInfo: nil, repeats: true)
        }
    }
    
    
    var lastTimestamp  = NSDate()
    var lastResubmitTimestamp  = NSDate()
    var random :NSTimeInterval = 0.0
    func stopUpdatingLocation() {
//        println("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    var timeInterval : NSTimeInterval = 0.0
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("aaa", NSDate())
        let location: CLLocation? = locations.last
        
        self.currentLocation = location 
        
        if NSDate().timeIntervalSinceDate(lastResubmitTimestamp) >= 60 {
            lastResubmitTimestamp = NSDate()
            let su = cl_submitData()
            su.resubmit(nil)
        }
      
        
        
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        if userInfo.boolForKey(CConstants.ToAddTrack) ?? true {
            
            syncFrequency()
            userInfo.setBool(false, forKey: CConstants.ToAddTrack)
            lastTimestamp = NSDate()
            updateLocation()
            
            let tl = Tool()
            timeInterval = Double(arc4random_uniform(15) * 60)
            print(timeInterval)
            random = tl.getFirstQuauterTimeSpace().0 + timeInterval
            
        }else{
            let d = NSDate()
            let h = d.timeIntervalSinceDate(lastTimestamp)
            
            if h >= random{
                syncFrequency()
                lastTimestamp = d
                updateLocation()
                let c = 900 - timeInterval
                timeInterval = Double(arc4random_uniform(15) * 60)
                random = timeInterval + c
                print(timeInterval)
                
            }
        }
        
    
        
        
        // use for real time update location
//        updateLocation()
//        print(NSDate(), location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 1)
    }
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        
        let su = cl_submitData()
        su.resubmit(nil)
        
        if NSDate().timeIntervalSinceDate(lastTimestamp) >= random {
            lastTimestamp = NSDate()
            random =  (-14 * 60)
            updateLocation()
        }
        
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
                let sStart = tl.getDateFromStringClient(array[0])
                let sEnd = tl.getDateFromStringClient(array[1])
                let now = NSDate()
                if (now.timeIntervalSinceDate(sStart) < 0 || sEnd.timeIntervalSinceDate(now) < 0){
                    return
                }
            }
        }
//        syncFrequency()
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
//        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let dayFullName = dateFormatter.stringFromDate(now)
       
        let clfrequency = cl_coreData()
        if let item = clfrequency.getFrequencyByWeekdayNm(dayFullName) {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let nowdate = dateFormatter.stringFromDate(now)
            
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            let todayFrom = dateFormatter.dateFromString("\(nowdate) \(item.ScheduledFrom ?? "12:00 AM")")
            let todayTo = dateFormatter.dateFromString("\(nowdate) \(item.ScheduledTo ?? "11:59 PM")")
            if (now.timeIntervalSinceDate(todayFrom ?? now) < 0 || (todayTo ?? now).timeIntervalSinceDate(now) < 0){
                return
            }
        }
        
        let tl = Tool()
        let lat = currentLocation?.coordinate.latitude
        let lng = currentLocation?.coordinate.longitude
        if lat == 0.0 || lng == 0.0 {
           userInfo.setBool(true, forKey: CConstants.ToAddTrack)
        }
        tl.callSubmitLocationService(lat, longitude1: lng)
    }
    
    
    func syncFrequency()  {
        let tl = Tool()
        tl.syncFrequency()
    }
    func saveLog(){
        
        self.performSelector(#selector(saveLog0), withObject: nil, afterDelay: Double(arc4random_uniform(15) * 60))
       
        
    }
    
    func saveLog0(){
//        print(NSDate())
        updateLocation()
//        let lg = cl_log()
//        lg.savedLogToDB(NSDate(), xtype: true, lat: "\(currentLocation?.coordinate.latitude) -- \(currentLocation?.coordinate.longitude)")
        
    }
    
}
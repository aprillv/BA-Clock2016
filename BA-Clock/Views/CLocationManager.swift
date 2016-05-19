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
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager?.distanceFilter = 50
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        self.locationManager?.delegate = self
    }
    
    func startUpdatingLocation() {
//        println("Starting Location Updates")
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.allowsBackgroundLocationUpdates = true
//        self.locationManager
        self.locationManager?.startUpdatingLocation()
        
        let tl = Tool()
        let firstInterval = tl.getFirstQuauterTimeSpace()
        NSTimer.scheduledTimerWithTimeInterval(firstInterval, target: self, selector: #selector(CLocationManager.CircleSubmitLocation), userInfo: nil, repeats: false)
        
        
        NSTimer.scheduledTimerWithTimeInterval(60*60, target: self, selector: #selector(CLocationManager.syncFrequency), userInfo: nil, repeats: false)
        
        
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
    
    
    
    func stopUpdatingLocation() {
//        println("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation? = locations.last
        
        self.currentLocation = location 
        
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        if userInfo.boolForKey(CConstants.ToAddTrack) ?? true {
            userInfo.setBool(false, forKey: CConstants.ToAddTrack)
            updateLocation()
        }
        
        
        // use for real time update location
//        updateLocation()
//        print(NSDate(), location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 1)
    }
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        
            print("Update Location Error : \(error.description)")
    
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
        
        let now = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
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
        print(NSDate())
        updateLocation()
        let lg = cl_log()
        lg.savedLogToDB(NSDate(), xtype: true, lat: "\(currentLocation?.coordinate.latitude) -- \(currentLocation?.coordinate.longitude)")
        
    }
    
}
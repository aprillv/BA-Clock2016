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
        
        
        
        
        
    }
    
    func setNotComeBackNotification(endTime : NSDate) {
        
        let info = UILocalNotification()
        info.fireDate = endTime.dateByAddingTimeInterval(10.0 * 60.0)
        info.timeZone = NSTimeZone.defaultTimeZone()
        info.alertBody = "You should click come back now. It is time out more than 10 minutes."
        info.soundName = UILocalNotificationDefaultSoundName
        info.applicationIconBadgeNumber = 1
        
        
        info.repeatInterval = .Minute
        //        info.repeatInterval = NSCalendar.int
        //        info.repeatInterval = 10
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
        saveLog()
        let tl = Tool()
        let interval = tl.getCurrentInterval1()
        if interval > 0 {
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
        
        // use for real time update location
//        updateLocation()
//        print(NSDate(), location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 1)
    }
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        
            print("Update Location Error : \(error.description)")
    
    }
    
    func updateLocation(){
        let lat = currentLocation?.coordinate.latitude
        let lng = currentLocation?.coordinate.longitude
        let tl = Tool()
        tl.callSubmitLocationService(lat, longitude1: lng)
    }
    
    func saveLog(){
        updateLocation()
        let lg = cl_log()
        lg.savedLogToDB(NSDate(), xtype: true, lat: "\(currentLocation?.coordinate.latitude) -- \(currentLocation?.coordinate.longitude)")
        
    }
    
}
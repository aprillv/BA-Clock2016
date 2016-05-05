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
        
        self.SyncTimer = NSTimer.scheduledTimerWithTimeInterval(900, target: self, selector: #selector(CLocationManager.saveLog), userInfo: nil, repeats: true)
        
        
    }
    
    
    
    func stopUpdatingLocation() {
//        println("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation? = locations.last
        
        self.currentLocation = location 
        
        // use for real time update location
        updateLocation(self.currentLocation)
        print(NSDate(), location?.coordinate.latitude ?? 0, location?.coordinate.longitude ?? 1)
    }
    
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        
            print("Update Location Error : \(error.description)")
    
    }
    
    func updateLocation(currentLocation:CLLocation?){
        let lat = currentLocation?.coordinate.latitude
        let lon = currentLocation?.coordinate.longitude
    }
    
    func saveLog(){
        let lg = cl_log()
        lg.savedLogToDB(NSDate(), xtype: true, lat: "\(currentLocation?.coordinate.latitude) -- \(currentLocation?.coordinate.longitude)")
        
    }
    
}
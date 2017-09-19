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
//    private static var __once: () = {
//            Static.instance = CLocationManager()
//        }()
    class var sharedInstance: CLocationManager {
        struct Static {
            static var onceToken: Int = 0
            
            static var instance: CLocationManager? = CLocationManager()
        }
//        _ = CLocationManager.__once
        return Static.instance!
    }
    
    var locationManager:CLLocationManager?
    var currentLocation:CLLocation?
    
    var SyncTimer: Timer?
    var ResetLocaitonAccurarcyTimer : Timer?
    
    var NoComeBackTimer: Timer?
    
    var hasfirstTrack = 0
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.requestAlwaysAuthorization()
        self.locationManager?.activityType = .fitness
        self.locationManager?.pausesLocationUpdatesAutomatically = false
        self.setHighLocationAccurcy()
        
    }
    
    func startUpdatingLocation() {
        
        self.locationManager?.allowsBackgroundLocationUpdates = true
        self.setHighLocationAccurcy()
        
        self.locationManager?.startUpdatingLocation()
        
        let nextInterval = self.getFirstQuauterTimeSpace(diffinterval)
        print(nextInterval)
        Timer.scheduledTimer(timeInterval: nextInterval, target: self, selector: #selector(CLocationManager.updateLocation99), userInfo: nil, repeats: false)
//        print("222222222locationManager")
        
//        let info = UILocalNotification()
//        info.fireDate = NSDate().dateByAddingTimeInterval(60)
//        info.timeZone = NSTimeZone.defaultTimeZone()
//        info.soundName = UILocalNotificationDefaultSoundName
//        info.applicationIconBadgeNumber = 0
//        UIApplication.sharedApplication().scheduleLocalNotification(info)
    }
    
    func setHighLocationAccurcy() {
        self.locationManager?.distanceFilter = 10
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    func setLowLocationAccurcy() {
        self.locationManager?.distanceFilter = 1000000
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    
    func setNotComeBackNotification(_ endTime : Date) {
        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy HH"
//        let nowHour = dateFormatter.stringFromDate(date)
//        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
//        var now15 = dateFormatter.dateFromString(nowHour + ":00:00")
        
        let now = Date()
        dateFormatter.dateFormat = "EEEE"
        let dayFullName = dateFormatter.string(from: now)
        
        let clfrequency = cl_coreData()
        if let item = clfrequency.getFrequencyByWeekdayNm(dayFullName) {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let nowdate = dateFormatter.string(from: now)
            
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            let todayTo = dateFormatter.date(from: "\(nowdate) \(item.ScheduledTo ?? "11:59 PM")")
            if endTime.addingTimeInterval(10.0 * 60.0 + 1.0).timeIntervalSince(todayTo ?? now) < 0 {
                let info = UILocalNotification()
                info.fireDate = endTime.addingTimeInterval(10.0 * 60.0 + 1.0)
                info.timeZone = TimeZone.current
                info.alertBody = "You should click come back now. It is more than 10 minutes since you go out."
                info.soundName = UILocalNotificationDefaultSoundName
                info.applicationIconBadgeNumber = 1
                UIApplication.shared.scheduleLocalNotification(info)
            }
        }
        
    }
   
   
    
    
    var lastTimestamp  = Date()
//    var lastResubmitTimestamp  = NSDate()
    func stopUpdatingLocation() {
//        println("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    var timeInterval : TimeInterval = 0.0
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedAlways && status != .notDetermined{
//             print("000")
            NotificationCenter.default.post(name: Notification.Name(rawValue: CConstants.LocationServericeChanged), object: nil)
        }else{
//            print(status)
//            print("111")
            let userInfo = UserDefaults.standard
            userInfo.set(true, forKey: CConstants.ToAddTrack)
            manager.startUpdatingLocation()
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("222222--------------")
        let location: CLLocation? = locations.last
        self.currentLocation = location
        
        
        let userInfo = UserDefaults.standard
        if userInfo.bool(forKey: CConstants.ToAddTrack) ?? true {
            userInfo.set(false, forKey: CConstants.ToAddTrack)
            lastTimestamp = Date()
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CLocationManager.updateLocation), userInfo: nil, repeats: false)
        }
    }
    
//    var deferringUpdates = false
//    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
//        deferringUpdates = false
//    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
//        print("333333", error)
//        manager.stopUpdatingHeading()
        manager.startUpdatingLocation()
    
    }
    
    func updateLocation(){
        let userInfo = UserDefaults.standard
        let lat = currentLocation?.coordinate.latitude
        let lng = currentLocation?.coordinate.longitude
        if lat == 0.0 || lng == 0.0 {
           userInfo.set(true, forKey: CConstants.ToAddTrack)
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
//            h = 900
            h = 90
        }
        if h >= 10 {
            self.setLowLocationAccurcy()
            Timer.scheduledTimer(timeInterval: h - 9, target: self, selector: #selector(CLocationManager.setHighLocationAccurcy), userInfo: nil, repeats: false)
        }else{
            self.setHighLocationAccurcy()
        }
        
        Timer.scheduledTimer(timeInterval: nextInterval, target: self, selector: #selector(CLocationManager.updateLocation99), userInfo: nil, repeats: false)
        
    }
    
    func getClientTime() -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"
        let ClientTime = dateFormatter.string(from: Date())
        return ClientTime
    }
    
    
   
    
    
    
    
    var redoTimes = 0
    
    func doNextUpdateLoaction(_ interval : TimeInterval) {
        var h = interval
        if h == 0 {
            h = 900
        }
            if h >= 10 {
                self.setLowLocationAccurcy()
                Timer.scheduledTimer(timeInterval: h - 9, target: self, selector: #selector(CLocationManager.setHighLocationAccurcy), userInfo: nil, repeats: false)
            }else{
                self.setHighLocationAccurcy()
            }
            
            
            Timer.scheduledTimer(timeInterval: h, target: self, selector: #selector(CLocationManager.updateLocation), userInfo: nil, repeats: false)
        
        
    }
    func callSubmitLocationService(_ latitude : Double?, longitude1 : Double?, time: String){
//        print("%%%%%%%%%%%%%%%")
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
        let param = [
            "Token": submitRequired.Token ?? ""
            , "TokenSecret": submitRequired.TokenSecret ?? ""
            , "Latitude": submitRequired.Latitude ?? ""
            , "Longitude": submitRequired.Longitude ?? ""
            , "ClientTime": submitRequired.ClientTime ?? ""
        ]
        
//        let param = submitRequired.getPropertieNamesAsDictionary()
//        print0000(param)
        Alamofire.request(CConstants.ServerURL + CConstants.SubmitLocationServiceURL, method:.post, parameters: param).responseJSON{ (response) -> Void in
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
                        
                        self.diffinterval = UserDefaults.standard.double(forKey:CConstants.SeverTimeSinceClienttime) ?? 0
                    }
                }
            }else{
                self.redoTimes += 1
                if self.redoTimes < 3 {
                    self.doNextUpdateLoaction(60)
                }else{
                    self.redoTimes = 0
                    self.diffinterval = UserDefaults.standard.double(forKey:CConstants.SeverTimeSinceClienttime) ?? 0
                }
            }
        }
    }
    
    var diffinterval: TimeInterval = 0.0
    
    fileprivate func getFirstQuauterTimeSpace(_ interval: TimeInterval) -> TimeInterval{
        
        let date = Date().addingTimeInterval(interval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH"
        let nowHour = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        var now15 = dateFormatter.date(from: nowHour + ":00:00")
        
        let now = date
        dateFormatter.dateFormat = "EEEE"
        
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let dayFullName = dateFormatter.string(from: now)
        
        let clfrequency = cl_coreData()
        if let item = clfrequency.getFrequencyByWeekdayNm(dayFullName) {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let nowdate = dateFormatter.string(from: now)
            
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            let todayFrom = dateFormatter.date(from: "\(nowdate) \(item.ScheduledFrom ?? "12:00 AM")")
            let todayTo = dateFormatter.date(from: "\(nowdate) \(item.ScheduledTo ?? "11:59 PM")")
//            print0000(now.timeIntervalSinceDate(todayFrom ?? now), (todayTo ?? now).timeIntervalSinceDate(now))
            if (now.timeIntervalSince(todayFrom ?? now) > 0 && (todayTo ?? now).timeIntervalSince(now) > 0){
                
                for _ in 1...4 {
//                    if dos{
                        now15 = now15?.addingTimeInterval(15*60)
                        if let now1 = now15 {
                            if (now1.timeIntervalSince(todayFrom ?? now1) > 0 && (todayTo ?? now1).timeIntervalSince(now1) > 0){
                                let timeSpace = now1.timeIntervalSince(date)
                                if  timeSpace > 0 {
                                    //                print0000("apirl", timeSpace ?? 0, i*15)
                                    return timeSpace
                                }
                                
                            }
                        }
//                    }
                    
                    
                    
                }
            }else{
                
                let now1 = Date()
                var h = now1.timeIntervalSince(todayFrom ?? now1)
                if h < 0 {
                    return -h
                }
                h = (todayTo ?? now1).timeIntervalSince(now1)
                if h < 0 {
                    let nextday = now.addingTimeInterval(60*60*24)
                    dateFormatter.dateFormat = "EEEE"
                    
                    let dayFullName = dateFormatter.string(from: nextday)
                    
                    let clfrequency = cl_coreData()
                    if let item = clfrequency.getFrequencyByWeekdayNm(dayFullName) {
                        dateFormatter.dateFormat = "MM/dd/yyyy"
                        let nowdate = dateFormatter.string(from: nextday)
                        
                        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
                        let todayFrom = dateFormatter.date(from: "\(nowdate) \(item.ScheduledFrom ?? "12:00 AM")")
                        h = todayFrom?.timeIntervalSince(Date()) ?? 0
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

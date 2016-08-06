//
//  Tool.swift
//  BA-Clock
//
//  Created by April on 1/14/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

class Tool: NSObject {
    func SetNextCallTime(serverTime: String) -> NSTimeInterval {
        let userInfo = NSUserDefaults.standardUserDefaults()
        if serverTime == "" {
            userInfo.setDouble(0, forKey: CConstants.SeverTimeSinceClienttime)
            return 0
        }
        
        
        let now = NSDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
        let serverTime = dateFormatter.dateFromString(serverTime)
        
        var timeInterval = serverTime?.timeIntervalSinceDate(now) ?? 0
        if timeInterval < 10  && timeInterval > -10{
            timeInterval = 0
        }
        userInfo.setDouble(timeInterval, forKey: CConstants.SeverTimeSinceClienttime)
//        print0000(timeInterval, now)
        return timeInterval
    }
    func getTime2() -> Bool{
        let date = NSDate()
        //        print0000(date)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy EEEE"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        
         dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        let today = dateFormatter.stringFromDate(date)
        let index0 = today.startIndex
        let todayDay = today.substringToIndex(index0.advancedBy(10))
        let coreData = cl_coreData()
        
        var send = false
        if let frequency = coreData.getFrequencyByWeekdayNm(today.substringFromIndex(index0.advancedBy(11))) {
            //        if let frequency = coreData.getFrequencyByWeekdayNm("Monday") {
            //            print0000(todayDay + " " + frequency.ScheduledFrom!)
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            //            print0000(dateFormatter.dateFromString(todayDay + " " + frequency.ScheduledFrom!))
            if let fromTime = dateFormatter.dateFromString(todayDay + " " + frequency.ScheduledFrom!) {
                //                print0000(fromTime)
                if date.timeIntervalSinceDate(fromTime) > 0 {
                    if let toTime = dateFormatter.dateFromString(todayDay + " " + frequency.ScheduledTo!) {
                        send = (toTime.timeIntervalSinceDate(date) > 0)
                    }
                }
                
            }
        }
        return send
        
    }
    
    func getTimeInter() -> (Bool, NSTimeInterval){
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy EEEE"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let today = dateFormatter.stringFromDate(date)
        let index0 = today.startIndex
        let todayDay = today.substringToIndex(index0.advancedBy(10))
        let coreData = cl_coreData()
        
        var send = false
        var rtn : NSTimeInterval = 0
        if let frequency = coreData.getFrequencyByWeekdayNm(today.substringFromIndex(index0.advancedBy(11))) {
            //        if let frequency = coreData.getFrequencyByWeekdayNm("Monday") {
            //            print0000(todayDay + " " + frequency.ScheduledFrom!)
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            //            print0000(dateFormatter.dateFromString(todayDay + " " + frequency.ScheduledFrom!))
            if let fromTime = dateFormatter.dateFromString(todayDay + " " + frequency.ScheduledFrom!) {
                //                print0000(fromTime)
                if date.timeIntervalSinceDate(fromTime) > 0 {
                    if let toTime = dateFormatter.dateFromString(todayDay + " " + frequency.ScheduledTo!) {
                        send = (toTime.timeIntervalSinceDate(date) > 0)
                        if !send {
                            let nextTime = fromTime.dateByAddingTimeInterval(60*60*24)
                            rtn = nextTime.timeIntervalSinceDate(date)
                        }
                    }
                }else {
                    rtn = fromTime.timeIntervalSinceDate(date)
                }
                
            }
        }
//        return (false, 60)
        return (send, rtn)
        
    }
    
    
    func md5(string string: String) -> String {
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
    
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
//          
            var ptr = ifaddr
            while ptr != nil {
                let interface = ptr.memory
                
                // Check for IPv4 or IPv6 interface:
                let addrFamily = interface.ifa_addr.memory.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // Check interface name:
                    if let name = String.fromCString(interface.ifa_name) where name == "en0" {
                        
                        // Convert interface address to a human readable string:
                        var addr = interface.ifa_addr.memory
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        getnameinfo(&addr, socklen_t(interface.ifa_addr.memory.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String.fromCString(hostname)
                    }
                }
                ptr = ptr.memory.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
    
    
    static func saveDeviceTokenToSever(){
        
        let userInfo = NSUserDefaults.standardUserDefaults()
//        let str = userInfo.valueForKey(CConstants.RegisteredDeviceToken) as? String
//        if str == nil || str == "0"{
        
            if let deviceToken = userInfo.valueForKey(CConstants.UserDeviceToken) as? String
                , let userToken = userInfo.valueForKey(CConstants.UserInfoTokenKey) as? String
                , let userTokenSecret = userInfo.valueForKey(CConstants.UserInfoTokenScretKey) as? String{
                
                    let required  = DeviceTokenRequired()
                    required.DeviceToken = deviceToken
                    required.TokenSecret = userTokenSecret
                    required.UserToken = userToken
                    required.PhoneType = CConstants.PhoneType
                    //        print0000(required.getPropertieNamesAsDictionary())
                    Alamofire.request(.POST, CConstants.ServerURL + CConstants.RegisterDeviceTokenServiceURL, parameters: required.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                        if let result = response.result.value as? Bool {
                            if result {
                                userInfo.setValue("1", forKey: CConstants.RegisteredDeviceToken)
                            }
                        }
                    }
                
                
            }
//        }
        
        
        
    }
    
    func getUserToken() -> OAuthTokenItem{
        let userInfo = NSUserDefaults.standardUserDefaults()
        let userInfo1 = OAuthTokenItem(dicInfo: nil)
        userInfo1.Token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String
        userInfo1.TokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String
        return userInfo1
    }

    func callSubmitLocationService(latitude : Double?, longitude1 : Double?){
        let d = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.locale = NSLocale(localeIdentifier : "en_US")
        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"
        let ClientTime = dateFormatter.stringFromDate(d)
        
        let submitData = cl_submitData()
        submitData.savedSubmitDataToDB(ClientTime, lat: latitude ?? 0 , lng: longitude1 ?? 0, xtype: CConstants.SubmitLocationType)
        
        submitData.resubmit(nil)
//        
//        callSubmitLocationService(latitude, longitude1: longitude1, time: ClientTime, ob)
    }
    
    func getDateFromString(ds : String) -> NSDate{
       
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat =  "MM/dd/yyyy hh:mm:ss a"
        dateFormatter.locale = NSLocale(localeIdentifier : "en_US")
//        print0000(dateFormatter.stringFromDate(NSDate()))
//        print0000(ds)
//        let ds1 = ds.stringByReplacingOccurrencesOfString("/", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
//        print0000(ds)
//        print0000(dateFormatter.dateFromString(ds))
        return dateFormatter.dateFromString(ds)!
    }
    
    func getDateFromStringClient(ds : String) -> NSDate{
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = NSLocale(localeIdentifier : "en_US")
        //        print0000(dateFormatter.stringFromDate(NSDate()))
        //        print0000(ds)
        //        let ds1 = ds.stringByReplacingOccurrencesOfString("/", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
//        print0000(ds)
//        print0000(dateFormatter.dateFromString(ds))
        return dateFormatter.dateFromString(ds)!
    }
    
    
    
//    func callSubmitLocationService(latitude : Double?, longitude1 : Double?, time: String){
//        let submitRequired = SubmitLocationRequired()
//        submitRequired.Latitude = "\(latitude ?? 0)"
//        submitRequired.Longitude = "\(longitude1 ?? 0)"
//        submitRequired.ClientTime = time
//        
//        let log = cl_log()
//        log.savedLogToDB(NSDate(), xtype: true, lat: "\(submitRequired.Latitude!) \(submitRequired.Longitude!)")
//        
//        let OAuthToken = getUserToken()
//        submitRequired.Token = OAuthToken.Token
//        submitRequired.TokenSecret = OAuthToken.TokenSecret
//        
//
//        
//    }
    
//    func callSubmitLocationService(latitude : Double?, longitude1 : Double?, time: String, obj: NSManagedObject){
//        let submitRequired = SubmitLocationRequired()
//        submitRequired.Latitude = "\(latitude ?? 0)"
//        submitRequired.Longitude = "\(longitude1 ?? 0)"
//        submitRequired.ClientTime = time
//        
//        let log = cl_log()
////        log.savedLogToDB(NSDate(), xtype: true, lat: "\(submitRequired.Latitude!) \(submitRequired.Longitude!)")
//        
//        let OAuthToken = getUserToken()
//        submitRequired.Token = OAuthToken.Token
//        submitRequired.TokenSecret = OAuthToken.TokenSecret
//        
//        Alamofire.request(.POST, CConstants.ServerURL + CConstants.SubmitLocationServiceURL, parameters: submitRequired.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
////            print0000(submitRequired.getPropertieNamesAsDictionary(), response.result.value)
//            if response.result.isSuccess {
//                if let result = response.result.value as? [String: AnyObject] {
//                    if (result["Result"] as? String) ?? "" == "1" {
//                        if (result["GeoFenceyn"] as? String) ?? "" == "0" {
//                        
//                        }
//                        let tl = Tool()
//                        let interval = tl.SetNextCallTime((result["ServerTime"] as? String) ?? "")
//                       
//                        
//                    }else{
//                    
//                    }
//                }else{
//                    NSNotificationCenter.defaultCenter().postNotificationName(CConstants.SubmitNext, object: true)
//                }
//            }else{
//                NSNotificationCenter.defaultCenter().postNotificationName(CConstants.SubmitNext, object: false)
//            }
//        }
//    }
//    private func getFirstQuauterTimeSpace(interval: NSTimeInterval) -> NSTimeInterval{
//        let date = NSDate().dateByAddingTimeInterval(interval)
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yyyy HH"
//        let nowHour = dateFormatter.stringFromDate(date)
//        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
//        var now15 = dateFormatter.dateFromString(nowHour + ":00:00")
//        
//        for i in 1...4 {
//            now15 = now15?.dateByAddingTimeInterval(15*60)
//            let timeSpace = now15?.timeIntervalSinceDate(date)
//            if  timeSpace > 0 {
//                //                print0000("apirl", timeSpace ?? 0, i*15)
//                return timeSpace!
//            }
//        }
//        return 15*60-5
//        
//    }
    
    
    
    func syncFrequency(){
        let userInfo = NSUserDefaults.standardUserDefaults()
        if let token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String{
            if let tokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String {
//                print0000(token, tokenSecret)
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
//                print0000(loginRequiredInfo.getPropertieNamesAsDictionary())
                Alamofire.request(.POST, CConstants.ServerURL + CConstants.SyncScheduleIntervalURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
//                    print0000(response.result.value)
//                    print0000("syncFrequency")
                    if response.result.isSuccess {
                        if let rtnValue = response.result.value as? [[String: AnyObject]]{
//                            print0000(rtnValue)
                            var rtn = [FrequencyItem]()
                            for item in rtnValue{
                                rtn.append(FrequencyItem(dicInfo: item))
                            }
                            let coreData = cl_coreData()
                            coreData.savedFrequencysToDB(rtn)
                        }else{
                            
                        }
                    }else{
                        
                    }
                }
            }
        }
        
    }
    
    func getFirstQuauterTimeSpace() -> (NSTimeInterval, Int){
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH"
        let nowHour = dateFormatter.stringFromDate(date)
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        var now15 = dateFormatter.dateFromString(nowHour + ":00:00")
        
        for i in 1...4 {
            now15 = now15?.dateByAddingTimeInterval(15*60)
            let timeSpace = now15?.timeIntervalSinceDate(date)
            if  timeSpace > 0 {
//                print0000("apirl", timeSpace ?? 0, i*15)
                return (timeSpace!, i*15)
            }
        }
        return (0, 15)
        
    }
    func getClientTime(date1 : NSDate?) -> String{
        //        return 60
        let date = date1 ?? NSDate()
        //        print0000(date)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let today = dateFormatter.stringFromDate(date)
        
        return today
        
    }
    
    func getClockMsgFormatedTime(date : NSDate) -> String{
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let today = dateFormatter.stringFromDate(date)
        
        return today
        
    }
    
    
    
    func getCurrentInterval1() -> Double{
        //        return 60
        let date = NSDate()
        //        print0000(date)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy EEEE"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let today = dateFormatter.stringFromDate(date)
        let index0 = today.startIndex
        let coreData = cl_coreData()
        
        var send = 900.0
        if let frequency = coreData.getFrequencyByWeekdayNm(today.substringFromIndex(index0.advancedBy(11))) {
            send = frequency.ScheduledInterval!.doubleValue * 60.0
        }
        //        print0000(send)
        return send
        
    }
    
    // MARK: Clock IN/OUT
    func callClockService(isClockIn isClockIn: Bool, clockOutRequiredInfo : ClockOutRequired, obj: NSManagedObject){
        
        Alamofire.request(.POST, CConstants.ServerURL + (isClockIn ? CConstants.ClockInServiceURL: CConstants.ClockOutServiceURL), parameters: clockOutRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
            if response.result.isSuccess {
//                                print0000(response.result.value)
                if let rtn = response.result.value as? [String: AnyObject]{
//                    let rtn = ClockResponse(dicInfo: rtnValue)
                    if let msg = rtn["Message"] as? String{
                        if msg.containsString("Successfully"){
                            NSNotificationCenter.defaultCenter().postNotificationName(CConstants.SubmitNext, object: obj)
                            return
                        }
                    }
                }
            }
            NSNotificationCenter.defaultCenter().postNotificationName(CConstants.SubmitNext, object: false)
        }
    }
    
    func saveClockDataToLocalDB(isClockIn isClockIn: Bool,clockOutRequiredInfo : ClockOutRequired) {
        let cl = cl_submitData()
        cl.savedSubmitDataToDB(clockOutRequiredInfo.ClientTime ?? ""
            , lat: Double(clockOutRequiredInfo.Latitude ?? "0.0" ) ?? 0.0
            , lng: Double(clockOutRequiredInfo.Longitude ?? "0.0" ) ?? 0.0
            , xtype: Int(isClockIn ? CConstants.ClockInType : CConstants.ClockOutType))
    }
    
    
    // MARK: COME BACK
    func doComeBack(clockOutRequiredInfo : ClockOutRequired, obj: NSManagedObject){
        
        var param = clockOutRequiredInfo.getPropertieNamesAsDictionary()
        param["ActionType"] = "Come Back"
        
        Alamofire.request(.POST, CConstants.ServerURL + "ComeBack.json", parameters: param).responseJSON{ (response) -> Void in
//           print0000("come back", response.result.value)
            if let rtnValue = response.result.value as? Int{
                if rtnValue == 1 {
                    NSNotificationCenter.defaultCenter().postNotificationName(CConstants.SubmitNext, object: obj)
                    return
                }
            }
            NSNotificationCenter.defaultCenter().postNotificationName(CConstants.SubmitNext, object: false)
                
            
        }
    }
    
    // MARK: GO OUT
    func doGoOutService(requiredInfo : MoreActionRequired, obj: NSManagedObject){
        Alamofire.request(.POST, CConstants.ServerURL + CConstants.MoreActionServiceURL,
            parameters: requiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
//                print0000("go out", response.result.value )
                if let rtnValue = response.result.value as? Int{
                    if rtnValue == 1 {
                         NSNotificationCenter.defaultCenter().postNotificationName(CConstants.SubmitNext, object: obj)
                        return
                    }
                }
                 NSNotificationCenter.defaultCenter().postNotificationName(CConstants.SubmitNext, object: false)
//                self.saveGoOutDataToLocalDB(requiredInfo)  
        }
    }
    
    func saveGoOutDataToLocalDB(requiredInfo : MoreActionRequired) {
        let cl = cl_submitData()
        cl.savedSubmitDataToDB(requiredInfo.ClientTime ?? ""
            , lat: Double(requiredInfo.Latitude ?? "0.0") ?? 0.0
            , lng: Double(requiredInfo.Longitude ?? "0.0") ?? 0.0
            , reasonStart : requiredInfo.ReasonStart ?? ""
            , reasonEnd : requiredInfo.ReasonEnd  ?? ""
            , reason : requiredInfo.Reason  ?? ""
            , actionType: requiredInfo.ActionType ?? "")
    }
    
}



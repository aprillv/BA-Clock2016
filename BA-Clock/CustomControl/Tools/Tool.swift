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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class Tool: NSObject {
    func SetNextCallTime(_ serverTime: String) -> TimeInterval {
        let userInfo = UserDefaults.standard
        if serverTime == "" {
            userInfo.set(0, forKey: CConstants.SeverTimeSinceClienttime)
            return 0
        }
        
        
        let now = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
        let serverTime = dateFormatter.date(from: serverTime)
        
        var timeInterval = serverTime?.timeIntervalSince(now) ?? 0
        if timeInterval < 10  && timeInterval > -10{
            timeInterval = 0
        }
        userInfo.set(timeInterval, forKey: CConstants.SeverTimeSinceClienttime)
//        print0000(timeInterval, now)
        return timeInterval
    }
    func getTime2() -> Bool{
        let date = Date()
        //        print0000(date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy EEEE"
        
        dateFormatter.locale = Locale(identifier: "en_US")
        
         dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
        let today = dateFormatter.string(from: date)
        let index0 = today.startIndex
        let todayDay = today.substring(to: today.index(index0, offsetBy: 10))
//        let todayDay = today.substring(to: <#T##String.CharacterView corresponding to `index0`##String.CharacterView#>.index(index0, offsetBy: 10))
        let coreData = cl_coreData()
        
        var send = false
//        if let frequency = coreData.getFrequencyByWeekdayNm(today.substring(from: <#T##String.CharacterView corresponding to `index0`##String.CharacterView#>.index(index0, offsetBy: 11))) {
         if let frequency = coreData.getFrequencyByWeekdayNm(today.substring(from: today.index(index0, offsetBy: 11))) {
            //        if let frequency = coreData.getFrequencyByWeekdayNm("Monday") {
            //            print0000(todayDay + " " + frequency.ScheduledFrom!)
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            //            print0000(dateFormatter.dateFromString(todayDay + " " + frequency.ScheduledFrom!))
            if let fromTime = dateFormatter.date(from: todayDay + " " + frequency.ScheduledFrom!) {
                //                print0000(fromTime)
                if date.timeIntervalSince(fromTime) > 0 {
                    if let toTime = dateFormatter.date(from: todayDay + " " + frequency.ScheduledTo!) {
                        send = (toTime.timeIntervalSince(date) > 0)
                    }
                }
                
            }
        }
        return send
        
    }
    
    func getTimeInter() -> (Bool, TimeInterval){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy EEEE"
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let today = dateFormatter.string(from: date)
        let index0 = today.startIndex
        let todayDay = today.substring(to: today.index(index0, offsetBy: 10))
        let coreData = cl_coreData()
        
        var send = false
        var rtn : TimeInterval = 0
        if let frequency = coreData.getFrequencyByWeekdayNm(today.substring(from: today.index(index0, offsetBy: 11))) {
            //        if let frequency = coreData.getFrequencyByWeekdayNm("Monday") {
            //            print0000(todayDay + " " + frequency.ScheduledFrom!)
            dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            //            print0000(dateFormatter.dateFromString(todayDay + " " + frequency.ScheduledFrom!))
            if let fromTime = dateFormatter.date(from: todayDay + " " + frequency.ScheduledFrom!) {
                //                print0000(fromTime)
                if date.timeIntervalSince(fromTime) > 0 {
                    if let toTime = dateFormatter.date(from: todayDay + " " + frequency.ScheduledTo!) {
                        send = (toTime.timeIntervalSince(date) > 0)
                        if !send {
                            let nextTime = fromTime.addingTimeInterval(60*60*24)
                            rtn = nextTime.timeIntervalSince(date)
                        }
                    }
                }else {
                    rtn = fromTime.timeIntervalSince(date)
                }
                
            }
        }
//        return (false, 60)
        return (send, rtn)
        
    }
    
    
    func md5(string: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = string.data(using: String.Encoding.utf8) {
            CC_MD5((data as NSData).bytes, CC_LONG(data.count), &digest)
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
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
//          
            var ptr = ifaddr
            while ptr != nil {
                let interface = ptr?.pointee
                
                // Check for IPv4 or IPv6 interface:
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // Check interface name:
                    if let name = String(validatingUTF8: (interface?.ifa_name)!), name == "en0" {
                        
                        // Convert interface address to a human readable string:
                        var addr = interface?.ifa_addr.pointee
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(&addr!, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
                ptr = ptr?.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
    
    
    static func saveDeviceTokenToSever(){
        
        let userInfo = UserDefaults.standard
//        let str = userInfo.valueForKey(CConstants.RegisteredDeviceToken) as? String
//        if str == nil || str == "0"{
        
            if let deviceToken = userInfo.value(forKey: CConstants.UserDeviceToken) as? String
                , let userToken = userInfo.value(forKey: CConstants.UserInfoTokenKey) as? String
                , let userTokenSecret = userInfo.value(forKey: CConstants.UserInfoTokenScretKey) as? String{
                
                
                
                let param = [
                    "DeviceToken": deviceToken
                , "UserToken": userToken
                , "PhoneType": CConstants.PhoneType
                , "TokenSecret": userTokenSecret
                ]
                    //        print0000(required.getPropertieNamesAsDictionary())
                Alamofire.request( CConstants.ServerURL + CConstants.RegisterDeviceTokenServiceURL, method:.post, parameters: param).responseJSON{ (response) -> Void in
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
        let userInfo = UserDefaults.standard
        let userInfo1 = OAuthTokenItem(dicInfo: nil)
        userInfo1.Token = userInfo.object(forKey: CConstants.UserInfoTokenKey) as? String
        userInfo1.TokenSecret = userInfo.object(forKey: CConstants.UserInfoTokenScretKey) as? String
        return userInfo1
    }

    func callSubmitLocationService(_ latitude : Double?, longitude1 : Double?){
        let d = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.locale = Locale(identifier : "en_US")
        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"
        let ClientTime = dateFormatter.string(from: d)
        
        let submitData = cl_submitData()
        submitData.savedSubmitDataToDB(ClientTime, lat: latitude ?? 0 , lng: longitude1 ?? 0, xtype: CConstants.SubmitLocationType)
        
        submitData.resubmit(nil)
//        
//        callSubmitLocationService(latitude, longitude1: longitude1, time: ClientTime, ob)
    }
    
    func getDateFromString(_ ds : String) -> Date{
       
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat =  "MM/dd/yyyy hh:mm:ss a"
        dateFormatter.locale = Locale(identifier : "en_US")
//        print0000(dateFormatter.stringFromDate(NSDate()))
//        print0000(ds)
//        let ds1 = ds.stringByReplacingOccurrencesOfString("/", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
//        print0000(ds)
//        print0000(dateFormatter.dateFromString(ds))
        return dateFormatter.date(from: ds)!
    }
    
    func getDateFromStringClient(_ ds : String) -> Date{
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier : "en_US")
        //        print0000(dateFormatter.stringFromDate(NSDate()))
        //        print0000(ds)
        //        let ds1 = ds.stringByReplacingOccurrencesOfString("/", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
//        print0000(ds)
//        print0000(dateFormatter.dateFromString(ds))
        return dateFormatter.date(from: ds)!
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
//        Alamofire.request(CConstants.ServerURL + CConstants.SubmitLocationServiceURL, method:.post, parameters: submitRequired.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
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
//                    NotificationCenter.default.post(name:CConstants.SubmitNext, object: true)
//                }
//            }else{
//                NotificationCenter.default.post(name:CConstants.SubmitNext, object: false)
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
        let userInfo = UserDefaults.standard
        if let token = userInfo.object(forKey: CConstants.UserInfoTokenKey) as? String{
            if let tokenSecret = userInfo.object(forKey: CConstants.UserInfoTokenScretKey) as? String {
//                print0000(token, tokenSecret)
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
//                print0000(loginRequiredInfo.getPropertieNamesAsDictionary())
                let param = [
                    "Token": token
                    , "TokenSecret": tokenSecret
                    , "ClientTime": loginRequiredInfo.ClientTime ?? ""
                    , "Email": loginRequiredInfo.Email ?? ""
                    , "Password": loginRequiredInfo.Password ?? ""]
                
                Alamofire.request(CConstants.ServerURL + CConstants.SyncScheduleIntervalURL
                    , method:.post
                    , parameters: param
                    ).responseJSON{ (response) -> Void in
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
    
    func getFirstQuauterTimeSpace() -> (TimeInterval, Int){
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH"
        let nowHour = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        var now15 = dateFormatter.date(from: nowHour + ":00:00")
        
        for i in 1...4 {
            now15 = now15?.addingTimeInterval(15*60)
            let timeSpace = now15?.timeIntervalSince(date)
            if  timeSpace > 0 {
//                print0000("apirl", timeSpace ?? 0, i*15)
                return (timeSpace!, i*15)
            }
        }
        return (0, 15)
        
    }
    func getClientTime(_ date1 : Date?) -> String{
        //        return 60
        let date = date1 ?? Date()
        //        print0000(date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let today = dateFormatter.string(from: date)
        
        return today
        
    }
    
    func getClockMsgFormatedTime(_ date : Date) -> String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let today = dateFormatter.string(from: date)
        
        return today
        
    }
    
    
    
    func getCurrentInterval1() -> Double{
        //        return 60
        let date = Date()
        //        print0000(date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy EEEE"
        
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        let today = dateFormatter.string(from: date)
        let index0 = today.startIndex
        let coreData = cl_coreData()
        
        var send = 900.0
        if let frequency = coreData.getFrequencyByWeekdayNm(today.substring(from: today.index(index0, offsetBy: 11))) {
            send = frequency.ScheduledInterval!.doubleValue * 60.0
        }
        //        print0000(send)
        return send
        
    }
    
    // MARK: Clock IN/OUT
    func callClockService(isClockIn: Bool, clockOutRequiredInfo : ClockOutRequired, obj: NSManagedObject){
        
        let param = [
          "Token": clockOutRequiredInfo.Token ?? ""
        , "TokenSecret": clockOutRequiredInfo.TokenSecret ?? ""
        , "IPAddress": clockOutRequiredInfo.IPAddress ?? ""
        , "ClientTime": clockOutRequiredInfo.ClientTime ?? ""
        , "HostName": clockOutRequiredInfo.HostName ?? ""
        , "Latitude": clockOutRequiredInfo.Latitude ?? ""
        , "Longitude": clockOutRequiredInfo.Longitude ?? ""
        ]
        Alamofire.request( CConstants.ServerURL + (isClockIn ? CConstants.ClockInServiceURL: CConstants.ClockOutServiceURL)
            , method:.post
            , parameters: param).responseJSON{ (response) -> Void in
            if response.result.isSuccess {
//                                print0000(response.result.value)
                if let rtn = response.result.value as? [String: AnyObject]{
//                    let rtn = ClockResponse(dicInfo: rtnValue)
                    if let msg = rtn["Message"] as? String{
                        if msg.contains("Successfully"){
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: CConstants.SubmitNext), object: obj)
                            return
                        }
                    }
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: CConstants.SubmitNext), object: false)
        }
    }
    
    func saveClockDataToLocalDB(isClockIn: Bool,clockOutRequiredInfo : ClockOutRequired) {
        let cl = cl_submitData()
        cl.savedSubmitDataToDB(clockOutRequiredInfo.ClientTime ?? ""
            , lat: Double(clockOutRequiredInfo.Latitude ?? "0.0" ) ?? 0.0
            , lng: Double(clockOutRequiredInfo.Longitude ?? "0.0" ) ?? 0.0
            , xtype: Int(isClockIn ? CConstants.ClockInType : CConstants.ClockOutType))
    }
    
    
    // MARK: COME BACK
    func doComeBack(_ clockOutRequiredInfo : ClockOutRequired, obj: NSManagedObject){
        
//        var param = clockOutRequiredInfo.getPropertieNamesAsDictionary
//        )
        var param = [
            "Token": clockOutRequiredInfo.Token
            , "TokenSecret": clockOutRequiredInfo.TokenSecret
            , "IPAddress": clockOutRequiredInfo.IPAddress
            , "ClientTime": clockOutRequiredInfo.ClientTime
            , "HostName": clockOutRequiredInfo.HostName
        , "Latitude": clockOutRequiredInfo.Latitude
        , "Longitude": clockOutRequiredInfo.Longitude]
        
        param["ActionType"] = "Come Back"
        
        Alamofire.request( CConstants.ServerURL + "ComeBack.json", method:.post, parameters: param).responseJSON{ (response) -> Void in
//           print0000("come back", response.result.value)
            if let rtnValue = response.result.value as? Int{
                if rtnValue == 1 {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CConstants.SubmitNext), object: obj)
                    return
                }
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: CConstants.SubmitNext), object: false)
                
            
        }
    }
    
    // MARK: GO OUT
    func doGoOutService(_ requiredInfo : MoreActionRequired, obj: NSManagedObject){
//        var ActionType: String?
//        var Token : String?
//        var TokenSecret : String?
//        var IPAddress : String?
//        var HostName : String?
//        var Latitude : String?
//        var Longitude : String?
//        var ReasonStart : String?
//        var ReasonEnd : String?
//        var Reason : String?
//        var ClientTime: String?
        let param = [
              "ActionType": requiredInfo.ActionType ?? ""
            , "Token": requiredInfo.Token ?? ""
            , "TokenSecret": requiredInfo.TokenSecret ?? ""
            , "IPAddress": requiredInfo.IPAddress ?? ""
            , "HostName": requiredInfo.HostName ?? ""
            , "Latitude": requiredInfo.Latitude ?? ""
            , "Longitude": requiredInfo.Longitude ?? ""
            , "ReasonStart": requiredInfo.ReasonStart ?? ""
            , "ReasonEnd": requiredInfo.ReasonEnd ?? ""
            , "Reason": requiredInfo.Reason ?? ""
            , "ClientTime": requiredInfo.ClientTime ?? ""
        ]
        
        Alamofire.request(CConstants.ServerURL + CConstants.MoreActionServiceURL
            , method:.post
            , parameters: param
            ).responseJSON{ (response) -> Void in
//                print0000("go out", response.result.value )
                if let rtnValue = response.result.value as? Int{
                    if rtnValue == 1 {
                         NotificationCenter.default.post(name: NSNotification.Name(rawValue: CConstants.SubmitNext), object: obj)
                        return
                    }
                }
                 NotificationCenter.default.post(name:NSNotification.Name(rawValue: CConstants.SubmitNext), object: false)
//                self.saveGoOutDataToLocalDB(requiredInfo)  
        }
    }
    
    func saveGoOutDataToLocalDB(_ requiredInfo : MoreActionRequired) {
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



//
//  Tool.swift
//  BA-Clock
//
//  Created by April on 1/14/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Foundation
import Alamofire

class Tool: NSObject {
    func getTime2() -> Bool{
        let date = NSDate()
        //        print(date)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy EEEE"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        
         dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
        
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
    
    func getTimeInter() -> (Bool, NSTimeInterval){
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy EEEE"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
        let today = dateFormatter.stringFromDate(date)
        let index0 = today.startIndex
        let todayDay = today.substringToIndex(index0.advancedBy(10))
        let coreData = cl_coreData()
        
        var send = false
        var rtn : NSTimeInterval = 0
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
                    //        print(required.getPropertieNamesAsDictionary())
                    Alamofire.request(.POST, CConstants.ServerURL + CConstants.RegisterDeviceTokenServiceURL, parameters: required.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                                            print(response.result.value)
                        
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
        dateFormatter.dateFormat =  "yyyy-MM-dd HH:mm:ss"
        let ClientTime = dateFormatter.stringFromDate(d)
        
        callSubmitLocationService(latitude, longitude1: longitude1, time: ClientTime)
    }
    
    
    func callSubmitLocationService(latitude : Double?, longitude1 : Double?, time: String){
        let submitRequired = SubmitLocationRequired()
        submitRequired.Latitude = "\(latitude ?? 0)"
        submitRequired.Longitude = "\(longitude1 ?? 0)"
        submitRequired.ClientTime = time
        
        let log = cl_log()
        log.savedLogToDB(NSDate(), xtype: true, lat: "\(submitRequired.Latitude!) \(submitRequired.Longitude!)")
        
        let OAuthToken = getUserToken()
        submitRequired.Token = OAuthToken.Token
        submitRequired.TokenSecret = OAuthToken.TokenSecret
        
        Alamofire.request(.POST, CConstants.ServerURL + CConstants.SubmitLocationServiceURL, parameters: submitRequired.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                            print(submitRequired.getPropertieNamesAsDictionary(), response.result.value)
            if response.result.isSuccess {
            }else{
                
                if let net = NetworkReachabilityManager() {
                    if net.isReachable {
                        self.callSubmitLocationService(latitude, longitude1: longitude1, time: time)
                    }else{
                        let submitData = cl_submitData()
                        submitData.savedSubmitDataToDB(time, lat: latitude ?? 0 , lng: longitude1 ?? 0, xtype: CConstants.SubmitLocationType)
                    }
                }else{
                    let submitData = cl_submitData()
                    submitData.savedSubmitDataToDB(time, lat: latitude ?? 0 , lng: longitude1 ?? 0, xtype: CConstants.SubmitLocationType)
                }
            }
        }
    }
    
    func syncFrequency(){
        let userInfo = NSUserDefaults.standardUserDefaults()
        if let token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String{
            if let tokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String {
                
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
                Alamofire.request(.POST, CConstants.ServerURL + CConstants.SyncScheduleIntervalURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
//                    print(response.result.value)
                    if response.result.isSuccess {
                        if let rtnValue = response.result.value as? [[String: AnyObject]]{
//                            print(rtnValue)
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
    
    func getFirstQuauterTimeSpace() -> NSTimeInterval{
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH"
        let nowHour = dateFormatter.stringFromDate(date)
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        for i in 0.stride(to: 59, by: 15) {
            
            let now15 = dateFormatter.dateFromString(nowHour + (i == 0 ? ":00:00" : ":\(i):00"))
//            print(nowHour + (i == 0 ? ":00:00" : ":\(i):00"))
            let timeSpace = now15?.timeIntervalSinceDate(date)
            if  timeSpace > 0 {
                return timeSpace!
            }
        }
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let nowHour1 = dateFormatter.stringFromDate(date)
         dateFormatter.dateFormat = "HH"
        let now2 = dateFormatter.stringFromDate(date)
        let a = Int(now2) ?? 0 + 1
        let now15 = dateFormatter.dateFromString(nowHour1 + " \(a)" + ":00:00")
        let timeSpace = now15?.timeIntervalSinceDate(date)
        if  timeSpace > 0 {
            return timeSpace!
        }
        
        return 0
        
    }
    func getClientTime() -> String{
        //        return 60
        let date = NSDate()
        //        print(date)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
        
        let today = dateFormatter.stringFromDate(date)
        
        return today
        
    }
    
    func getClockMsgFormatedTime(date : NSDate) -> String{
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm:ss a"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
        
        let today = dateFormatter.stringFromDate(date)
        
        return today
        
    }
    
    
    func getCurrentInterval1() -> Double{
        //        return 60
        let date = NSDate()
        //        print(date)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy EEEE"
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(name: "America/Chicago")
        
        let today = dateFormatter.stringFromDate(date)
        let index0 = today.startIndex
        let coreData = cl_coreData()
        
        var send = 900.0
        if let frequency = coreData.getFrequencyByWeekdayNm(today.substringFromIndex(index0.advancedBy(11))) {
            send = frequency.ScheduledInterval!.doubleValue * 60.0
        }
        //        print(send)
        return send
        
    }
    
    // MARK: Clock IN/OUT
    func callClockService(isClockIn isClockIn: Bool, clockOutRequiredInfo : ClockOutRequired){
        
        Alamofire.request(.POST, CConstants.ServerURL + (isClockIn ? CConstants.ClockInServiceURL: CConstants.ClockOutServiceURL), parameters: clockOutRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
            if response.result.isSuccess {
                //                print(response.result.value)
                if let _ = response.result.value as? [String: AnyObject]{
//                    let rtn = ClockResponse(dicInfo: rtnValue)
                    
                }else{
                    self.saveClockDataToLocalDB(isClockIn: isClockIn, clockOutRequiredInfo: clockOutRequiredInfo)
                }
                
            }else{
                self.saveClockDataToLocalDB(isClockIn: isClockIn, clockOutRequiredInfo: clockOutRequiredInfo)
            }
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
    func doComeBack(clockOutRequiredInfo : ClockOutRequired){
        
        var param = clockOutRequiredInfo.getPropertieNamesAsDictionary()
        param["ActionType"] = "Come Back"
        
        Alamofire.request(.POST, CConstants.ServerURL + "ComeBack.json", parameters: param).responseJSON{ (response) -> Void in
            if response.result.isSuccess {
                
            }else{
                let cl = cl_submitData()
                cl.savedSubmitDataToDB(clockOutRequiredInfo.ClientTime ?? ""
                    , lat: Double(clockOutRequiredInfo.Latitude ?? "0.0") ?? 0.0
                    , lng: Double(clockOutRequiredInfo.Longitude ?? "0.0") ?? 0.0
                    , xtype: CConstants.ComeBackType)
                
            }
        }
    }
    
    // MARK: GO OUT
    func doGoOutService(requiredInfo : MoreActionRequired){
//        var actionType : String?
//        for i in 0...2 {
//            if checkStatus[i] {
//                switch i{
//                case 0:
//                    actionType = "Lunch"
//                case 1:
//                    actionType = "Personal Reason"
//                default:
//                    actionType = "Company Reason"
//                }
//                break
//            }
//        }
//        let requiredInfo = MoreActionRequired()
//        requiredInfo.ActionType = actionType
//        
//        requiredInfo.Latitude = "\(self.locationManager?.currentLocation?.coordinate.latitude ?? 0)"
//        requiredInfo.Longitude = "\(self.locationManager?.currentLocation?.coordinate.longitude ?? 0)"
//        requiredInfo.HostName = UIDevice.currentDevice().name
//        let tl = Tool()
//        requiredInfo.IPAddress = tl.getWiFiAddress()
//        requiredInfo.ClientTime = tl.getClientTime()
//        let OAuthToken = self.getUserToken()
//        requiredInfo.Token = OAuthToken.Token!
//        //        clockOutRequiredInfo.Token = "asdfaasdf"
//        requiredInfo.TokenSecret = OAuthToken.TokenSecret!
//        requiredInfo.ReasonStart = self.getFormatedDate2(StartTime)
//        requiredInfo.ReasonEnd = self.getFormatedDate2(EndTime)
//        
//        
//        let index = NSIndexPath(forRow: 0, inSection: 3)
//        if let cell = tableView.cellForRowAtIndexPath(index) as? noteTableViewCell {
//            requiredInfo.Reason = cell.txtView.text ?? " "
//        }else{
//            requiredInfo.Reason = " "
//        }
        
        //        print(requiredInfo.getPropertieNamesAsDictionary())
        Alamofire.request(.POST, CConstants.ServerURL + CConstants.MoreActionServiceURL,
            parameters: requiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                
                if let rtnValue = response.result.value as? Int{
                    if rtnValue == 1 {
                        
                    }else{
                        self.saveGoOutDataToLocalDB(requiredInfo)
                    }
                }else{
                    self.saveGoOutDataToLocalDB(requiredInfo)
                }
                
                
        }
    }
    
    func saveGoOutDataToLocalDB(requiredInfo : MoreActionRequired) {
        let cl = cl_submitData()
        cl.savedSubmitDataToDB(requiredInfo.ClientTime ?? ""
            , lat: Double(requiredInfo.Latitude ?? "0.0") ?? 0.0
            , lng: Double(requiredInfo.Latitude ?? "0.0") ?? 0.0
            , reasonStart : requiredInfo.ReasonStart ?? ""
            , reasonEnd : requiredInfo.ReasonEnd  ?? ""
            , reason : requiredInfo.Reason  ?? ""
            , actionType: requiredInfo.ActionType ?? "")
    }
    
}



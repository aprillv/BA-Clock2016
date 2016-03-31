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
            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
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
            }
            freeifaddrs(ifaddr)
        }
        
        return address
    }
    
    
    static func saveDeviceTokenToSever(){
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        let str = userInfo.valueForKey(CConstants.RegisteredDeviceToken) as? String
        if str == nil || str == "0"{
        
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
        }
        
        
        
    }
}



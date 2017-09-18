//
//  cl_submitData.swift
//  BA-Clock
//
//  Created by April on 5/4/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Alamofire

class cl_submitData: NSObject {
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    func savedSubmitDataToDB(_ d: String, lat: Double, lng: Double, reasonStart: String, reasonEnd: String, reason: String, actionType: String){
        let entity =  NSEntityDescription.entity(forEntityName: "SubmitData",
                                                        in:managedObjectContext)
        let scheduledDayItem = NSManagedObject(entity: entity!,
                                               insertInto: managedObjectContext)
        
        scheduledDayItem.setValue(lat, forKey: "latitude")
        scheduledDayItem.setValue(lng, forKey: "longitude")
        scheduledDayItem.setValue(d, forKey: "submitdate")
        scheduledDayItem.setValue(CConstants.GoOutType, forKey: "xtype")
        scheduledDayItem.setValue(reasonStart, forKey: "reasonStart")
        scheduledDayItem.setValue(reasonEnd, forKey: "reasonEnd")
        scheduledDayItem.setValue(reason, forKey: "reason")
        scheduledDayItem.setValue(actionType, forKey: "actionType")
        do {
            try managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func savedSubmitDataToDB(_ d: String, lat: Double, lng: Double, xtype: Int){
        let entity =  NSEntityDescription.entity(forEntityName: "SubmitData",
                                                        in:managedObjectContext)
        let scheduledDayItem = NSManagedObject(entity: entity!,
                                               insertInto: managedObjectContext)
        
        scheduledDayItem.setValue(lat, forKey: "latitude")
        scheduledDayItem.setValue(lng, forKey: "longitude")
        scheduledDayItem.setValue(d, forKey: "submitdate")
        scheduledDayItem.setValue(xtype, forKey: "xtype")
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    
    
    func resubmit(_ last : NSManagedObject?){
        let net = NetworkReachabilityManager()
        if !(net?.isReachable ?? false){
            return
        }
        if last == nil {
            let userInfo = UserDefaults.standard
            if let date = userInfo.value(forKey: CConstants.LastSubmitDateTime) as? Date {
                if Date().timeIntervalSince(date) < 60 {
//                    print0000("dfdfdf")
                    return
                }
            }
            userInfo.setValue(Date(), forKey: CConstants.LastSubmitDateTime)
        }
        
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SubmitData")
        do {
            if let a = last {
                managedObjectContext.delete(a)
                try managedObjectContext.save()
            }
            let results =
                try managedObjectContext.fetch(fetchRequest)
            let tl = Tool()
            if let t = results as? [NSManagedObject] {
//                print0000(t.count)
                for item in t{
//                    print0000(item.valueForKey("xtype") ,item.valueForKey("submitdate"))
                }
                if let item = t.first{
                    let lat =  item.value(forKey: "latitude") as? Double
                    let lng = item.value(forKey: "longitude") as? Double
                    
                    if let xtype = item.value(forKey: "xtype") as? Int,
                        let d = item.value(forKey: "submitdate") as? String{
                        
//
                        switch xtype {
                        case CConstants.ClockInType, CConstants.ClockOutType, CConstants.ComeBackType:
                            let clockOutRequiredInfo : ClockOutRequired = ClockOutRequired()
                            clockOutRequiredInfo.Latitude = "\(lat ?? 0.0 )"
                            clockOutRequiredInfo.Longitude = "\(lng ?? 0.0 )"
                            clockOutRequiredInfo.HostName = UIDevice.current.name
                            clockOutRequiredInfo.IPAddress = tl.getWiFiAddress()
                            clockOutRequiredInfo.ClientTime = d
                            let OAuthToken = tl.getUserToken()
                            clockOutRequiredInfo.Token = OAuthToken.Token!
                            clockOutRequiredInfo.TokenSecret = OAuthToken.TokenSecret!
                            if xtype == CConstants.ComeBackType {
                                tl.doComeBack(clockOutRequiredInfo, obj: item)
                            }else{
                                tl.callClockService(isClockIn: xtype == CConstants.ClockInType, clockOutRequiredInfo: clockOutRequiredInfo, obj: item)
                            }
                        case CConstants.GoOutType:
                            
                            let requiredInfo = MoreActionRequired()
                            requiredInfo.ActionType = (item.value(forKey: "actionType") as? String) ?? ""
                            
                            requiredInfo.Latitude = "\(lat ?? 0.0 )"
                            requiredInfo.Longitude = "\(lng ?? 0.0 )"
                            requiredInfo.HostName = UIDevice.current.name
                            requiredInfo.IPAddress = tl.getWiFiAddress()
                            requiredInfo.ClientTime = d
                            let OAuthToken = tl.getUserToken()
                            requiredInfo.Token = OAuthToken.Token!
                            requiredInfo.TokenSecret = OAuthToken.TokenSecret!
                            requiredInfo.ReasonStart = (item.value(forKey: "reasonStart") as? String) ?? ""
                            requiredInfo.ReasonEnd = (item.value(forKey: "reasonEnd") as? String) ?? ""
                            requiredInfo.Reason = (item.value(forKey: "reason") as? String) ?? ""
                            tl.doGoOutService(requiredInfo, obj: item)
                            
                        default:
                            break
                        }
                        
                    }
                }else{
                    let userInfo = UserDefaults.standard
                    
                    userInfo.setValue("", forKey: CConstants.LastSubmitDateTime)
                }
                
            }
            
//
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
//
    }
}


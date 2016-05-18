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
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    func savedSubmitDataToDB(d: String, lat: Double, lng: Double, reasonStart: String, reasonEnd: String, reason: String, actionType: String){
        let entity =  NSEntityDescription.entityForName("SubmitData",
                                                        inManagedObjectContext:managedObjectContext)
        let scheduledDayItem = NSManagedObject(entity: entity!,
                                               insertIntoManagedObjectContext: managedObjectContext)
        
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
    
    func savedSubmitDataToDB(d: String, lat: Double, lng: Double, xtype: Int){
        let entity =  NSEntityDescription.entityForName("SubmitData",
                                                        inManagedObjectContext:managedObjectContext)
        let scheduledDayItem = NSManagedObject(entity: entity!,
                                               insertIntoManagedObjectContext: managedObjectContext)
        
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
    
    
    
    func resubmit(last : NSManagedObject?){
        let net = NetworkReachabilityManager()
        if !(net?.isReachable ?? false){
            return
        }
        let fetchRequest = NSFetchRequest(entityName: "SubmitData")
        do {
            if let a = last {
                managedObjectContext.deleteObject(a)
                try managedObjectContext.save()
            }
            let results =
                try managedObjectContext.executeFetchRequest(fetchRequest)
            let tl = Tool()
            if let t = results as? [NSManagedObject] {
                if let item = t.first{
                    let lat =  item.valueForKey("latitude") as? Double
                    let lng = item.valueForKey("longitude") as? Double
                    
                    if let xtype = item.valueForKey("xtype") as? Int,
                        let d = item.valueForKey("submitdate") as? String{
                        
//
                        switch xtype {
                        case CConstants.SubmitLocationType:
                            tl.callSubmitLocationService(lat, longitude1: lng, time: d)
                        case CConstants.ClockInType, CConstants.ClockOutType, CConstants.ComeBackType:
                            let clockOutRequiredInfo : ClockOutRequired = ClockOutRequired()
                            clockOutRequiredInfo.Latitude = "\(lat ?? 0.0 )"
                            clockOutRequiredInfo.Longitude = "\(lng ?? 0.0 )"
                            clockOutRequiredInfo.HostName = UIDevice.currentDevice().name
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
                            requiredInfo.ActionType = (item.valueForKey("actionType") as? String) ?? ""
                            
                            requiredInfo.Latitude = "\(lat ?? 0.0 )"
                            requiredInfo.Longitude = "\(lat ?? 0.0 )"
                            requiredInfo.HostName = UIDevice.currentDevice().name
                            requiredInfo.IPAddress = tl.getWiFiAddress()
                            requiredInfo.ClientTime = d
                            let OAuthToken = tl.getUserToken()
                            requiredInfo.Token = OAuthToken.Token!
                            requiredInfo.TokenSecret = OAuthToken.TokenSecret!
                            requiredInfo.ReasonStart = (item.valueForKey("reasonStart") as? String) ?? ""
                            requiredInfo.ReasonEnd = (item.valueForKey("reasonEnd") as? String) ?? ""
                            requiredInfo.Reason = (item.valueForKey("reason") as? String) ?? ""
                            tl.doGoOutService(requiredInfo, obj: item)
                            
                        default:
                            break
                        }
                        
                    }
                }
                
            }
            
//
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
}


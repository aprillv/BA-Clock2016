//
//  cl_showSchedule.swift
//  BA-Clock
//
//  Created by April on 5/17/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class cl_showSchedule: NSObject {
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    func savedSubmitDataToDB(item : ScheduledDayItem){
        let entity =  NSEntityDescription.entityForName("ShowSchedule",
                                                        inManagedObjectContext:managedObjectContext)
        let sitem = NSManagedObject(entity: entity!,
                                               insertIntoManagedObjectContext: managedObjectContext)
        
        sitem.setValue(item.ClockIn, forKey: "clockIn")
        sitem.setValue(item.ClockInCoordinate?.Latitude ?? 0.0, forKey: "clockInCoordinate_lat")
        sitem.setValue(item.ClockInCoordinate?.Longitude ?? 0.0, forKey: "clockInCoordinate_lng")
        sitem.setValue(item.ClockInDay, forKey: "clockInDay")
        sitem.setValue(item.ClockInDayFullName, forKey: "clockInDayFullName")
        sitem.setValue(item.ClockInName, forKey: "clockInName")
        sitem.setValue(item.ClockOut, forKey: "clockOut")
        sitem.setValue(item.ClockOutCoordinate?.Latitude ?? 0.0, forKey: "clockOutCoordinate_lat")
        sitem.setValue(item.ClockOutCoordinate?.Longitude ?? 0.0, forKey: "clockOutCoordinate_lng")
        sitem.setValue(item.ClockOutDay, forKey: "clockOutDay")
        sitem.setValue(item.ClockOutDayFullName, forKey: "clockOutDayFullName")
        sitem.setValue(item.ClockOutName, forKey: "clockOutName")
        sitem.setValue(item.Hours, forKey: "hours")
        sitem.setValue(item.clockInDateDay, forKey: "clockInDate")
        sitem.setValue(item.clockOutDateDay, forKey: "clockOutDate")
        do {
            try managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func updateLastItem(item : ScheduledDayItem) {
//        var rtn = [ScheduledDayItem]()
        let fetchRequest = NSFetchRequest(entityName: "ShowSchedule")
        do {
            let results =
                try managedObjectContext.executeFetchRequest(fetchRequest)
            //            let tl = Tool()
            if let t = results as? [NSManagedObject] {
                if let sitem = t.last {
//                    sitem.setValue(item.ClockIn, forKey: "clockIn")
//                    sitem.setValue(item.ClockInCoordinate?.Latitude ?? 0.0, forKey: "clockInCoordinate_lat")
//                    sitem.setValue(item.ClockInCoordinate?.Longitude ?? 0.0, forKey: "clockInCoordinate_lng")
//                    sitem.setValue(item.ClockInDay, forKey: "clockInDay")
//                    sitem.setValue(item.ClockInDayFullName, forKey: "clockInDayFullName")
//                    sitem.setValue(item.ClockInName, forKey: "clockInName")
                    sitem.setValue(item.ClockOut, forKey: "clockOut")
                    sitem.setValue(item.ClockOutCoordinate?.Latitude ?? 0.0, forKey: "clockOutCoordinate_lat")
                    sitem.setValue(item.ClockOutCoordinate?.Longitude ?? 0.0, forKey: "clockOutCoordinate_lng")
                    sitem.setValue(item.ClockOutDay, forKey: "clockOutDay")
                    sitem.setValue(item.ClockOutDayFullName, forKey: "clockOutDayFullName")
                    sitem.setValue(item.ClockOutName, forKey: "clockOutName")
                    sitem.setValue(item.Hours, forKey: "hours")
//                    sitem.setValue(item.clockInDateDay, forKey: "clockInDate")
                    sitem.setValue(item.clockOutDateDay, forKey: "clockOutDate")
                }
            }
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
//        return rtn
        
    }
    
    
    func getScheduledList() -> [ScheduledDayItem]{
        var rtn = [ScheduledDayItem]()
        let fetchRequest = NSFetchRequest(entityName: "ShowSchedule")
        do {
            let results =
                try managedObjectContext.executeFetchRequest(fetchRequest)
//            let tl = Tool()
            if let t = results as? [NSManagedObject] {
                for item : NSManagedObject in t {
                    
                    let sitem = ScheduledDayItem(dicInfo: nil)
                    sitem.ClockInCoordinate = CoordinateObject(dicInfo: nil)
                    sitem.ClockOutCoordinate = CoordinateObject(dicInfo: nil)
                    
                    sitem.ClockIn =  item.valueForKey("clockIn") as? String
                    sitem.ClockInCoordinate!.Latitude = item.valueForKey("clockInCoordinate_lat") as? Double
                    sitem.ClockInCoordinate!.Longitude =  item.valueForKey("clockInCoordinate_lng") as? Double
                    sitem.ClockInDay = item.valueForKey("clockInDay") as? String
                    sitem.ClockInDayFullName = item.valueForKey("clockInDayFullName") as? String
                    sitem.ClockInName = item.valueForKey("clockInName") as? String
                    sitem.ClockOut =  item.valueForKey("clockOut") as? String
                    sitem.ClockOutCoordinate!.Latitude = item.valueForKey("clockOutCoordinate_lat") as? Double
                    sitem.ClockOutCoordinate!.Longitude =  item.valueForKey("clockOutCoordinate_lng") as? Double
                    sitem.ClockOutDay = item.valueForKey("clockOutDay") as? String
                    sitem.ClockOutDayFullName = item.valueForKey("clockOutDayFullName") as? String
                    sitem.ClockOutName = item.valueForKey("clockOutName") as? String
                    sitem.Hours = item.valueForKey("hours") as? Double
                    sitem.clockInDateDay = item.valueForKey("clockInDate") as? String
                    sitem.clockOutDateDay = item.valueForKey("clockOutDate") as? String
                    rtn.append(sitem)
                }
                
            }
//            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return rtn
        
    }
    
}

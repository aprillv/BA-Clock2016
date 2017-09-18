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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    func savedSubmitDataToDB(_ item : ScheduledDayItem){
//        print(item.ClockInCoordinate?.Latitude)
        let entity =  NSEntityDescription.entity(forEntityName: "ShowSchedule",
                                                        in:managedObjectContext)
        let sitem = NSManagedObject(entity: entity!,
                                               insertInto: managedObjectContext)
        
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
    
    func updateLastItem(_ item : ScheduledDayItem) {
//        var rtn = [ScheduledDayItem]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShowSchedule")
        do {
            let results =
                try managedObjectContext.fetch(fetchRequest)
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
                }else{
                    return savedSubmitDataToDB(item)
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ShowSchedule")
        do {
            let results =
                try managedObjectContext.fetch(fetchRequest)
//            let tl = Tool()
            if let t = results as? [NSManagedObject] {
                for item : NSManagedObject in t {
                    
                    let sitem = ScheduledDayItem(dicInfo: nil)
                    sitem.ClockInCoordinate = CoordinateObject(dicInfo: nil)
                    sitem.ClockOutCoordinate = CoordinateObject(dicInfo: nil)
                    
                    sitem.ClockIn =  item.value(forKey: "clockIn") as? String
                    sitem.ClockInCoordinate!.Latitude = item.value(forKey: "clockInCoordinate_lat") as? Double as! NSNumber
                    sitem.ClockInCoordinate!.Longitude =  item.value(forKey: "clockInCoordinate_lng") as? Double as! NSNumber
                    sitem.ClockInDay = item.value(forKey: "clockInDay") as? String
                    sitem.ClockInDayFullName = item.value(forKey: "clockInDayFullName") as? String
                    sitem.ClockInName = item.value(forKey: "clockInName") as? String
                    sitem.ClockOut =  item.value(forKey: "clockOut") as? String
                    sitem.ClockOutCoordinate!.Latitude = item.value(forKey: "clockOutCoordinate_lat") as? Double as! NSNumber
                    sitem.ClockOutCoordinate!.Longitude =  item.value(forKey: "clockOutCoordinate_lng") as? Double as! NSNumber
                    sitem.ClockOutDay = item.value(forKey: "clockOutDay") as? String
                    sitem.ClockOutDayFullName = item.value(forKey: "clockOutDayFullName") as? String
                    sitem.ClockOutName = item.value(forKey: "clockOutName") as? String
                    sitem.Hours = item.value(forKey: "hours") as? Double as! NSNumber
                    sitem.clockInDateDay = item.value(forKey: "clockInDate") as? String
                    sitem.clockOutDateDay = item.value(forKey: "clockOutDate") as? String
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

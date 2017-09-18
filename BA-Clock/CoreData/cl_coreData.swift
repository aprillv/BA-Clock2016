//
//  cl_clockData.swift
//  BA-Clock
//
//  Created by April on 1/20/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class cl_coreData: NSObject {
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
//    func savedScheduledDaysToDB(itemList : [ScheduledDayItem]){
//        return
//        let fetchRequest = NSFetchRequest(entityName: "ScheduledDay")
//        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        do {
//            try persistentStoreCoordinator.executeRequest(request, withContext: managedObjectContext)
//            for item : ScheduledDayItem in itemList {
//                let entity =  NSEntityDescription.entityForName("ScheduledDay",
//                    inManagedObjectContext:managedObjectContext)
//                
//                let scheduledDayItem = NSManagedObject(entity: entity!,
//                    insertIntoManagedObjectContext: managedObjectContext)
//                
//                
//                
//                scheduledDayItem.setValue(item.ClockIn!, forKey: "clockIn")
//                scheduledDayItem.setValue(item.ClockInCoordinate!.Latitude!, forKey: "clockInLatitude")
//                scheduledDayItem.setValue(item.ClockInCoordinate!.Longitude!, forKey: "clockInLongitude")
//                scheduledDayItem.setValue(item.ClockInDay!, forKey: "clockInDay")
//                scheduledDayItem.setValue(item.ClockInDayFullName!, forKey: "ClockInDayFullName")
//                scheduledDayItem.setValue(item.ClockInDayName!, forKey: "ClockInDayName")
//                scheduledDayItem.setValue(item.ClockInDayOfWeek!, forKey: "ClockInDayOfWeek")
//                scheduledDayItem.setValue(item.ClockOut!, forKey: "clockOut")
//                scheduledDayItem.setValue(item.ClockOutCoordinate!.Latitude!, forKey: "clockOutLatitude")
//                scheduledDayItem.setValue(item.ClockOutCoordinate!.Longitude!, forKey: "clockOutLatitude")
//                scheduledDayItem.setValue(item.ClockOutDay!, forKey: "ClockOutDay")
//                scheduledDayItem.setValue(item.ClockOutDayFullName!, forKey: "ClockOutDayFullName")
//                scheduledDayItem.setValue(item.ClockOutDayName!, forKey: "ClockOutDayName")
//                scheduledDayItem.setValue(item.ClockOutDayOfWeek!, forKey: "ClockOutDayOfWeek")
//                scheduledDayItem.setValue(item.Hours!, forKey: "Hours")
//                
//                
//                do {
//                    try managedObjectContext.save()
//                    
//                } catch let error as NSError  {
//                    print0000("Could not save \(error), \(error.userInfo)")
//                }
//            }
//            
//        } catch let error as NSError {
//            print0000("\(error)")
//            // TODO: handle the error
//        }
//        
//    
//
//    }
    
    func savedFrequencysToDB(_ itemList : [FrequencyItem]){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Frequency")
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try persistentStoreCoordinator.execute(request, with: managedObjectContext)
            for item : FrequencyItem in itemList {
                let entity =  NSEntityDescription.entity(forEntityName: "Frequency",
                    in:managedObjectContext)
                
                let scheduledDayItem = NSManagedObject(entity: entity!,
                    insertInto: managedObjectContext)
                
                scheduledDayItem.setValue(item.DayFullName!, forKey: "dayFullName")
                scheduledDayItem.setValue(item.DayName!, forKey: "dayName")
                scheduledDayItem.setValue(item.DayOfWeek!, forKey: "dayOfWeek")
                scheduledDayItem.setValue(item.ScheduledFrom ?? "08:00 AM", forKey: "scheduledFrom")
                scheduledDayItem.setValue(item.ScheduledInterval!, forKey: "scheduledInterval")
                scheduledDayItem.setValue(item.ScheduledTo ?? "05:30 PM", forKey: "scheduledTo")
                do {
                    try managedObjectContext.save()
                    
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }
            
        } catch let error as NSError {
//            print0000("\(error)")
            // TODO: handle the error
        }
        
        
        
    }
    
    func getFrequencyByWeekdayNm(_ weekdayNm: String) -> FrequencyItem?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Frequency")
        let predicate = NSPredicate(format: "dayFullName = %@", weekdayNm)
        fetchRequest.predicate = predicate
        
        //3
        do {
            let results =
            try managedObjectContext.fetch(fetchRequest)
            if let t = results as? [NSManagedObject] {
                if let item : NSManagedObject = t.first {
                    let tmp : FrequencyItem = FrequencyItem(dicInfo : nil)
                    tmp.DayFullName = item.value(forKey: "dayFullName") as? String
                    tmp.DayOfWeek = item.value(forKey: "dayOfWeek") as? NSNumber
                    tmp.DayName = item.value(forKey: "dayName") as? String
                    tmp.ScheduledFrom = item.value(forKey: "scheduledFrom") as? String
                    tmp.ScheduledInterval = item.value(forKey: "scheduledInterval") as? NSNumber
                    tmp.ScheduledTo = item.value(forKey: "scheduledTo") as? String
                    return tmp
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    
    }
    
    func getAllFrequency() -> [FrequencyItem]{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Frequency")
//        let predicate = NSPredicate(format: "dayFullName = %@", weekdayNm)
//        fetchRequest.predicate = predicate
        
        var rtn = [FrequencyItem]()
        //3
        do {
            let results =
                try managedObjectContext.fetch(fetchRequest)
            if let t = results as? [NSManagedObject] {
                for item in t {
                    let tmp : FrequencyItem = FrequencyItem(dicInfo : nil)
                    tmp.DayFullName = item.value(forKey: "dayFullName") as? String
                    tmp.DayOfWeek = item.value(forKey: "dayOfWeek") as? NSNumber
                    tmp.DayName = item.value(forKey: "dayName") as? String
                    tmp.ScheduledFrom = item.value(forKey: "scheduledFrom") as? String
                    tmp.ScheduledInterval = item.value(forKey: "scheduledInterval") as? NSNumber
                    tmp.ScheduledTo = item.value(forKey: "scheduledTo") as? String
                    rtn.append(tmp)
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return rtn
        
    }
    
}

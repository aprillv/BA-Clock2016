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
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    func savedScheduledDaysToDB(itemList : [ScheduledDayItem]){

        let fetchRequest = NSFetchRequest(entityName: "ScheduledDay")
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try persistentStoreCoordinator.executeRequest(request, withContext: managedObjectContext)
            for item : ScheduledDayItem in itemList {
                let entity =  NSEntityDescription.entityForName("ScheduledDay",
                    inManagedObjectContext:managedObjectContext)
                
                let scheduledDayItem = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext: managedObjectContext)
                
                
                
                scheduledDayItem.setValue(item.ClockIn!, forKey: "clockIn")
                scheduledDayItem.setValue(item.ClockInCoordinate!.Latitude!, forKey: "clockInLatitude")
                scheduledDayItem.setValue(item.ClockInCoordinate!.Longitude!, forKey: "clockInLongitude")
                scheduledDayItem.setValue(item.ClockInDay!, forKey: "clockInDay")
                scheduledDayItem.setValue(item.ClockInDayFullName!, forKey: "ClockInDayFullName")
                scheduledDayItem.setValue(item.ClockInDayName!, forKey: "ClockInDayName")
                scheduledDayItem.setValue(item.ClockInDayOfWeek!, forKey: "ClockInDayOfWeek")
                scheduledDayItem.setValue(item.ClockOut!, forKey: "clockOut")
                scheduledDayItem.setValue(item.ClockOutCoordinate!.Latitude!, forKey: "clockOutLatitude")
                scheduledDayItem.setValue(item.ClockOutCoordinate!.Longitude!, forKey: "clockOutLatitude")
                scheduledDayItem.setValue(item.ClockOutDay!, forKey: "ClockOutDay")
                scheduledDayItem.setValue(item.ClockOutDayFullName!, forKey: "ClockOutDayFullName")
                scheduledDayItem.setValue(item.ClockOutDayName!, forKey: "ClockOutDayName")
                scheduledDayItem.setValue(item.ClockOutDayOfWeek!, forKey: "ClockOutDayOfWeek")
                scheduledDayItem.setValue(item.Hours!, forKey: "Hours")
                
                
                do {
                    try managedObjectContext.save()
                    
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }
            
        } catch let error as NSError {
            print("\(error)")
            // TODO: handle the error
        }
        
    

    }
    
    func savedFrequencysToDB(itemList : [FrequencyItem]){
        
        let fetchRequest = NSFetchRequest(entityName: "Frequency")
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try persistentStoreCoordinator.executeRequest(request, withContext: managedObjectContext)
            for item : FrequencyItem in itemList {
                let entity =  NSEntityDescription.entityForName("Frequency",
                    inManagedObjectContext:managedObjectContext)
                
                let scheduledDayItem = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext: managedObjectContext)
                
                scheduledDayItem.setValue(item.DayFullName!, forKey: "dayFullName")
                scheduledDayItem.setValue(item.DayName!, forKey: "dayName")
                scheduledDayItem.setValue(item.DayOfWeek!, forKey: "dayOfWeek")
                scheduledDayItem.setValue(item.ScheduledFrom!, forKey: "scheduledFrom")
                scheduledDayItem.setValue(item.ScheduledInterval!, forKey: "scheduledInterval")
                scheduledDayItem.setValue(item.ScheduledTo!, forKey: "scheduledTo")
                do {
                    try managedObjectContext.save()
                    
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            }
            
        } catch let error as NSError {
            print("\(error)")
            // TODO: handle the error
        }
        
        
        
    }
    
    func getFrequencyByWeekdayNm(weekdayNm: String) -> FrequencyItem?{
        let fetchRequest = NSFetchRequest(entityName: "Frequency")
        let predicate = NSPredicate(format: "dayFullName = %@", weekdayNm)
        fetchRequest.predicate = predicate
        
        //3
        do {
            let results =
            try managedObjectContext.executeFetchRequest(fetchRequest)
            if let t = results as? [NSManagedObject] {
                if let item : NSManagedObject = t.first {
                    let tmp : FrequencyItem = FrequencyItem(dicInfo : nil)
                    tmp.DayFullName = item.valueForKey("dayFullName") as? String
                    tmp.DayOfWeek = item.valueForKey("dayOfWeek") as? NSNumber
                    tmp.DayName = item.valueForKey("dayName") as? String
                    tmp.ScheduledFrom = item.valueForKey("scheduledFrom") as? String
                    tmp.ScheduledInterval = item.valueForKey("scheduledInterval") as? NSNumber
                    tmp.ScheduledTo = item.valueForKey("scheduledTo") as? String
                    return tmp
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    
    }
}

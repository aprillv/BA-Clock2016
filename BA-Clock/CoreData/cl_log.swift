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

class cl_log: NSObject {
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    func savedLogToDB(d: NSDate, xtype: Bool, lat: String){
        
//        let fetchRequest = NSFetchRequest(entityName: "LogFile")
//        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
//            try persistentStoreCoordinator.executeRequest(request, withContext: managedObjectContext)
           
                let entity =  NSEntityDescription.entityForName("LogFile",
                    inManagedObjectContext:managedObjectContext)
                
                let scheduledDayItem = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext: managedObjectContext)
                
                
                
                scheduledDayItem.setValue(lat, forKey: "latlng")
                scheduledDayItem.setValue(xtype, forKey: "xtype")
                scheduledDayItem.setValue("\(d)", forKey: "time")
            
                
                
                do {
                    try managedObjectContext.save()
                    
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            
            
        } catch let error as NSError {
            print("\(error)")
            // TODO: handle the error
        }
        
        
        
    }
    
  
    
    func getLogs() -> [logs]?{
        let fetchRequest = NSFetchRequest(entityName: "LogFile")
        let predicate = NSPredicate(format: "time BEGINSWITH[cd] %@", "2016")
        fetchRequest.predicate = predicate
        do {
            let results =
            try managedObjectContext.executeFetchRequest(fetchRequest)
            var c  = [logs]()
            if let t = results as? [NSManagedObject] {
                for item : NSManagedObject in t {
                    let c1 = logs(dicInfo: nil)
                    c1.time = item.valueForKey("time") as? String
                    c1.xtype = item.valueForKey("xtype") as? Bool
                    c1.latlng = item.valueForKey("latlng") as? String
                    c.append(c1)
                }
                
            }
            return c
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
        
    }
}

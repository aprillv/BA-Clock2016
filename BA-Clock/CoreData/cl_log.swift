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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    func savedLogToDB(_ d: Date, xtype: Bool, lat: String){
        
        let userInfo = UserDefaults.standard
        let title = userInfo.value(forKey: CConstants.UserFullName) as? String
        
        if !(title == "April" || title == "april Lv" || title == "jack fan" || title == "Bob Xia" || title == "Apple"){
            return
        }
        
//        let fetchRequest = NSFetchRequest(entityName: "LogFile")
//        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        do {
//            try persistentStoreCoordinator.executeRequest(request, withContext: managedObjectContext)
           
                let entity =  NSEntityDescription.entity(forEntityName: "LogFile",
                    in:managedObjectContext)
                
                let scheduledDayItem = NSManagedObject(entity: entity!,
                    insertInto: managedObjectContext)
                
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(identifier: "America/Chicago")
//        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.locale = Locale(identifier : "en_US")
            dateFormatter.dateFormat =  "MM/dd hh:mm a"
            let nowHour = dateFormatter.string(from: d)
            
            scheduledDayItem.setValue(lat, forKey: "latlng")
            scheduledDayItem.setValue(xtype, forKey: "xtype")
            scheduledDayItem.setValue(nowHour, forKey: "time")
            
            
                
                do {
                    try managedObjectContext.save()
                    
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                }
            
            
//        } catch let error as NSError {
//            print0000("\(error)")
//            // TODO: handle the error
//        }
        
        
        
    }
    
  
    
    func getLogs() -> [logs]?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LogFile")
//        let predicate = NSPredicate(format: "time BEGINSWITH[cd] %@", "2016")
//        fetchRequest.predicate = predicate
        do {
            let results =
            try managedObjectContext.fetch(fetchRequest)
            var c  = [logs]()
            if let t = results as? [NSManagedObject] {
                for item : NSManagedObject in t {
                    let c1 = logs(dicInfo: nil)
                    c1.time = item.value(forKey: "time") as? String
                    c1.xtype = item.value(forKey: "xtype") as? Bool
                    c1.latlng = item.value(forKey: "latlng") as? String
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

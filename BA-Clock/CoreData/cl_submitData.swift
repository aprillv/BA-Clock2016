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

class cl_submitData: NSObject {
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    func savedSubmitDataToDB(d: String, lat: Double, lng: Double){
        let entity =  NSEntityDescription.entityForName("SubmitData",
                                                        inManagedObjectContext:managedObjectContext)
        let scheduledDayItem = NSManagedObject(entity: entity!,
                                               insertIntoManagedObjectContext: managedObjectContext)
        
        scheduledDayItem.setValue(lat, forKey: "latitude")
        scheduledDayItem.setValue(lng, forKey: "longitude")
        scheduledDayItem.setValue(d, forKey: "submitdate")
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    
    
    func resubmit(){
        let fetchRequest = NSFetchRequest(entityName: "SubmitData")
        do {
            let results =
                try managedObjectContext.executeFetchRequest(fetchRequest)
            let tl = Tool()
            if let t = results as? [NSManagedObject] {
                for item : NSManagedObject in t {
                    let lat =  item.valueForKey("latitude") as? Double
                    let lng = item.valueForKey("longitude") as? Double
                    if let d = item.valueForKey("submitdate") as? String{
                        managedObjectContext.deleteObject(item)
                        tl.callSubmitLocationService(lat, longitude1: lng, time: d)
                    }
                }
                
            }
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
}


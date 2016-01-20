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

class cl_clockData: NSObject {
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    func savedToDB(){

        let fetchRequest = NSFetchRequest(entityName: "ClockData")
        let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try persistentStoreCoordinator.executeRequest(request, withContext: managedObjectContext)
            
        } catch let error as NSError {
            // TODO: handle the error
        }
        
    

    }
}

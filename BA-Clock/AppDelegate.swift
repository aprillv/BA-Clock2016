//
//  AppDelegate.swift
//  BA-Clock
//
//  Created by April on 1/7/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private func clearNotifications(){
//        print0000("sss")
        UIApplication.sharedApplication().applicationIconBadgeNumber = -1
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
    }
    
   
//    func applicationWillEnterForeground(application: UIApplication){
////        print0000("aadsfdfd");
//        let locaitonManager = CLocationManager.sharedInstance
//        locaitonManager.updateLocation()
//    }
    
//    
//    func donextSubmit(n: NSNotification) {
//        let cl = cl_submitData()
//        if let sdata = n.object as? NSManagedObject {
//            cl.resubmit(sdata)
//        }else{
//            cl.resubmit(nil)
//        }
//    }
    
//    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
//        print("4444@@@@", notification.alertBody)
//        CLocationManager.sharedInstance.startUpdatingLocation()
//    }
//    
//    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
////        print("@@@@", notification.alertBody)
//        CLocationManager.sharedInstance.startUpdatingLocation()
//    }
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//         print0000("\(NSDate()) didFinishLaunchingWithOptions")
        
       clearNotifications()
        let userInfo = NSUserDefaults.standardUserDefaults()
        userInfo.setValue(NSDate(), forKey: CConstants.LoginedDate)
        userInfo.setBool(true, forKey: CConstants.ToAddTrack)
        userInfo.setBool(false, forKey: CConstants.LocationServericeChanged)
//        checkUpate()
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(donextSubmit(_:)), name: CConstants.SubmitNext, object: nil)
        
        self.window?.backgroundColor = UIColor.whiteColor()
//        print0000(CLLocationManager.locationServicesEnabled())
        
        
        let net = NetworkReachabilityManager()
        net?.startListening()
        
        net?.listener = {status in
           
            if  net?.isReachable ?? false {
//                 print0000(net?.isReachable, status, NSDate())
//                let userInfo = NSUserDefaults.standardUserDefaults()
//                userInfo.setBool(true, forKey: "openApp")
                let sd = cl_submitData()
                sd.resubmit(nil)
            }
            else {
                //                print0000("no connection")
            }
            
        }
        
        
//
        initializeNotificationServices()
        
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Selected)
        
        
        let storyboard = UIStoryboard(name: CConstants.StoryboardName, bundle: nil)
        
//        let userInfo = NSUserDefaults.standardUserDefaults()
//        userInfo.setBool(true, forKey: CConstants.ToAddTrack)
        
        var storyid : String?
        if let _ = userInfo.objectForKey(CConstants.UserInfoPwd) as? String{
            if let _ = userInfo.objectForKey(CConstants.UserInfoEmail) as? String {
                storyid = CConstants.ListStoryBoardId
            }
        }
        let rootController = storyboard.instantiateViewControllerWithIdentifier(storyid ?? CConstants.LoginStoryBoardId) as UIViewController
        
        if let nav = self.window?.rootViewController as? UINavigationController{
            
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            
            nav.pushViewController(rootController, animated: true)
        }
        return true
        
        
    }

    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var deviceTokenStr = "\(deviceToken)"
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString(" ", withString: "")
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString("<", withString: "")
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString(">", withString: "")
//        print0000(deviceTokenStr)
        let userInfo = NSUserDefaults.standardUserDefaults()
        userInfo.setValue(deviceTokenStr, forKey: CConstants.UserDeviceToken)
        
        
        // ...register device token with our Time Entry API server via REST
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Device token for push notifications: FAIL -- ")
//        print0000(error.description)
    }
    
    func initializeNotificationServices() -> Void {
        
//        var type = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound];
        let setting = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound], categories: nil);
        UIApplication.sharedApplication().registerUserNotificationSettings(setting);
        UIApplication.sharedApplication().registerForRemoteNotifications();
        
//        let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Sound , UIUserNotificationType.Alert , UIUserNotificationType.Badge], categories: nil)
//        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
//        
//        // This is an asynchronous method to retrieve a Device Token
//        // Callbacks are in AppDelegate.swift
//        // Success = didRegisterForRemoteNotificationsWithDeviceToken
//        // Fail = didFailToRegisterForRemoteNotificationsWithError
//        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        print("fort tessssssss")
        // display the userInfo
        
        if let aps = userInfo["aps"] as? NSDictionary {
            
//            print(aps.count, aps.allKeys)
            for vaa in aps.allKeys {
                if let s = vaa as? String {
                    if s == "content-available" {
//                        switch CLLocationManager.authorizationStatus() {
//                        case .AuthorizedAlways:
//                            print("AuthorizedAlways")
//                        default:
//                            print("other")
//                        }
//                        print(CLLocationManager.authorizationStatus())
                        var bgtask : UIBackgroundTaskIdentifier
                        bgtask = application.beginBackgroundTaskWithExpirationHandler({
                            CLocationManager.sharedInstance.startUpdatingLocation()
                        })
                    }
                }
            }
            
                UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                
                // call the completion handler
                // -- pass in NoData, since no new data was fetched from the server.
                completionHandler(UIBackgroundFetchResult.NoData)
        }
    }
    
    

    func applicationDidBecomeActive(application: UIApplication) {
        CLocationManager.sharedInstance.startUpdatingLocation()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        CLocationManager.sharedInstance.stopUpdatingLocation()
        NSNotificationCenter.defaultCenter().postNotificationName(CConstants.AppTerminal, object: nil)
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ba.BA_Clock" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("BA_Clock", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
   
    
    func applicationDidEnterBackground(application: UIApplication) {
//        print0000("\(NSDate()) applicationDidEnterBackground")
//      print0000("_______________")
         clearNotifications()
    }
    
    
    var  backgroundUpdateTask : UIBackgroundTaskIdentifier?
    
    func applicationWillResignActive(application: UIApplication) {
//        print("&&&&&&&&&&&&&&&&&&")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//        backgroundUpdateTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ 
//            self.endBackgroundUpdateTask()
//        })
    }
    
    func  endBackgroundUpdateTask() {
//        if self.backgroundUpdateTask != nil{
//            UIApplication.sharedApplication().endBackgroundTask(self.backgroundUpdateTask!)
//            self.backgroundUpdateTask = UIBackgroundTaskInvalid
//        }
        
    }
    
    

    
    func applicationWillEnterForeground(application: UIApplication) {
//        for win in UIApplication.sharedApplication().windows {
//            let a = win.subviews
//            if a.count > 0 {
//                for vi in a {
//                    if vi .isKindOfClass(UIAlertController)
//                }
//            }
//        }
        CLocationManager.sharedInstance.updateLocation()
        let c = UIApplication.sharedApplication().keyWindow?.rootViewController
        if let a = c?.presentedViewController as? UIAlertController {
            if a.message == CConstants.TurnOnLocationServiceMsg {
                let status = CLLocationManager.authorizationStatus()
                if status == .AuthorizedAlways{
                    c?.dismissViewControllerAnimated(true){}
                }
            }
            
        }else{
            let status = CLLocationManager.authorizationStatus()
            if status != .AuthorizedAlways && status != .NotDetermined{
                NSNotificationCenter.defaultCenter().postNotificationName(CConstants.LocationServericeChanged, object: nil)
            }
        }
        
        
//        endBackgroundUpdateTask()
    }
//
    

}



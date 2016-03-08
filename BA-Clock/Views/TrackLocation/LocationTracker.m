//
//  LocationTracker.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location All rights reserved.
//

#import "LocationTracker.h"

#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define ACCURACY @"theAccuracy"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation LocationTracker

+ (CLLocationManager *)sharedLocationManager {
	static CLLocationManager *_locationManager;
	
	@synchronized(self) {
		if (_locationManager == nil) {
			_locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            _locationManager.distanceFilter = 10.0;
			_locationManager.allowsBackgroundLocationUpdates = YES;
			_locationManager.pausesLocationUpdatesAutomatically = NO;
		}
	}
	return _locationManager;
}

- (id)init {
	if (self==[super init]) {
        //Get the share model and also initialize myLocationArray
        self.shareModel = [LocationShareModel sharedModel];
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
	return self;
}

-(void)applicationEnterBackground{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.distanceFilter = 10.0;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    //Use the BackgroundTaskManager to manage all the background Task
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
}

- (void) restartLocationUpdates
{
//    NSLog(@"restartLocationUpdates");
    
//    // 初始化本地通知对象
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    if (notification) {
//        // 设置通知的提醒时间
//        NSDate *currentDate   = [NSDate date];
//        notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
//        notification.fireDate = [currentDate dateByAddingTimeInterval:5.0];
//        
//        // 设置重复间隔
//        notification.repeatInterval = kCFCalendarUnitDay;
//        
//        // 设置提醒的文字内容
//        notification.alertBody   = @"Wake up, man";
//        notification.alertAction = NSLocalizedString(@"起床了", nil);
//        
//        // 通知提示音 使用默认的
//        notification.soundName= UILocalNotificationDefaultSoundName;
//        
//        // 设置应用程序右上角的提醒个数
//        notification.applicationIconBadgeNumber++;
//        
//        // 设定通知的userInfo，用来标识该通知
//        NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
////        aUserInfo[@"sss"] = @"LocalNotificationID";
//        notification.userInfo = aUserInfo;
//        
//        // 将通知添加到系统中
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//    }
    
    
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    locationManager.distanceFilter = 10.0;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
}


- (void)startLocationTracking {
//    NSLog(@"startLocationTracking");

	if ([CLLocationManager locationServicesEnabled] == NO) {
//        NSLog(@"locationServicesEnabled false");
        
//        et alert: UIAlertController = UIAlertController(title: CConstants.MsgTitle, message: msg1, preferredStyle: .Alert)
//        
//        //Create and add the OK action
//        let oKAction: UIAlertAction = UIAlertAction(title: CConstants.MsgOKTitle, style: .Cancel) { action -> Void in
//            //Do some stuff
//            txtField?.becomeFirstResponder()
//        }
//        alert.addAction(oKAction)
//        
//        
//        //Present the AlertController
//        self.presentViewController(alert, animated: true, completion: nil)
        
//         initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil
//        UIAlertController *servicesDisabledAlert = [[UIAlertController alloc] init];
//        servicesDisabledAlert.title = @"BA Clock";
//        servicesDisabledAlert.message = @"You currently have all location services for this device disabled";
//        UIAlertAction *ok = [[UIAlertAction alloc]init];
//        [servicesDisabledAlert addAction:ok];
    
        
        
        
	} else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
//            NSLog(@"authorizationStatus failed");
        } else {
//            NSLog(@"authorizationStatus authorized");
            CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
            locationManager.delegate = self;
//            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            locationManager.distanceFilter = 10.0;
            if(IS_OS_8_OR_LATER) {
              [locationManager requestAlwaysAuthorization];
            }
            [locationManager startUpdatingLocation];
        }
	}
}


- (void)stopLocationTracking {
//    NSLog(@"stopLocationTracking");
    
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    
	CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
	[locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
//    NSLog(@"locationManager didUpdateLocations");
    
    for(int i=0;i<locations.count;i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        
        if (locationAge > 30.0)
        {
            continue;
        }
        
        //Select only valid location and also location with good accuracy
        if(newLocation!=nil&&theAccuracy>0
           &&theAccuracy<2000
           &&(!(theLocation.latitude==0.0&&theLocation.longitude==0.0))){
            
            self.myLastLocation = theLocation;
            self.myLastLocationAccuracy= theAccuracy;
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
            [dict setObject:[NSNumber numberWithFloat:theLocation.latitude] forKey:@"latitude"];
            [dict setObject:[NSNumber numberWithFloat:theLocation.longitude] forKey:@"longitude"];
            [dict setObject:[NSNumber numberWithFloat:theAccuracy] forKey:@"theAccuracy"];
            
            //Add the vallid location with good accuracy into an array
            //Every 1 minute, I will select the best location based on accuracy and send to server
            [self.shareModel.myLocationArray addObject:dict];
            
//             NSLog(@"--- Latitude(%f) Longitude(%f) Accuracy(%f)", self.myLocation.latitude, self.myLocation.longitude,self.myLocationAccuracy);
        }
    }
    
    //If the timer still valid, return it (Will not run the code below)
    if (self.shareModel.timer) {
        return;
    }
    
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
    
    //Restart the locationMaanger after 1 minute
    self.shareModel.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self
                                                           selector:@selector(restartLocationUpdates)
                                                           userInfo:nil
                                                            repeats:NO];
    
    //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
    //The location manager will only operate for 10 seconds to save battery
    if (self.shareModel.delay10Seconds) {
        [self.shareModel.delay10Seconds invalidate];
        self.shareModel.delay10Seconds = nil;
    }
    
    self.shareModel.delay10Seconds = [NSTimer scheduledTimerWithTimeInterval:10 target:self
                                                    selector:@selector(stopLocationDelayBy10Seconds)
                                                    userInfo:nil
                                                     repeats:NO];

}


//Stop the locationManager
-(void)stopLocationDelayBy10Seconds{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
    
//    NSLog(@"locationManager stop Updating after 10 seconds");
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusDenied) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationServiceDenied" object:nil];
//        NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: nil)
    }
}
- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
   // NSLog(@"locationManager error:%@",error);
    
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            NSLog(@"workerror");
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
        }
            break;
        case kCLErrorDenied:{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LocationServiceDenied" object:nil];
        }
            break;
        default:
        {
            
        }
            break;
    }
}
- (void)getMyLocation222{
    
    //    NSLog(@"updateLocationToServer");
    
    // Find the best location from the array based on accuracy
    NSMutableDictionary * myBestLocation = [[NSMutableDictionary alloc]init];
    
    for(int i=0;i<self.shareModel.myLocationArray.count;i++){
        NSMutableDictionary * currentLocation = [self.shareModel.myLocationArray objectAtIndex:i];
        
        if(i==0)
            myBestLocation = currentLocation;
        else{
            if([[currentLocation objectForKey:ACCURACY]floatValue]<=[[myBestLocation objectForKey:ACCURACY]floatValue]){
                myBestLocation = currentLocation;
            }
        }
    }
//        NSLog(@"My Best location:%@",myBestLocation);
    
    //If the array is 0, get the last location
    //Sometimes due to network issue or unknown reason, you could not get the location during that  period, the best you can do is sending the last known location to the server
    if(self.shareModel.myLocationArray.count==0)
    {
        //        NSLog(@"Unable to get location, use the last known location");
        
        self.myLocation=self.myLastLocation;
        self.myLocationAccuracy=self.myLastLocationAccuracy;
        
    }else{
        CLLocationCoordinate2D theBestLocation;
        theBestLocation.latitude =[[myBestLocation objectForKey:LATITUDE]floatValue];
        theBestLocation.longitude =[[myBestLocation objectForKey:LONGITUDE]floatValue];
        self.myLocation=theBestLocation;
        self.myLocationAccuracy =[[myBestLocation objectForKey:ACCURACY]floatValue];
    }
    
    //TODO: Your code to send the self.myLocation and self.myLocationAccuracy to your server
    
    //After sending the location to the server successful, remember to clear the current array with the following code. It is to make sure that you clear up old location in the array and add the new locations from locationManager
    [self.shareModel.myLocationArray removeAllObjects];
    self.shareModel.myLocationArray = nil;
    self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
}

//Send the location to Server
//- (void)updateLocationToServer {
//    [self getMyLocation222];
//    [self submitLocaiton];
//}
//
//-(void)submitLocaiton{
//    
//    NSURLSessionDataTask *postDataTask;
//    
//    NSError *error;
//    NSData *data1;
//    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//    [dic setValue:[NSString stringWithFormat:@"%f", self.myLastLocation.latitude] forKey:@"Latitude"];
//    [dic setValue:[NSString stringWithFormat:@"%f", self.myLastLocation.longitude] forKey:@"Longitude"];
//    [dic setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"] forKey:@"Token"];
//    [dic setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"TokenScret"] forKey:@"TokenSecret"];
//    
//    if (dic) {
//        data1 =[NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:&error];
//    }else{
//        data1=nil;
//    }
//    
//    
//    
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
//    NSURL *url;
//    url = [NSURL URLWithString: @"http://clockservice.buildersaccess.com/SubmitLocation.json"];
//    
//    //     NSLog(@"-%@-%@",url, [[NSString alloc]initWithData:data1 encoding:NSUTF8StringEncoding]);
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
//                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                       timeoutInterval:20];
//    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setHTTPMethod:@"POST"];
//    [request setTimeoutInterval: 15];
//    [request setHTTPBody:data1];
//    //        NSLog(@"application %@", [[NSString alloc]initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
//    NSLog(@"Latitude(%f) Longitude(%f) Accuracy(%f)", self.myLocation.latitude, self.myLocation.longitude,self.myLocationAccuracy);
//    
//    postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", str);
//
//    }];
//    [postDataTask resume];
////    return postDataTask;
//    
//    
//}




@end

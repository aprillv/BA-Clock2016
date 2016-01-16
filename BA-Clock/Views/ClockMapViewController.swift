//
//  ClockMapViewController.swift
//  BA-Clock
//
//  Created by April on 1/12/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

class ClockMapViewController: BaseViewController {
    var clockInfo : LoginedInfo?{
        didSet{
            if let time = clockInfo!.CurrentScheduledInterval {
                
                if time.integerValue > 0 {
                    self.timeIntervalClockIn = time.doubleValue * 60 - 20
                    self.performSelector("clockIn", withObject: nil, afterDelay: self.timeIntervalClockIn!)
                }
            }
        }
    }
    
    var latitude: NSNumber?
    var longitude: NSNumber?
    var timeIntervalClockIn : Double?
    
    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:1.0];
//    
//    //    self.firstView.backgroundColor=[UIColor redColor];
//    
//    
//    if (fromMap){
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.flipSuperView cache:YES];
//    [self.mapPage removeFromSuperview];
//    [self.flipSuperView addSubview:self.listbackView];
//    [self.flipSuperView sendSubviewToBack:self.mapPage];
//    [sender setImage:[UIImage imageNamed:@"map.png"] forState:UIControlStateAll];
//    //        [sender setImage:[UIImage imageNamed:@"map.png"] forState:UIControlStateHighlighted];
//    [self tabBar:self.Topbar didSelectItem:self.Topbar.selectedItem];
//    }else{
//    
//    if (!self.btnCurrentLocation.superview) {
//    [self.map addSubview:self.btnCurrentLocation];
//    }
//    if ([self.btnSearch.currentTitle isEqualToString:@"Nearby"]) {
//    [self.btnCurrentLocation.layer setValue:@"1" forKey:@"isLookfor"];
//    }
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.flipSuperView cache:YES];
//    [self.listbackView removeFromSuperview];
//    [self.flipSuperView addSubview:self.mapPage];
//    [self.flipSuperView sendSubviewToBack:self.listbackView];
//    [sender setImage:[UIImage imageNamed:@"grid.png"] forState:UIControlStateAll];
//    //        [sender setImage:[UIImage imageNamed:@"grid.png"] forState:UIControlStateHighlighted];
//    
//    }
//    
//    [UIView commitAnimations];
    
    @IBAction func switchTo(sender: UIBarButtonItem) {
        switch sender.title!{
        case "Text":
            sender.title = "Map"
            textTable.hidden = false
            UIView.transitionFromView(mapTable, toView: textTable, duration: 1, options: [.TransitionFlipFromRight, .ShowHideTransitionViews], completion: { (_) -> Void in
                
                self.view.bringSubviewToFront(self.textTable)
            })
            
            
            break
        default:
            sender.title = "Text"
            mapTable.hidden = false
            UIView.transitionFromView(textTable, toView: mapTable, duration: 1, options: [.TransitionFlipFromLeft, .ShowHideTransitionViews], completion: { (_) -> Void in
                self.view.bringSubviewToFront(self.mapTable)
            })
            
            
            break
        }
    }
    
    @IBOutlet weak var switchItem: UIBarButtonItem!
    @IBOutlet weak var mapTable: UITableView!
    @IBOutlet weak var textTable: UITableView!
    
    @IBOutlet weak var clockInBtn: UIButton!{
        didSet{
            clockInBtn.enabled = false
            clockInBtn.layer.cornerRadius = 5.0
        }
    }
    @IBOutlet weak var clockOutBtn: UIButton!{
        didSet{
            clockOutBtn.layer.cornerRadius = 5.0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        
        view.bringSubviewToFront(mapTable)
        title = userInfo.valueForKey(CConstants.UserFullName) as? String
        
    }
    
    private struct constants{
        static let CellIdentifier : String = "clockMapCell"
        static let CellIdentifierText : String = "clockItemCell"
    }
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clockInfo?.ScheduledDay?.count ?? 0
    }
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if tableView == mapTable {
            let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifier, forIndexPath: indexPath)
            if let cellitem = cell as? ClockMapCell {
                if let item : ScheduledDayItem = clockInfo?.ScheduledDay?[indexPath.row] {
                    cellitem.clockInfo = item
                }
                
                //            let ddd = CiaNmArray?[CiaNm?[indexPath.section] ?? ""]
                //            cellitem.contractInfo = ddd![indexPath.row]
                //            cell.separatorInset = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 8)
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifierText, forIndexPath: indexPath)
            if let cellitem = cell as? ClockTextCell {
                if let item : ScheduledDayItem = clockInfo?.ScheduledDay?[indexPath.row] {
                    cellitem.clockInfo = item
                }
                
                //            let ddd = CiaNmArray?[CiaNm?[indexPath.section] ?? ""]
                //            cellitem.contractInfo = ddd![indexPath.row]
                //            cell.separatorInset = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 8)
            }
            return cell
        }
        
        
        
    }
    @IBAction func doClockIn(sender: UIButton) {
    }
    @IBAction func doClockOut(sender: UIButton) {
        self.timeIntervalClockIn = -1
        print(self.locationManager)
        print(self.locationManager?.delegate)
       self.locationManager?.stopUpdatingLocation()
        self.locationManager?.startUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            
        }else{
            self.latitude = 0
            self.longitude = 0
            self.PopMsgWithJustOK(msg: CConstants.TurnOnLocationServiceMsg, txtField: nil)
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //        print(locations)
        let userLocation = locations.last
        if userLocation?.horizontalAccuracy < 0 {
            return
        }
        if userLocation?.timestamp.timeIntervalSinceNow < 30 {
            self.latitude = userLocation?.coordinate.latitude
            self.longitude = userLocation?.coordinate.longitude
            locationManager?.stopUpdatingLocation()
        }
        
        if self.timeIntervalClockIn > 0 {
            callClockInService()
        }else if self.timeIntervalClockIn == -1{
            callClockOutService()
        }
    }
    
    func clockIn(){
        locationManager?.startUpdatingLocation()
    }
    
    private func callClockInService(){
        let userInfo = NSUserDefaults.standardUserDefaults()
        let submitRequired = SubmitLocationRequired()
        submitRequired.Latitude = "\(self.latitude!)"
        submitRequired.Longitude = "\(self.longitude!)"
        submitRequired.UserName = userInfo.valueForKey(CConstants.UserDisplayName) as? String
        //        print(submitRequired.getPropertieNamesAsDictionary())
        Alamofire.request(.POST, CConstants.ServerURL + CConstants.SubmitLocationServiceURL, parameters: submitRequired.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
            if response.result.isSuccess {
                print("submit location information")
                print(response.result.value)
            }else{
            }
        }
        
    }
    
    private func callClockOutService(){
        let userInfo = NSUserDefaults.standardUserDefaults()
        let clockOutRequiredInfo = ClockOutRequired()
        clockOutRequiredInfo.Latitude = "\(self.latitude!)"
        clockOutRequiredInfo.Longitude = "\(self.longitude!)"
        clockOutRequiredInfo.HostName = UIDevice.currentDevice().name
        let tl = Tool()
        clockOutRequiredInfo.IPAddress = tl.getWiFiAddress()
        clockOutRequiredInfo.UserName = userInfo.valueForKey(CConstants.UserDisplayName) as? String
        //        print(submitRequired.getPropertieNamesAsDictionary())
        Alamofire.request(.POST, CConstants.ServerURL + CConstants.ClockOutServiceURL, parameters: clockOutRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
            if response.result.isSuccess {
                print("clock out")
                print(response.result.value)
                self.navigationController?.popViewControllerAnimated(true)
                
            }else{
                
                //                self.PopNetworkError()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.latitude = 0
        self.longitude = 0
        locationManager?.stopUpdatingLocation()
        locationManager?.startUpdatingLocation()
    }
    
}

//
//  MoreViewController.swift
//  BA-Clock
//
//  Created by April on 3/8/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit
import Alamofire

class MoreViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, timeSelectorDelegate {
//    var locationTracker : LocationTracker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
//        [button setImage:[UIImage imageNamed:@"image.png"] forState:UIControlStateNormal];
//        [button addTarget:target action:@selector(buttonAction:)forControlEvents:UIControlEventTouchUpInside];
//        [button setFrame:CGRectMake(0, 0, 53, 31)];
//        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(3, 5, 50, 20)];
//        [label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:13]];
//        [label setText:title];
//        label.textAlignment = UITextAlignmentCenter;
//        [label setTextColor:[UIColor whiteColor]];
//        [label setBackgroundColor:[UIColor clearColor]];
//        [button addSubview:label];
//        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
//        self.navigationItem.leftBarButtonItem = barButton;
        
        let button = UIButton(type: .Custom)
//        button.setImage(UIImage(named: "back"), forState: .Normal)
        button.addTarget(self, action: #selector(MoreViewController.GoBackToList(_:)), forControlEvents: .TouchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
//        button.setTitle("Back", forState: .Normal)
        let im = UIImageView(image: UIImage(named: "back"))
        var ct = im.frame
        ct.origin.y = (44 - ct.size.height)/2
        im.frame = ct
        button.addSubview(im)
        let lbl = UILabel(frame: CGRect(x: 20, y: 0, width: 40, height: 44))
        lbl.textColor = UIColor.whiteColor()
        lbl.text = "Back"
        button.addSubview(lbl)
        let leftbutton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = leftbutton
        
    }
    
    @IBAction func GoBackToList(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBOutlet var tableView: UITableView!
    
    struct constants {
        static let CellIdentifierTrack = "MoreCell"
        static let SegueToGISTrack = "GISTrack"
        
//        static let TitleGISTrack = "GIS Track"
//        static let TitleLunch = "Lunch"
//        static let TitleLunchBreak = "Strart Time"
//        static let TitleLunchReturn = "Lunch Return"
//        static let TitlePersonal = "Personal Reason"
//        static let TitlePersonalStart = "Strart Time"
//        static let TitlePersonalEnd = "End Time"
//        static let TitleCompanyReason = "Company Reason"
//        static let TitleCompanyStart = "Strart Time"
//        static let TitleCompanyEnd = "End Time"
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 3
        default:
             return 1
        }

        
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    var checkStatus = [true, false, false]
    var StartTime : NSDate = NSDate() {
        didSet{
            if tableView != nil {
                let index = NSIndexSet(index: 1)
                tableView.reloadSections(index, withRowAnimation: .Automatic)
            }
            EndTime = StartTime.dateByAddingTimeInterval(60*30)
        }
    }
    var EndTime : NSDate = NSDate().dateByAddingTimeInterval(60*30){
        didSet{
            if tableView != nil {
                let index = NSIndexSet(index: 2)
                tableView.reloadSections(index, withRowAnimation: .Automatic)
            }
        }
    }
    
    var dateFormat: NSDateFormatter = NSDateFormatter()
    
    private func getFormatedDate(d: NSDate) -> String{
        dateFormat.dateFormat = "hh:mm a"
        return dateFormat.stringFromDate(d)
    }
    
    private func getFormatedDate2(d: NSDate) -> String{
        dateFormat.dateFormat = "hh:mm:ss a"
        return dateFormat.stringFromDate(d)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        let cell1 = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifierTrack, forIndexPath: indexPath)
        
        switch indexPath.section{
        case 0:
            let cell1 = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifierTrack, forIndexPath: indexPath)
            if let cell = cell1 as? MoreTableViewCell {
                switch indexPath.row {
                case 0:
                    cell.actionlbl?.text = "Lunch"
                case 1:
                    cell.actionlbl?.text = "Business / Meeting"
                default:
                    cell.actionlbl?.text = "Personal Reason"
                }
                cell.checkImg.image = UIImage(named: checkStatus[indexPath.row] ? "radioed" : "radio")
            }
            return cell1
        case 1:
            let cell1 = tableView.dequeueReusableCellWithIdentifier("time", forIndexPath: indexPath)
            cell1.textLabel?.text = getFormatedDate(StartTime)
            return cell1
        case 2:
            let cell1 = tableView.dequeueReusableCellWithIdentifier("time", forIndexPath: indexPath)
            cell1.textLabel?.text = getFormatedDate(EndTime)
            return cell1
        default:
            let cell1 = tableView.dequeueReusableCellWithIdentifier("notes", forIndexPath: indexPath)
            if let cell = cell1 as? noteTableViewCell {
                
                let numberToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
                numberToolbar.barStyle = UIBarStyle.Default
                numberToolbar.items = [
//                    UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action:
//                        #selector(cancelNumberPad)),
                    UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
                    UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(doneWithNumberPad))]
                numberToolbar.sizeToFit()
                dext = cell.txtView
                cell.txtView.inputAccessoryView = numberToolbar
               
            }
            return cell1
        }
        
    }
    
    var dext : UITextView?
    
    func cancelNumberPad() {
        dext?.resignFirstResponder()
    }
    
    func doneWithNumberPad() {
        dext?.resignFirstResponder()
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section{
        case 3:
            return 120
        default:
            return 44
        }
    }
    
    @IBOutlet var datepicker: UIDatePicker!
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            dext?.resignFirstResponder()
                for i in 0...checkStatus.count-1 {
                    if i == indexPath.row {
                        checkStatus[indexPath.row] = true
                    }else{
                        checkStatus[i] = false
                    }
                }
                self.tableView.reloadData()
        case 1:
            dext?.resignFirstResponder()
            self.performSegueWithIdentifier("showTime", sender: 1)
        case 2:
            dext?.resignFirstResponder()
            self.performSegueWithIdentifier("showTime", sender: 2)
        default:
            break;
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showTime":
                if let time = segue.destinationViewController as? timeSelectorViewController,
                    let index = sender as? Int {
                    time.delegate = self
                    time.xtitle = index == 1 ? "Start Time" : "End Time"
                    time.xdate = index == 1 ? StartTime : EndTime
                    if index == 2 {
                        time.xminDate = StartTime.dateByAddingTimeInterval(60*5)
                    }
                }
            default:
                break
            }
        }
    }
    
    func finishSelectTime(xtime: NSDate, isStrat: Bool) {
        if isStrat {
            StartTime = xtime
        }else{
            EndTime = xtime
        }
    }
   
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view =  UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        
        let lbl = UILabel()
        lbl.textAlignment = .Left
        
        switch section{
        case 0:
            lbl.text = "Leave Reason"
        case 1:
            lbl.text = "Start Time"
        case 2:
            lbl.text = "End Time"
        default:
            lbl.text = "Notes"
        }
        lbl.sizeToFit()
        lbl.font = UIFont(name: "System", size: 17)
        lbl.frame = CGRect(x: 16, y: (40-lbl.frame.size.height)/2.0, width: self.view.frame.size.width-40, height: lbl.frame.size.height)
        lbl.textColor = UIColor.darkGrayColor()
        view.addSubview(lbl)
        return view
    }
    private func getUserToken() -> OAuthTokenItem{
        let userInfo = NSUserDefaults.standardUserDefaults()
        let userInfo1 = OAuthTokenItem(dicInfo: nil)
        userInfo1.Token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String
        userInfo1.TokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String
        return userInfo1
    }
    
//    private func callService(actionType : String){
//       
//        let requiredInfo = MoreActionRequired()
//        requiredInfo.ActionType = actionType
//        requiredInfo.Latitude = "\(self.locationTracker?.myLastLocation.latitude ?? 0)"
//        requiredInfo.Longitude = "\(self.locationTracker?.myLastLocation.longitude ?? 0)"
//        requiredInfo.HostName = UIDevice.currentDevice().name
//        let tl = Tool()
//        requiredInfo.IPAddress = tl.getWiFiAddress()
//        let OAuthToken = self.getUserToken()
//        requiredInfo.Token = OAuthToken.Token!
//        //        clockOutRequiredInfo.Token = "asdfaasdf"
//        requiredInfo.TokenSecret = OAuthToken.TokenSecret!
//        
//        print(requiredInfo.getPropertieNamesAsDictionary())
//        Alamofire.request(.POST, CConstants.ServerURL + CConstants.MoreActionServiceURL,
//            parameters: requiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
//            
//                if let rtnValue = response.result.value as? Int{
//                    if rtnValue == 1 {
//                        self.navigationController?.popViewControllerAnimated(true)
//                    }else{
//                         self.PopServerError()
//                    }
//                }else{
//                    self.PopServerError()
//                }
//                
//           
//        }
//    }
    
    
    var locationManager : CLocationManager?
    
    private func callService(){
        var actionType : String?
        for i in 0...2 {
            if checkStatus[i] {
                switch i{
                case 0:
                    actionType = "Lunch"
                case 1:
                    actionType = "Personal Reason"
                default:
                    actionType = "Company Reason"
                }
                break
            }
        }
        let requiredInfo = MoreActionRequired()
        requiredInfo.ActionType = actionType
        
        requiredInfo.Latitude = "\(self.locationManager?.currentLocation?.coordinate.latitude ?? 0)"
        requiredInfo.Longitude = "\(self.locationManager?.currentLocation?.coordinate.longitude ?? 0)"
        requiredInfo.HostName = UIDevice.currentDevice().name
        let tl = Tool()
        requiredInfo.IPAddress = tl.getWiFiAddress()
        requiredInfo.ClientTime = tl.getClientTime()
        let OAuthToken = self.getUserToken()
        requiredInfo.Token = OAuthToken.Token!
        //        clockOutRequiredInfo.Token = "asdfaasdf"
        requiredInfo.TokenSecret = OAuthToken.TokenSecret!
        requiredInfo.ReasonStart = self.getFormatedDate2(StartTime)
        requiredInfo.ReasonEnd = self.getFormatedDate2(EndTime)
        
        
        let index = NSIndexPath(forRow: 0, inSection: 3)
        if let cell = tableView.cellForRowAtIndexPath(index) as? noteTableViewCell {
            requiredInfo.Reason = cell.txtView.text ?? " "
        }else{
            requiredInfo.Reason = " "
        }
        
        let net = NetworkReachabilityManager()
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        
        if let lastGoOutTime = userInfo.valueForKey(CConstants.LastGoOutTime) as? NSDate {
            if let lastComeBackTime = userInfo.valueForKey(CConstants.LastComeBackTime) as? NSDate {
                if lastGoOutTime.timeIntervalSinceDate(lastComeBackTime) > 0 {
                    let msg = "In order to go out, you have to come back first."
                    self.PopMsgWithJustOK(msg: msg, txtField: nil)
                    return
                }
            }else{
                let msg = "In order to go out, you have to come back first."
                self.PopMsgWithJustOK(msg: msg, txtField: nil)
                return
            }
            
        }
        
        if let lastClockInTime = userInfo.valueForKey(CConstants.LastClockInTime) as? NSDate {
            if let lastClockOutTime = userInfo.valueForKey(CConstants.LastClockOutTime) as? NSDate {
                if lastClockOutTime.timeIntervalSinceDate(lastClockInTime) > 0 {
                    let msg = "In order to go out, you have to clock in first."
                    self.PopMsgWithJustOK(msg: msg, txtField: nil)
                    return
                }
            }
        }else{
            let msg = "In order to go out, you have to clock in first."
            self.PopMsgWithJustOK(msg: msg, txtField: nil)
            return
        }
        
        if net?.isReachable ?? false {
            
            let submitData = cl_submitData()
            submitData.resubmit()
            
//            let userInfo = NSUserDefaults.standardUserDefaults()
            userInfo.setValue(NSDate(), forKey: CConstants.LastGoOutTime)
            
            //        print(requiredInfo.getPropertieNamesAsDictionary())
            Alamofire.request(.POST, CConstants.ServerURL + CConstants.MoreActionServiceURL,
                parameters: requiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                    
                    if let rtnValue = response.result.value as? Int{
                        if rtnValue == 1 {
                            self.locationManager?.setNotComeBackNotification(self.EndTime)
                            self.navigationController?.popViewControllerAnimated(true)
                        }else{
//                            tl.saveGoOutDataToLocalDB(requiredInfo)
                            self.PopServerError()
                        }
                    }else{
                        tl.saveGoOutDataToLocalDB(requiredInfo)
                        self.navigationController?.popViewControllerAnimated(true)
                        //                    self.PopServerError()
                    }
            }
            
        }else{
            userInfo.setValue(NSDate(), forKey: CConstants.LastGoOutTime)
            tl.saveGoOutDataToLocalDB(requiredInfo)
            self.navigationController?.popViewControllerAnimated(true)
        }

    }
    
    @IBAction func doCancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    

//    @IBOutlet var noteView: UITextView!{
//        didSet{
//            noteView.layer.cornerRadius = 5.0
//            noteView.layer.borderColor = CConstants.BorderColor.CGColor
//            noteView.layer.borderWidth = 1.0 / (UIScreen().scale)
//        }
//    }
    @IBAction func dosubmit(sender: AnyObject) {
        callService()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(myKeyboardWillShowHandler(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(myKeyboardWillHideHandler(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        //        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
        
    }
    func myKeyboardWillHideHandler(noti : NSNotification) {
        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        tableView.scrollEnabled = true
    }
    
    
    func myKeyboardWillShowHandler(noti : NSNotification) {
//        print(view.frame.size.height)
        if view.frame.size.height == 672.0{
            // 6+
             tableView.setContentOffset(CGPoint(x: 0, y: 150), animated: true)
        }else if view.frame.size.height > 600{
            // 6
            tableView.setContentOffset(CGPoint(x: 0, y: 200), animated: true)
       }else if view.frame.size.height > 500{
    // 6
            tableView.setContentOffset(CGPoint(x: 0, y: 300), animated: true)
        }
    
        tableView.scrollEnabled = false
    }
    
    
}


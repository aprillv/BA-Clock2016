
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
        
        self.locationManager = CLocationManager.sharedInstance
        
        let button = UIButton(type: .custom)
//        button.setImage(UIImage(named: "back"), forState: .Normal)
        button.addTarget(self, action: #selector(MoreViewController.GoBackToList(_:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
//        button.setTitle("Back", forState: .Normal)
        let im = UIImageView(image: UIImage(named: "back"))
        var ct = im.frame
        ct.origin.y = (44 - ct.size.height)/2
        im.frame = ct
        button.addSubview(im)
        let lbl = UILabel(frame: CGRect(x: 20, y: 0, width: 40, height: 44))
        lbl.textColor = UIColor.white
        lbl.text = "Back"
        button.addSubview(lbl)
        let leftbutton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = leftbutton
        
    }
    
    @IBAction func GoBackToList(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet var tableView: UITableView!
    
    struct constants {
        static let CellIdentifierTrack = "MoreCell"
        static let SegueToGISTrack = "GISTrack"
        
//        case 0:
//        cell.actionlbl?.text = "Lunch"
//        case 1:
//        cell.actionlbl?.text = "Business / Meeting"
//        default:
//        cell.actionlbl?.text = "Personal Reason"
//        
        static let LunchString = "Lunch"
        static let BusinessString = "Business/Meeting"
        static let PersonalString = "Personal Reason"
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 3
        default:
             return 1
        }

        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    var checkStatus = [true, false, false]
    var StartTime : Date = Date() {
        didSet{
            if tableView != nil {
                let index = IndexSet(integer: 1)
                tableView.reloadSections(index, with: .automatic)
            }
            EndTime = StartTime.addingTimeInterval(60*30)
        }
    }
    var EndTime : Date = Date().addingTimeInterval(60*30){
        didSet{
            if tableView != nil {
                let index = IndexSet(integer: 2)
                tableView.reloadSections(index, with: .automatic)
            }
        }
    }
    
    var dateFormat: DateFormatter = DateFormatter()
    
    fileprivate func getFormatedDate(_ d: Date) -> String{
        dateFormat.dateFormat = "hh:mm a"
        return dateFormat.string(from: d)
    }
    
    fileprivate func getFormatedDate2(_ d: Date) -> String{
        dateFormat.dateFormat = "HH:mm:ss"
         dateFormat.timeZone = TimeZone(identifier: "America/Chicago")
//         dateFormat.timeZone = NSTimeZone.localTimeZone()
        dateFormat.locale = Locale(identifier : "en_US")
        return dateFormat.string(from: d)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell1 = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifierTrack, forIndexPath: indexPath)
        
        switch indexPath.section{
        case 0:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: constants.CellIdentifierTrack, for: indexPath)
            if let cell = cell1 as? MoreTableViewCell {
                switch indexPath.row {
                case 0:
                    cell.actionlbl?.text = constants.LunchString
                case 1:
                    cell.actionlbl?.text = constants.BusinessString
                default:
                    cell.actionlbl?.text = constants.PersonalString
                }
                cell.checkImg.image = UIImage(named: checkStatus[indexPath.row] ? "radioed" : "radio")
            }
            return cell1
        case 1:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "time", for: indexPath)
            cell1.textLabel?.text = getFormatedDate(StartTime)
            return cell1
        case 2:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "time", for: indexPath)
            cell1.textLabel?.text = getFormatedDate(EndTime)
            return cell1
        default:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "notes", for: indexPath)
            if let cell = cell1 as? noteTableViewCell {
                
                let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
                numberToolbar.barStyle = UIBarStyle.default
                numberToolbar.items = [
//                    UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action:
//                        #selector(cancelNumberPad)),
                    UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
                    UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneWithNumberPad))]
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

    @IBOutlet var submitBtn: UIButton!{
        didSet{
            submitBtn.layer.cornerRadius = 5.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section{
        case 3:
            return 180
        default:
            return 44
        }
    }
    
    @IBOutlet var datepicker: UIDatePicker!
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
            self.performSegue(withIdentifier: "showTime", sender: 1)
        case 2:
            dext?.resignFirstResponder()
            self.performSegue(withIdentifier: "showTime", sender: 2)
        default:
            break;
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showTime":
                if let time = segue.destination as? timeSelectorViewController,
                    let index = sender as? Int {
                    time.delegate = self
                    time.xtitle = index == 1 ? "Start Time" : "End Time"
                    time.xdate = index == 1 ? StartTime : EndTime
                    if index == 2 {
                        time.xminDate = StartTime.addingTimeInterval(60*5)
                    }
                }
            default:
                break
            }
        }
    }
    
    func finishSelectTime(_ xtime: Date, isStrat: Bool) {
        if isStrat {
            StartTime = xtime
        }else{
            EndTime = xtime
        }
    }
   
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view =  UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        
        let lbl = UILabel()
        lbl.textAlignment = .left
        
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
        lbl.textColor = UIColor.darkGray
        view.addSubview(lbl)
        return view
    }
    fileprivate func getUserToken() -> OAuthTokenItem{
        let userInfo = UserDefaults.standard
        let userInfo1 = OAuthTokenItem(dicInfo: nil)
        userInfo1.Token = userInfo.object(forKey: CConstants.UserInfoTokenKey) as? String
        userInfo1.TokenSecret = userInfo.object(forKey: CConstants.UserInfoTokenScretKey) as? String
        return userInfo1
    }
    
    
    var locationManager : CLocationManager?
    
    fileprivate func callService(){
        var actionType : String?
        for i in 0...2 {
            if checkStatus[i] {
                switch i{
                case 0:
                    actionType = constants.LunchString
                case 2:
                    actionType = constants.PersonalString
                default:
                    actionType = constants.BusinessString
                }
                break
            }
        }
        let requiredInfo = MoreActionRequired()
        requiredInfo.ActionType = actionType
        
//        let lat = self.locationManager?.currentLocation?.coordinate.latitude ?? 0
//        let lng = self.locationManager?.currentLocation?.coordinate.longitude ?? 0
        requiredInfo.Latitude = "\(self.locationManager?.currentLocation?.coordinate.latitude ?? 0)"
        requiredInfo.Longitude = "\(self.locationManager?.currentLocation?.coordinate.longitude ?? 0)"
        requiredInfo.HostName = UIDevice.current.name
        let tl = Tool()
        requiredInfo.IPAddress = tl.getWiFiAddress()
        let now = Date()
        requiredInfo.ClientTime = tl.getClientTime(now)
        let OAuthToken = self.getUserToken()
        requiredInfo.Token = OAuthToken.Token!
        //        clockOutRequiredInfo.Token = "asdfaasdf"
        requiredInfo.TokenSecret = OAuthToken.TokenSecret!
        requiredInfo.ReasonStart = self.getFormatedDate2(StartTime)
        requiredInfo.ReasonEnd = self.getFormatedDate2(EndTime)
        
        
        
        let index = IndexPath(row: 0, section: 3)
        if let cell = tableView.cellForRow(at: index) as? noteTableViewCell {
            requiredInfo.Reason = cell.txtView.text ?? " "
        }else{
            requiredInfo.Reason = " "
        }
        
        let net = NetworkReachabilityManager()
        
        
        let userInfo = UserDefaults.standard
        if net?.isReachable ?? false {
            
//            let submitData = cl_submitData()
//            submitData.resubmit(nil)
            
//            let userInfo = UserDefaults.standard
            userInfo.setValue(Date(), forKey: CConstants.LastGoOutTime)
//            userInfo.synchronize()
//            print0000(userInfo.valueForKey(CConstants.LastGoOutTime))
            //        print0000(requiredInfo.getPropertieNamesAsDictionary())
            
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud?.isUserInteractionEnabled = false
            hud?.labelText = CConstants.SavingMsg
//             print0000(requiredInfo.getPropertieNamesAsDictionary(), CConstants.MoreActionServiceURL)
            
            let param = [
                "ActionType": requiredInfo.ActionType   ?? ""
                ,"Token": requiredInfo.Token   ?? ""
                ,"TokenSecret": requiredInfo.TokenSecret   ?? ""
                ,"IPAddress": requiredInfo.IPAddress   ?? ""
                ,"HostName": requiredInfo.HostName   ?? ""
                ,"Latitude": requiredInfo.Latitude   ?? ""
                ,"Longitude": requiredInfo.Longitude   ?? ""
                ,"ReasonStart": requiredInfo.ReasonStart   ?? ""
                ,"ReasonEnd": requiredInfo.ReasonEnd   ?? ""
                ,"Reason": requiredInfo.Reason   ?? ""
                ,"ClientTime": requiredInfo.ClientTime   ?? ""
            ]
            
//            print(param);
            
            Alamofire.request(CConstants.ServerURL + CConstants.MoreActionServiceURL, method:.post,
                parameters: param).responseJSON{ (response) -> Void in
//                    print0000(requiredInfo.getPropertieNamesAsDictionary(), CConstants.MoreActionServiceURL)
                    hud?.isUserInteractionEnabled = true
                    hud?.hide(true)
//                    print0000(requiredInfo.getPropertieNamesAsDictionary(), response.result.value)
//                    print(response.result.value)
                    if let rtnValue = response.result.value as? Int{
                        if rtnValue == 1 {
                            self.locationManager?.setNotComeBackNotification(self.EndTime)
                            self.navigationController?.popViewController(animated: true)
                        }else{
//                            tl.saveGoOutDataToLocalDB(requiredInfo)
                            self.PopServerError()
                        }
                    }else{
//                        tl.saveGoOutDataToLocalDB(requiredInfo)
                        self.navigationController?.popViewController(animated: true)
                        //                    self.PopServerError()
                    }
            }
            
        }else{
            userInfo.setValue(Date(), forKey: CConstants.LastGoOutTime)
//            tl.saveGoOutDataToLocalDB(requiredInfo)
            self.navigationController?.popViewController(animated: true)
        }

    }
    
    @IBAction func doCancel(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    

//    @IBOutlet var noteView: UITextView!{
//        didSet{
//            noteView.layer.cornerRadius = 5.0
//            noteView.layer.borderColor = CConstants.BorderColor.CGColor
//            noteView.layer.borderWidth = 1.0 / (UIScreen().scale)
//        }
//    }
    @IBAction func dosubmit(_ sender: AnyObject) {
        callService()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         NotificationCenter.default.addObserver(self, selector: #selector(myKeyboardWillShowHandler(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myKeyboardWillHideHandler(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        //        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
        
    }
    func myKeyboardWillHideHandler(_ noti : Notification) {
        tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        tableView.isScrollEnabled = true
    }
    
    
    func myKeyboardWillShowHandler(_ noti : Notification) {
//        print0000(view.frame.size.height)
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
    
        tableView.isScrollEnabled = false
    }
    
    
}


//
//  LoginViewController.swift
//  Contract
//
//  Created by April on 11/18/15.
//  Copyright © 2015 HapApp. All rights reserved.
//

import UIKit
import Alamofire
//import LocalAuthentication

class LoginViewController: BaseViewController, UITextFieldDelegate, afterAgreeDelegate {

    
    var locationTracker : LocationTracker?
    // MARK: - Page constants
    private struct constants{
        static let PasswordEmptyMsg : String = "Password Required."
        static let EmailEmptyMsg :  String = "Email Required."
        static let WrongEmailOrPwdMsg :  String = "Email or password is incorrect."
        
        static let segueToAgreement = "showAgreement"
        
    }
    
    func afterAgree() {
        self.Login(signInBtn)
    }
    
//    var isLocationServiceEnabled: Bool?
    
//    @IBOutlet weak var signInMap: UIButton!{
//        didSet{
//            signInMap.layer.cornerRadius = 5.0
//            signInMap.backgroundColor = UIColor(red: 76/255.0, green: 217/255.0, blue: 100/255.0, alpha: 1)
//        }
//    }
    // MARK: Outlets
    @IBOutlet weak var emailTxt: UITextField!{
        
        didSet{
            emailTxt.returnKeyType = .Next
            emailTxt.delegate = self
            let userInfo = NSUserDefaults.standardUserDefaults()
            emailTxt.text = userInfo.objectForKey(CConstants.UserInfoEmail) as? String
            emailTxt.keyboardType = .EmailAddress
            self.setSignInBtn()
        }
    }
    @IBOutlet weak var passwordTxt: UITextField!{
        didSet{
            passwordTxt.returnKeyType = .Go
            passwordTxt.enablesReturnKeyAutomatically = true
            passwordTxt.delegate = self
            let userInfo = NSUserDefaults.standardUserDefaults()
            if let isRemembered = userInfo.objectForKey(CConstants.UserInfoRememberMe) as? Bool{
                if isRemembered {
                    passwordTxt.text = userInfo.objectForKey(CConstants.UserInfoPwd) as? String
                }
                
            }
            self.setSignInBtn()
        }
    }
    
//    @IBOutlet weak var rememberMeSwitch: UISwitch!{
//        didSet {
//            rememberMeSwitch.transform = CGAffineTransformMakeScale(0.85, 0.85)
//            let userInfo = NSUserDefaults.standardUserDefaults()
//            if let isRemembered = userInfo.objectForKey(CConstants.UserInfoRememberMe) as? Bool{
//                rememberMeSwitch.on = isRemembered
//            }else{
//                rememberMeSwitch.on = true
//            }
//        }
//    }
    
    @IBOutlet weak var backView2: UIView!{
//        backView.backgroundColor = UIColor.whiteColor()
        didSet{
            backView2.layer.borderColor = CConstants.BorderColor.CGColor
            backView2.layer.borderWidth = 0
            
            backView2.layer.shadowColor = CConstants.BorderColor.CGColor
            backView2.layer.shadowOpacity = 1
            backView2.layer.shadowRadius = 3.0
            backView2.layer.shadowOffset = CGSize(width: -1.0, height: 0)
        }
    }
    @IBOutlet weak var backView: UIView!{
        didSet{
            backView.backgroundColor = UIColor.whiteColor()
            backView.layer.borderColor = CConstants.BorderColor.CGColor
            backView.layer.borderWidth = 1.0
            
            backView.layer.shadowColor = CConstants.BorderColor.CGColor
            backView.layer.shadowOpacity = 1
            backView.layer.shadowRadius = 3.0
            backView.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
            
            
            
//            [v.layer setShadowColor:[UIColor blackColor].CGColor];
//            [v.layer setShadowOpacity:0.8];
//            [v.layer setShadowRadius:3.0];
//            [v.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
//            
//            backView.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet weak var signInBtn: UIButton!{
        didSet{
            signInBtn.layer.cornerRadius = 5.0
            setSignInBtn()
        }
    }
    
//    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    // MARK: UITextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField{
        case emailTxt:
            passwordTxt.becomeFirstResponder()
        case passwordTxt:
            Login(signInBtn)
        default:
            break
        }
        return true
    }
    
    @IBAction func textFieldChanged() {
        setSignInBtn()
    }
    private func setSignInBtn(){
        signInBtn?.enabled = !self.IsNilOrEmpty(passwordTxt?.text)
            && !self.IsNilOrEmpty(emailTxt?.text)
//        signInMap.enabled = signInBtn.enabled  && isLocationServiceEnabled!
        
    }
    
    
    // MARK: Outlet Action
//    @IBAction func rememberChanged(sender: UISwitch) {
//        let userInfo = NSUserDefaults.standardUserDefaults()
//        userInfo.setObject(rememberMeSwitch.on, forKey: CConstants.UserInfoRememberMe)
//        if !rememberMeSwitch.on {
//            userInfo.setObject("", forKey: CConstants.UserInfoPwd)
//        }
//    }
    
    
    
    @IBAction func Login(sender: UIButton) {
       
//        popupAgreement()
//        self.noticeOnlyText(CConstants.LoginingMsg)
        disAblePageControl()
        self.doLogin()
    }
    
    
    
    private func disAblePageControl(){
        signInBtn.enabled = false
//        signInBtn.backgroundColor = UIColor(red: 125/255.0, green: 153/255.0, blue: 176/255.0, alpha: 1)
//        signInMap.hidden = true
        emailTxt.enabled = false
        passwordTxt.enabled = false
//        rememberMeSwitch.enabled = false
        emailTxt.textColor = UIColor.darkGrayColor()
        passwordTxt.textColor = UIColor.darkGrayColor()
        
    }
    
    var clockInfo : LoginedInfo?{
        didSet{
            if let username = clockInfo?.UserName{
                
                if let gistrack = clockInfo?.GPSAgreement {
                    if gistrack == 1 {
                        self.saveEmailAndPwdToDisk(email: emailTxt.text!, password: passwordTxt.text!, displayName: username, fullName: clockInfo!.UserFullName!)
                        
                        let coreData = cl_coreData()
                        coreData.savedScheduledDaysToDB(clockInfo!.ScheduledDay!)
                        coreData.savedFrequencysToDB(clockInfo!.Frequency!)
                        
                        let userInfo = NSUserDefaults.standardUserDefaults()
                        userInfo.setValue(clockInfo!.OAuthToken!.Token!, forKey: CConstants.UserInfoTokenKey)
                        userInfo.setValue(clockInfo!.OAuthToken!.TokenSecret!, forKey: CConstants.UserInfoTokenScretKey)
                        self.performSegueWithIdentifier(CConstants.SegueToMap, sender: self)
                        
                        Tool.saveDeviceTokenToSever()
                    }else{
                        let userInfo = NSUserDefaults.standardUserDefaults()
                        userInfo.setValue(clockInfo!.OAuthToken!.Token!, forKey: CConstants.UserInfoTokenKey)
                        userInfo.setValue(clockInfo!.OAuthToken!.TokenSecret!, forKey: CConstants.UserInfoTokenScretKey)
                        self.performSegueWithIdentifier(constants.segueToAgreement, sender: nil)
                    }
                }else{
                    self.performSegueWithIdentifier(constants.segueToAgreement, sender: nil)
                }
                
                
                
                
            }else{
                self.PopMsgValidationWithJustOK(msg: constants.WrongEmailOrPwdMsg, txtField: nil)
            }
            
            
            
            
        }
    }
    
    
    private func doLogin(){
        
        emailTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        
        let email = emailTxt.text
        let password = passwordTxt.text
        
       
        
        if IsNilOrEmpty(email) {
            self.toEablePageControl()
            self.PopMsgWithJustOK(msg: constants.EmailEmptyMsg, txtField: emailTxt)
        }else{
            if IsNilOrEmpty(password) {
                self.toEablePageControl()
                self.PopMsgWithJustOK(msg: constants.PasswordEmptyMsg, txtField: passwordTxt)
            }else {
                
                let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                hud.labelText = CConstants.LoginingMsg
                
                
                // do login
                let tl = Tool()
                
                let loginRequiredInfo : ClockInRequired = ClockInRequired()
                loginRequiredInfo.Email = email
                loginRequiredInfo.Password = tl.md5(string: password!)
//                print(loginRequiredInfo.getPropertieNamesAsDictionary())
                Alamofire.request(.POST, CConstants.ServerURL + CConstants.LoginServiceURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                    hud.hide(true)
//                    print(response.result.value)
//                    self.progressBar.dismissViewControllerAnimated(true){
                        if response.result.isSuccess {
                            
                            if let rtnValue = response.result.value as? [String: AnyObject]{
                                
                                self.clockInfo = LoginedInfo(dicInfo: rtnValue)
                                
                            }else{
                                self.PopServerError()
                            }
                        }else{
                            self.PopNetworkError()
                        }
                        self.toEablePageControl()
//                        self.clearNotice()
//                    }
                }
                
                
            }
        }
    }
   private func toEablePageControl(){
//    self.view.userInteractionEnabled = true
//    self.signInBtn.hidden = false
//    self.signInMap.hidden = false
//     signInBtn.backgroundColor = UIColor(red: 19/255.0, green: 72/255.0, blue: 116/255.0, alpha: 1)
    self.signInBtn.enabled = true
    self.emailTxt.enabled = true
    self.passwordTxt.enabled = true
//    self.rememberMeSwitch.enabled = true
    self.emailTxt.textColor = UIColor.blackColor()
    self.passwordTxt.textColor = UIColor.blackColor()
//    self.spinner.stopAnimating()
    }
    
    func saveEmailAndPwdToDisk(email email: String, password: String, displayName: String, fullName: String){
        let userInfo = NSUserDefaults.standardUserDefaults()
//        if rememberMeSwitch.on {
            userInfo.setObject(true, forKey: CConstants.UserInfoRememberMe)
//        }else{
//            userInfo.setObject(false, forKey: CConstants.UserInfoRememberMe)
//        }
        userInfo.setObject(email, forKey: CConstants.UserInfoEmail)
        userInfo.setObject(password, forKey: CConstants.UserInfoPwd)
        userInfo.setObject(displayName, forKey: CConstants.UserDisplayName)
        userInfo.setObject(fullName, forKey: CConstants.UserFullName)
    }
    func beginTracking(){
        NSNotificationCenter.defaultCenter().postNotificationName("beginTracking", object: nil)
    }
    
    // MARK: PrepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
               
            case CConstants.SegueToMap:
                if let clockListView = segue.destinationViewController as? ClockMapViewController{
                    if let itemList = self.clockInfo?.ScheduledDay {
                        var h = itemList
                        let tl = Tool()
                        let (istime, timespace) = tl.getTimeInter()
                        if !istime {
                            h.append(ScheduledDayItem(dicInfo: ["ClockIn" : "-1", "ClockOut":"-1"]))
                            if timespace > 0 {
                                self.performSelector("beginTracking", withObject: nil, afterDelay: timespace)
                            }
                            
                        }
                        clockListView.clockDataList = h
                        
                    }
                    if let tracker = locationTracker {
                        clockListView.locationTracker = tracker
                    }
                }
                break
            case constants.segueToAgreement:
                if let agreement = segue.destinationViewController as? AgreementViewController{
                    agreement.delegate = self
                }
                break
            default:
                break
            }
        }
        
    }
    
    // MARK: Life cycle
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let userInfo = NSUserDefaults.standardUserDefaults()
        userInfo.setValue("0", forKey: CConstants.RegisteredDeviceToken)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255.0, green: 72/255.0, blue: 116/255.0, alpha: 1)
        self.navigationController?.navigationBar.translucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        self.title = "BA Clock"
        
        self.checkUpate()
        
        let locationManager = LocationTracker.sharedLocationManager()
        locationTracker = LocationTracker()
        locationManager.delegate = locationTracker
        locationManager.requestAlwaysAuthorization()
        
        
    }
}

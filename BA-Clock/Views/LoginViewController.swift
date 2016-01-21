//
//  LoginViewController.swift
//  Contract
//
//  Created by April on 11/18/15.
//  Copyright © 2015 HapApp. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
//import LocalAuthentication

class LoginViewController: BaseViewController, UITextFieldDelegate {

    // MARK: - Page constants
    private struct constants{
        static let PasswordEmptyMsg : String = "Password Required."
        static let EmailEmptyMsg :  String = "Email Required."
        static let WrongEmailOrPwdMsg :  String = "Email or password is incorrect."
        
    }
    
    var isLocationServiceEnabled: Bool?
    
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
        }
    }
    
    @IBOutlet weak var rememberMeSwitch: UISwitch!{
        didSet {
            rememberMeSwitch.transform = CGAffineTransformMakeScale(0.9, 0.9)
            let userInfo = NSUserDefaults.standardUserDefaults()
            if let isRemembered = userInfo.objectForKey(CConstants.UserInfoRememberMe) as? Bool{
                rememberMeSwitch.on = isRemembered
            }else{
                rememberMeSwitch.on = true
            }
        }
    }
    
    @IBOutlet weak var backView: UIView!{
        didSet{
            backView.backgroundColor = UIColor.whiteColor()
            backView.layer.borderColor = CConstants.BorderColor.CGColor
            backView.layer.borderWidth = 1.0
            backView.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet weak var signInBtn: UIButton!{
        didSet{
            signInBtn.layer.cornerRadius = 5.0
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
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
        signInBtn.enabled = !self.IsNilOrEmpty(passwordTxt.text)
            && !self.IsNilOrEmpty(emailTxt.text) && isLocationServiceEnabled!
//        signInMap.enabled = signInBtn.enabled  && isLocationServiceEnabled!
        
    }
    
    
    // MARK: Outlet Action
    @IBAction func rememberChanged(sender: UISwitch) {
        let userInfo = NSUserDefaults.standardUserDefaults()
        userInfo.setObject(rememberMeSwitch.on, forKey: CConstants.UserInfoRememberMe)
        if !rememberMeSwitch.on {
            userInfo.setObject("", forKey: CConstants.UserInfoPwd)
        }
    }
    
    
    func checkUpate(){
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"]
        let parameter = ["version": (version == nil ?  "" : version!), "appid": "iphone_ClockIn"]
        
        
        
        Alamofire.request(.POST,
            CConstants.ServerVersionURL + CConstants.CheckUpdateServiceURL,
            parameters: parameter).responseJSON{ (response) -> Void in
            if response.result.isSuccess {
                
                if let rtnValue = response.result.value{
                    if rtnValue.integerValue == 1 {
                         self.doLogin()
                    }else{
                        if let url = NSURL(string: CConstants.InstallAppLink){
                            self.toEablePageControl()
                            UIApplication.sharedApplication().openURL(url)
                        }else{
                             self.doLogin()
                        }
                    }
                }else{
                    self.doLogin()
                }
            }else{
                self.doLogin()
            }
        }
        //     NSString*   version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    }
    
    @IBAction func Login(sender: UIButton) {
        disAblePageControl()
        checkUpate()
    }
    
    private func disAblePageControl(){
        signInBtn.hidden = true
//        signInMap.hidden = true
        emailTxt.enabled = false
        passwordTxt.enabled = false
        rememberMeSwitch.enabled = false
        emailTxt.textColor = UIColor.darkGrayColor()
        passwordTxt.textColor = UIColor.darkGrayColor()
        spinner.startAnimating()
        
    }
    
    var clockInfo : LoginedInfo?{
        didSet{
            if clockInfo?.UserName != ""{
                self.saveEmailAndPwdToDisk(email: emailTxt.text!, password: passwordTxt.text!, displayName: clockInfo!.UserName!, fullName: clockInfo!.UserFullName!)
                self.performSegueWithIdentifier(CConstants.SegueToMap, sender: self)
                
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
                // do login
                let tl = Tool()
                
                let loginRequiredInfo : ClockInRequired = ClockInRequired()
                loginRequiredInfo.Email = email
                loginRequiredInfo.Password = tl.md5(string: password!)
//                print(loginRequiredInfo.getPropertieNamesAsDictionary())
                Alamofire.request(.POST, CConstants.ServerURL + CConstants.LoginServiceURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                    if response.result.isSuccess {
//                        print(response.result.value)
                        if let rtnValue = response.result.value as? [String: AnyObject]{
                            self.clockInfo = LoginedInfo(dicInfo: rtnValue)
                            self.toEablePageControl()
                        }else{
                            self.toEablePageControl()
                            self.PopServerError()
                        }
                    }else{
                        self.toEablePageControl()
                        self.PopNetworkError()
                    }
                }
                
                
            }
        }
    }
   private func toEablePageControl(){
//    self.view.userInteractionEnabled = true
    self.signInBtn.hidden = false
//    self.signInMap.hidden = false
    self.emailTxt.enabled = true
    self.passwordTxt.enabled = true
    self.rememberMeSwitch.enabled = true
    self.emailTxt.textColor = UIColor.blackColor()
    self.passwordTxt.textColor = UIColor.blackColor()
    self.spinner.stopAnimating()
    }
    
    func saveEmailAndPwdToDisk(email email: String, password: String, displayName: String, fullName: String){
        let userInfo = NSUserDefaults.standardUserDefaults()
        if rememberMeSwitch.on {
            userInfo.setObject(true, forKey: CConstants.UserInfoRememberMe)
        }else{
            userInfo.setObject(false, forKey: CConstants.UserInfoRememberMe)
        }
        userInfo.setObject(email, forKey: CConstants.UserInfoEmail)
        userInfo.setObject(password, forKey: CConstants.UserInfoPwd)
        userInfo.setObject(displayName, forKey: CConstants.UserDisplayName)
        userInfo.setObject(fullName, forKey: CConstants.UserFullName)
    }
    
    
    // MARK: PrepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
               
            case CConstants.SegueToMap:
                if let clockListView = segue.destinationViewController as? ClockMapViewController{
                    clockListView.locationManager = self.locationManager
                    locationManager?.delegate = clockListView
                    clockListView.clockInfo = self.clockInfo
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
        
        if let _ = isLocationServiceEnabled {
        
        }else{
            isLocationServiceEnabled = false
        }
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.delegate = self;
        if emailTxt.text != "" && passwordTxt != "" && rememberMeSwitch.on {
//            self.Login(signInBtn)
        }else{
            setSignInBtn()
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            isLocationServiceEnabled = true
        }else if status != .NotDetermined{
           self.PopMsgWithJustOK(msg: CConstants.TurnOnLocationServiceMsg, txtField: nil)
            isLocationServiceEnabled = false
        }
        
        setSignInBtn()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
//         self.performSegueWithIdentifier(CConstants.SegueToMap, sender: self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
//        navigationController?.setToolbarHidden(false, animated: true)
    }
}

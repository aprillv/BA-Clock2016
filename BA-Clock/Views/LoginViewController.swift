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

class LoginViewController: BaseViewController, UITextFieldDelegate {

    // MARK: - Page constants
    private struct constants{
        static let PasswordEmptyMsg : String = "Password Required."
        static let EmailEmptyMsg :  String = "Email Required."
        static let WrongEmailOrPwdMsg :  String = "Email or password is incorrect."
        
    }
    @IBOutlet weak var signInMap: UIButton!
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
    
    @IBOutlet weak var signInBtn: UIButton!
    
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
            && !self.IsNilOrEmpty(emailTxt.text)
        signInMap.enabled = signInBtn.enabled
        
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
        let parameter = ["version": (version == nil ?  "" : version!)]
        
        
        
        Alamofire.request(.POST,
            CConstants.ServerURL + CConstants.CheckUpdateServiceURL,
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
        emailTxt.enabled = false
        passwordTxt.enabled = false
        rememberMeSwitch.enabled = false
        emailTxt.textColor = UIColor.darkGrayColor()
        passwordTxt.textColor = UIColor.darkGrayColor()
        spinner.startAnimating()
        
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
                
                //                self.view.userInteractionEnabled = false
                
                
//                let loginUserInfo = LoginUser(email: email!, password: password!)
//                
//                let a = loginUserInfo.DictionaryFromObject()
//                Alamofire.request(.POST, CConstants.ServerURL + CConstants.LoginServiceURL, parameters: a).responseJSON{ (response) -> Void in
//                    if response.result.isSuccess {
//                        if let rtnValue = response.result.value as? [String: AnyObject]{
//                            let rtn = Contract(dicInfo: rtnValue)
//                            
//                            self.toEablePageControl()
//                            
//                            if rtn.activeyn == 1{
//                                self.saveEmailAndPwdToDisk(email: email!, password: password!)
//                                self.loginResult = rtn
//                                self.performSegueWithIdentifier(CConstants.SegueToAddressList, sender: self)
//                            }else{
//                                self.PopMsgValidationWithJustOK(msg: constants.WrongEmailOrPwdMsg, txtField: nil)
//                            }
//                        }else{
//                            self.toEablePageControl()
//                            self.PopServerError()
//                        }
//                    }else{
//                        self.toEablePageControl()
//                        self.PopNetworkError()
//                    }
//                }
                
                
            }
        }
    }
   private func toEablePageControl(){
//    self.view.userInteractionEnabled = true
    self.signInBtn.hidden = false
    self.emailTxt.enabled = true
    self.passwordTxt.enabled = true
    self.rememberMeSwitch.enabled = true
    self.emailTxt.textColor = UIColor.blackColor()
    self.passwordTxt.textColor = UIColor.blackColor()
    self.spinner.stopAnimating()
    }
    
    func saveEmailAndPwdToDisk(email email: String, password: String){
        let userInfo = NSUserDefaults.standardUserDefaults()
        if rememberMeSwitch.on {
            userInfo.setObject(true, forKey: CConstants.UserInfoRememberMe)
        }else{
            userInfo.setObject(false, forKey: CConstants.UserInfoRememberMe)
        }
        userInfo.setObject(email, forKey: CConstants.UserInfoEmail)
        userInfo.setObject(password, forKey: CConstants.UserInfoPwd)
    }
    
    
    // MARK: PrepareForSegue
//    private var loginResult : Contract?{
//        didSet{
//            if loginResult != nil{
//                let userInfo = NSUserDefaults.standardUserDefaults()
//                userInfo.setObject(loginResult!.username, forKey: CConstants.LoggedUserNameKey)
//            }
//        }
//    }
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let identifier = segue.identifier {
//            switch identifier {
//                case CConstants.SegueToAddressList:
//                    if let addressListView = segue.destinationViewController as? AddressListViewController{
//                        addressListView.AddressListOrigin = loginResult?.contracts
//                    }
//                break
//            default:
//                break
//            }
//        }
//        
//    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(view.frame.size)
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.delegate = self;
        
        locationManager?.startUpdatingLocation()
        navigationController?.setToolbarHidden(true, animated: true)
        
//        var region : CLRegion
        setSignInBtn()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            print("AuthorizedAlways")
        }else{
            print("++++++++++++++++++")
        }
        
        
        
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
}

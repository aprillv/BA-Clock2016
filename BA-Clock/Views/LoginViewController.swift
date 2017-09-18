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

class LoginViewController: BaseViewController, UITextFieldDelegate, afterAgreeDelegate {
    
    // MARK: - Page constants
    fileprivate struct constants{
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
            emailTxt.returnKeyType = .next
            emailTxt.delegate = self
            let userInfo = UserDefaults.standard
            emailTxt.text = userInfo.object(forKey: CConstants.UserInfoEmail) as? String
            emailTxt.keyboardType = .emailAddress
            self.setSignInBtn()
        }
    }
    @IBOutlet weak var passwordTxt: UITextField!{
        didSet{
            passwordTxt.returnKeyType = .go
            passwordTxt.enablesReturnKeyAutomatically = true
            passwordTxt.delegate = self
            let userInfo = UserDefaults.standard
            if let isRemembered = userInfo.object(forKey: CConstants.UserInfoRememberMe) as? Bool{
                if isRemembered {
                    passwordTxt.text = userInfo.object(forKey: CConstants.UserInfoPwd) as? String
                }
                
            }
            self.setSignInBtn()
        }
    }
    
    //    @IBOutlet weak var rememberMeSwitch: UISwitch!{
    //        didSet {
    //            rememberMeSwitch.transform = CGAffineTransformMakeScale(0.85, 0.85)
    //            let userInfo = UserDefaults.standard
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
            backView2.layer.borderColor = CConstants.BorderColor.cgColor
            backView2.layer.borderWidth = 0
            
            backView2.layer.shadowColor = CConstants.BorderColor.cgColor
            backView2.layer.shadowOpacity = 1
            backView2.layer.shadowRadius = 3.0
            backView2.layer.shadowOffset = CGSize(width: -1.0, height: 0)
        }
    }
    @IBOutlet weak var backView: UIView!{
        didSet{
            backView.backgroundColor = UIColor.white
            backView.layer.borderColor = CConstants.BorderColor.cgColor
            backView.layer.borderWidth = 1.0
            
            backView.layer.shadowColor = CConstants.BorderColor.cgColor
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    fileprivate func setSignInBtn(){
        signInBtn?.isEnabled = !self.IsNilOrEmpty(passwordTxt?.text)
            && !self.IsNilOrEmpty(emailTxt?.text)
        //        signInMap.enabled = signInBtn.enabled  && isLocationServiceEnabled!
        
    }
    
    
    // MARK: Outlet Action
    //    @IBAction func rememberChanged(sender: UISwitch) {
    //        let userInfo = UserDefaults.standard
    //        userInfo.setObject(rememberMeSwitch.on, forKey: CConstants.UserInfoRememberMe)
    //        if !rememberMeSwitch.on {
    //            userInfo.setObject("", forKey: CConstants.UserInfoPwd)
    //        }
    //    }
    
    
    
    @IBAction func Login(_ sender: UIButton) {
        
        //        popupAgreement()
        //        self.noticeOnlyText(CConstants.LoginingMsg)
        
        if UserDefaults.standard.bool(forKey: CConstants.LocationServericeChanged) {
            if CLLocationManager.authorizationStatus() != .authorizedAlways {
                self.popLocationErrorMsg()
            }else{
                disAblePageControl()
                self.doLogin()
            }
        }else{
            disAblePageControl()
            self.doLogin()
        }
        
    }
    
    
    
    fileprivate func disAblePageControl(){
        signInBtn.isEnabled = false
        //        signInBtn.backgroundColor = UIColor(red: 125/255.0, green: 153/255.0, blue: 176/255.0, alpha: 1)
        //        signInMap.hidden = true
        emailTxt.isEnabled = false
        passwordTxt.isEnabled = false
        //        rememberMeSwitch.enabled = false
        emailTxt.textColor = UIColor.darkGray
        passwordTxt.textColor = UIColor.darkGray
        
    }
    
    var clockInfo : LoginedInfo?{
        didSet{
            
            if let username = clockInfo?.UserName{
                
                if let gistrack = clockInfo?.GPSAgreement {
                    if gistrack == 1 {
                        self.saveEmailAndPwdToDisk(email: emailTxt.text!, password: passwordTxt.text!, displayName: username, fullName: clockInfo!.UserFullName!)
                        
                        let coreData = cl_coreData()
                        //                        coreData.savedScheduledDaysToDB(clockInfo!.ScheduledDay!)
                        coreData.savedFrequencysToDB(clockInfo!.Frequency!)
                        
                        let userInfo = UserDefaults.standard
                        userInfo.setValue(clockInfo?.ClockYN ?? "1", forKey: CConstants.ShowClockInAndOut)
                        userInfo.setValue(clockInfo!.OAuthToken!.Token!, forKey: CConstants.UserInfoTokenKey)
                        userInfo.setValue(clockInfo!.OAuthToken!.TokenSecret!, forKey: CConstants.UserInfoTokenScretKey)
                        userInfo.setValue(clockInfo!.iddeptos ?? "0", forKey: CConstants.UserInfoIdDeptos)
                        print(userInfo.string(forKey: CConstants.UserInfoIdDeptos) ?? "0")
                        self.performSegue(withIdentifier: CConstants.SegueToMap, sender: self)
                        
                        Tool.saveDeviceTokenToSever()
                    }else{
                        let userInfo = UserDefaults.standard
                        userInfo.setValue(clockInfo!.OAuthToken!.Token!, forKey: CConstants.UserInfoTokenKey)
                        userInfo.setValue(clockInfo!.OAuthToken!.TokenSecret!, forKey: CConstants.UserInfoTokenScretKey)
                        self.performSegue(withIdentifier: constants.segueToAgreement, sender: nil)
                    }
                }else{
                    self.performSegue(withIdentifier: constants.segueToAgreement, sender: nil)
                }
                
                
                
                
            }else{
                self.PopMsgValidationWithJustOK(msg: constants.WrongEmailOrPwdMsg, txtField: nil)
            }
            
            
            
            
        }
    }
    
    
    fileprivate func doLogin(){
        
        
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
                
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud?.labelText = CConstants.LoginingMsg
                
                
                // do login
                let tl = Tool()
                
//                let loginRequiredInfo : ClockInRequired = ClockInRequired()
//                loginRequiredInfo.Email = email
//                loginRequiredInfo.Password = tl.md5(string: password!)
                let now = Date()
//                loginRequiredInfo.ClientTime = tl.getClientTime(now)
                let param = [
                    "Email": email ?? ""
                    , "Password": tl.md5(string: password!)  ?? ""
                    , "ClientTime": tl.getClientTime(now)  ?? ""]
                
                //                print0000(loginRequiredInfo.getPropertieNamesAsDictionary())
                Alamofire.request(CConstants.ServerURL + CConstants.LoginServiceURL
                    , method:.post
                    , parameters: param
                    ).responseJSON{ (response) -> Void in
                    hud?.hide(true)
                                        print(response.result.value)
                    //                    self.progressBar.dismissViewControllerAnimated(true){
                    if response.result.isSuccess {
                        
                        if let rtnValue = response.result.value as? [String: AnyObject]{
                            
                           let tmp = LoginedInfo(dicInfo: rtnValue)
                            tmp.Frequency = [FrequencyItem]()
                            if let Frequencys = rtnValue["Frequency"] as? [[String: AnyObject]]{
                                for fitem in Frequencys {
                                    tmp.Frequency?.append(FrequencyItem(dicInfo: fitem))
                                }
                            }
                            
                            if let OAuthToken = rtnValue["OAuthToken"] as? [String: AnyObject]{
                                tmp.OAuthToken = OAuthTokenItem(dicInfo: OAuthToken);
                            }
                            
                            tmp.ScheduledDay = [ScheduledDayItem]()
                            if let ScheduledDay = rtnValue["ScheduledDay"] as? [[String: AnyObject]]{
                                for fitem in ScheduledDay {
                                    tmp.ScheduledDay?.append(ScheduledDayItem(dicInfo: fitem))
                                }
                            }
                            
                            
                            
                            self.clockInfo  = tmp;
                            
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
    fileprivate func toEablePageControl(){
        self.signInBtn.isEnabled = true
        self.emailTxt.isEnabled = true
        self.passwordTxt.isEnabled = true
        self.emailTxt.textColor = UIColor.black
        self.passwordTxt.textColor = UIColor.black
        //    self.spinner.stopAnimating()
    }
    
    func saveEmailAndPwdToDisk(email: String, password: String, displayName: String, fullName: String){
        let userInfo = UserDefaults.standard
        //        if rememberMeSwitch.on {
        userInfo.set(true, forKey: CConstants.UserInfoRememberMe)
        //        }else{
        //            userInfo.setObject(false, forKey: CConstants.UserInfoRememberMe)
        //        }
        userInfo.set(email, forKey: CConstants.UserInfoEmail)
        userInfo.set(password, forKey: CConstants.UserInfoPwd)
        userInfo.set(displayName, forKey: CConstants.UserDisplayName)
        userInfo.set(fullName, forKey: CConstants.UserFullName)
    }
    
    
    // MARK: PrepareForSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                
            case CConstants.SegueToMap:
                if let clockListView = segue.destination as? ClockMapViewController{
                    //                    if let itemList = self.clockInfo?.ScheduledDay {
                    //                        var h = itemList
                    //                        let tl = Tool()
                    //                        let (istime, _) = tl.getTimeInter()
                    //                        if !istime {
                    //                            h.append(ScheduledDayItem(dicInfo: ["ClockIn" : "-1", "ClockOut":"-1"]))
                    //
                    //
                    //                        }
                    //                        clockListView.clockDataList = h
                    //
                    //                    }
                    //                    if let tracker = locationTracker {
                    //                        clockListView.locationTracker = tracker
                    //                    }
                }
                break
            case constants.segueToAgreement:
                if let agreement = segue.destination as? AgreementViewController{
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
        
        self.checkUpate()
        let userInfo = UserDefaults.standard
        userInfo.setValue("0", forKey: CConstants.RegisteredDeviceToken)
        userInfo.set(true, forKey: CConstants.ToAddTrack)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 19/255.0, green: 72/255.0, blue: 116/255.0, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        self.title = "BA Clock"
        
    }
}

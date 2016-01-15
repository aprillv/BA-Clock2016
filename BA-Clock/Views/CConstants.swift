//
//  File.swift
//  Contract
//
//  Created by April on 11/23/15.
//  Copyright © 2015 HapApp. All rights reserved.
//

import Foundation
import UIKit

struct CConstants{
   
    
    static let BorderColor : UIColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1)
    static let BackColor : UIColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
    
    static let MsgTitle : String = "BA Clock"
    static let MsgOKTitle : String = "OK"
    static let MsgValidationTitle : String = "Validation Failed"
    static let MsgServerError : String = "Server Error, please try again later"
    static let MsgNetworkError : String = "Network Error, please check your network"
    
    static let UserInfoRememberMe :  String = "Login Remember Me"
    static let UserInfoEmail :  String = "Login Email"
    static let UserInfoPwd :  String = "Login Password"
    static let UserDisplayName :  String = "Logined User Name"
    static let UserFullName : String = "Logined User Full Name"
    
    static let RequestMsg = "Requesting from server"
    static let SavedMsg = "Saving to the BA Server"
    static let SavedSuccessMsg = "Saved successfully."
    static let SavedFailMsg = "Saved fail."
    static let SendEmailSuccessfullMsg = "Sent email successfully."
    static let PrintSuccessfullMsg = "Print successfully."
    
    static let SegueToText :  String = "LoginText"
    static let SegueToMap : String = "LoginMap"
    
    static let TurnOnLocationServiceMsg : String = "Please turn on Locaiton Service on your iphone to continue."
    
    static let LoggedUserNameKey : String = "LoggedUserNameInDefaults"
    static let InstallAppLink : String = "itms-services://?action=download-manifest&url=https://www.buildersaccess.com/iphone/BA-Clock.plist"
    static let ServerURL : String = "http://clockservice.buildersaccess.com/"
    static let ServerVersionURL : String = "http://contractssl.buildersaccess.com/"
    //validate login and get address list
    static let LoginServiceURL: String = "login.json"
    static let ClockInServiceURL: String = "ClockIn.json"
    static let SubmitLocationServiceURL: String = "SubmitLocation.json"
    static let ClockOutServiceURL: String = "ClockOut.json"
    //check app version
    static let CheckUpdateServiceURL: String = "bacontract_appid.json"
   
   
    
    
    
}




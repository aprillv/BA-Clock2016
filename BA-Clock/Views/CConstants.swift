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
   
    
    static let AppColor : UIColor = UIColor(red: 20/255.0, green: 72/255.0, blue:116/255.0, alpha: 1)
    static let BorderColor : UIColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1)
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
    static let UserDeviceToken : String = "User Device Token"
    static let UserInfoTokenKey : String = "Token"
    static let ShowClockInAndOut : String = "ShowClockInAndOut"
    static let UserInfoTokenScretKey : String = "TokenScret"
    static let RegisteredDeviceToken : String = "registeredDeviceToken"
    static let PhoneType : String = "1"
    
    static let LoadingMsg = "Loading Data...   "
     static let LoginingMsg = "Logining... ...  "
    
    static let SegueToMap : String = "LoginMap"

    static let TurnOnLocationServiceMsg : String = "Please turn on Locaiton Service on your iphone to continue."
    
    static let LoggedUserNameKey : String = "LoggedUserNameInDefaults"
    static let InstallAppLink : String = "itms-services://?action=download-manifest&url=https://www.buildersaccess.com/iphone/BA-Clock.plist"
    static let ServerURL : String = "http://clockservice.buildersaccess.com/"
    static let ServerVersionURL : String = "http://contractssl.buildersaccess.com/"
    //validate login and get address list
    static let LoginServiceURL: String = "login.json"
    static let UpdAgreementURL : String = "UpdateGPSAgreement.json"
    static let RegisterDeviceTokenServiceURL: String = "RegisterDeviceToken.json"
    static let ClockInServiceURL: String = "ClockIn.json"
    static let MoreActionServiceURL: String = "MoreActions.json"
    static let SubmitLocationServiceURL: String = "SubmitLocation.json"
    static let ClockOutServiceURL: String = "ClockOut.json"
    static let SyncScheduleIntervalURL : String = "SyncScheduleInterval.json"
    static let GetScheduledDataURL : String = "GetScheduledData.json"
    static let GetGISTrackURL : String = "GetGISTrack.json"
    
    static let LastClockInTime : String = "LastClockInTime"
    static let LastClockOutTime : String = "LastClockOutTime"
    static let LastGoOutTime : String = "LastGoOutTime"
    static let LastComeBackTime : String = "LastComeBackTime"
    
    static let SavingMsg = "Saving to server..."
    static let LastSubmitDateTime = "LastSubmitDateTime"
    
    static let SubmitNext = "DO NEXT SUBMIT"

    //check app version
    static let CheckUpdateServiceURL: String = "bacontract_appid.json"
   
   
    //about stroyboard
    static let StoryboardName : String = "Main"
    static let LoginStoryBoardId : String = "LoginStart"
    static let ListStoryBoardId : String = "ListStart"
    
    static let SubmitLocationType : Int = 1
    static let ClockInType : Int = 2
    static let ClockOutType : Int = 3
    static let GoOutType : Int = 4
    static let ComeBackType : Int = 5
    
    static let ToAddTrack : String = "AddTrack"
    static let LastGoOutTimeStartEnd : String = "LastGoOutTimeStartEnd"
}




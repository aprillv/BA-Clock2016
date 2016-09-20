//
//  BaseViewController.swift
//  Contract
//
//  Created by April on 11/18/15.
//  Copyright © 2015 HapApp. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class BaseViewController: UIViewController {
    
//    var locationManager : CLLocationManager?
    func checkUpate(){
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"]
        let parameter = ["version": (version == nil ?  "" : version!), "appid": "iphone_ClockIn"]
        
        Alamofire.request(.POST,
            CConstants.ServerVersionURL + CConstants.CheckUpdateServiceURL,
            parameters: parameter).responseJSON{ (response) -> Void in
                if response.result.isSuccess {
                    
                    if let rtnValue = response.result.value{
                        
                        if rtnValue.integerValue == 1 {
                            
                        }else{
                            if let url = NSURL(string: CConstants.InstallAppLink){
                                
                                UIApplication.sharedApplication().openURL(url)
                            }else{
                                
                            }
                        }
                    }else{
                        
                    }
                }else{
                    
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        navigationItem.hidesBackButton = true
        edgesForExtendedLayout = .None
    }
    
    func IsNilOrEmpty(str : String?) -> Bool{
        return str == nil || str!.isEmpty
    }
    
    func PopMsgWithJustOK(msg msg1: String, txtField : UITextField?){
//        let hud = 
        let alert: UIAlertController = UIAlertController(title: CConstants.MsgTitle, message: msg1, preferredStyle: .Alert)
        
        //Create and add the OK action
        let oKAction: UIAlertAction = UIAlertAction(title: CConstants.MsgOKTitle, style: .Cancel) { [weak txtField] action -> Void in
            //Do some stuff
            txtField?.becomeFirstResponder()
        }
        alert.addAction(oKAction)
        
        
        //Present the AlertController
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    func PopMsgWithJustOK(msg msg1: String, action1 : (action : UIAlertAction) -> Void){
        
        let alert: UIAlertController = UIAlertController(title: CConstants.MsgTitle, message: msg1, preferredStyle: .Alert)
        
        //Create and add the OK action
        let oKAction: UIAlertAction = UIAlertAction(title: CConstants.MsgOKTitle, style: .Cancel, handler:action1)
        alert.addAction(oKAction)
        
        
        //Present the AlertController
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    
    func PopServerError(){
        self.PopMsgWithJustOK(msg: CConstants.MsgServerError, txtField: nil)
    }
    func PopNetworkError(){
        self.PopMsgWithJustOK(msg: CConstants.MsgNetworkError, txtField: nil)
    }
    
    func PopMsgValidationWithJustOK(msg msg1: String, txtField : UITextField?){
        
        let alert: UIAlertController = UIAlertController(title: CConstants.MsgValidationTitle, message: msg1, preferredStyle: .Alert)
        
        //Create and add the OK action
        let oKAction: UIAlertAction = UIAlertAction(title: CConstants.MsgOKTitle, style: .Cancel) { action -> Void in
            //Do some stuff
            txtField?.becomeFirstResponder()
        }
        alert.addAction(oKAction)
        
        
        //Present the AlertController
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //LocationServiceDenied
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BaseViewController.popLocationErrorMsg), name:CConstants.LocationServericeChanged, object: nil)
    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: CConstants.LocationServericeChanged, object: nil)
    }
    
    func popLocationErrorMsg(){
//        self.PopMsgWithJustOK(msg: CConstants.TurnOnLocationServiceMsg, action1:
//        })
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: CConstants.LocationServericeChanged)
        self.PopMsgWithJustOK(msg: CConstants.TurnOnLocationServiceMsg) { (action) in
            if let url = NSURL(string: UIApplicationOpenSettingsURLString){
                UIApplication.sharedApplication().openURL(url)
            }
//            self.popToRootLogin()
        }
        
    }
    
    func popToRootLogin()  {
        
        var va : [UIViewController]? = self.navigationController?.viewControllers
        if (va?.count ?? 0) > 0 && va![0].isMemberOfClass(LoginViewController) {
            let userInfo = NSUserDefaults.standardUserDefaults()
            userInfo.removeObjectForKey(CConstants.UserInfoTokenKey)
            userInfo.removeObjectForKey(CConstants.UserInfoTokenScretKey)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let login = storyboard.instantiateViewControllerWithIdentifier("LoginStart") as? LoginViewController {
                
                
                if va != nil {
                    va!.insert(login, atIndex: 0)
                    self.navigationController?.viewControllers = va!
                    let userInfo = NSUserDefaults.standardUserDefaults()
                    userInfo.removeObjectForKey(CConstants.UserInfoTokenKey)
                    userInfo.removeObjectForKey(CConstants.UserInfoTokenScretKey)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                }}
        }
        
    }
    
}

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
        let version = Bundle.main.infoDictionary?["CFBundleVersion"]
        let parameter = ["version": (version == nil ?  "" : version!), "appid": "iphone_ClockIn"]
        
        Alamofire.request(
            CConstants.ServerVersionURL + CConstants.CheckUpdateServiceURL, method:.post,
            parameters: parameter).responseJSON{ (response) -> Void in
                if response.result.isSuccess {
                    
                    if let rtnValue = response.result.value{
                        
                        if (rtnValue as? NSNumber ?? 0).intValue == 1 {
                            
                        }else{
                            if let url = URL(string: CConstants.InstallAppLink){
                                UIApplication.shared.openURL(url)
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
        edgesForExtendedLayout = UIRectEdge()
    }
    
    func IsNilOrEmpty(_ str : String?) -> Bool{
        return str == nil || str!.isEmpty
    }
    
    func PopMsgWithJustOK(msg msg1: String, txtField : UITextField?){
//        let hud = 
        let alert: UIAlertController = UIAlertController(title: CConstants.MsgTitle, message: msg1, preferredStyle: .alert)
        
        //Create and add the OK action
        let oKAction: UIAlertAction = UIAlertAction(title: CConstants.MsgOKTitle, style: .cancel) { [weak txtField] action -> Void in
            //Do some stuff
            txtField?.becomeFirstResponder()
        }
        alert.addAction(oKAction)
        
        
        //Present the AlertController
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func PopMsgWithJustOK(msg msg1: String, action1 : @escaping (_ action : UIAlertAction) -> Void){
        
        let alert: UIAlertController = UIAlertController(title: CConstants.MsgTitle, message: msg1, preferredStyle: .alert)
        
        //Create and add the OK action
        let oKAction: UIAlertAction = UIAlertAction(title: CConstants.MsgOKTitle, style: .cancel, handler:action1)
        alert.addAction(oKAction)
        
        
        //Present the AlertController
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    
    func PopServerError(){
        self.PopMsgWithJustOK(msg: CConstants.MsgServerError, txtField: nil)
    }
    func PopNetworkError(){
        self.PopMsgWithJustOK(msg: CConstants.MsgNetworkError, txtField: nil)
    }
    
    func PopMsgValidationWithJustOK(msg msg1: String, txtField : UITextField?){
        
        let alert: UIAlertController = UIAlertController(title: CConstants.MsgValidationTitle, message: msg1, preferredStyle: .alert)
        
        //Create and add the OK action
        let oKAction: UIAlertAction = UIAlertAction(title: CConstants.MsgOKTitle, style: .cancel) { action -> Void in
            //Do some stuff
            txtField?.becomeFirstResponder()
        }
        alert.addAction(oKAction)
        
        
        //Present the AlertController
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //LocationServiceDenied
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.popLocationErrorMsg), name:NSNotification.Name(rawValue: CConstants.LocationServericeChanged), object: nil)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CConstants.LocationServericeChanged), object: nil)
    }
    
    func popLocationErrorMsg(){
//        self.PopMsgWithJustOK(msg: CConstants.TurnOnLocationServiceMsg, action1:
//        })
        UserDefaults.standard.set(true, forKey: CConstants.LocationServericeChanged)
        self.PopMsgWithJustOK(msg: CConstants.TurnOnLocationServiceMsg) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString){
                UIApplication.shared.openURL(url)
            }
//            self.popToRootLogin()
        }
        
    }
    
    func popToRootLogin()  {
        
        var va : [UIViewController]? = self.navigationController?.viewControllers
        if (va?.count ?? 0) > 0 && va![0].isMember(of: LoginViewController.classForCoder()) {
            let userInfo = UserDefaults.standard
            userInfo.removeObject(forKey: CConstants.UserInfoTokenKey)
            userInfo.removeObject(forKey: CConstants.UserInfoTokenScretKey)
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let login = storyboard.instantiateViewController(withIdentifier: "LoginStart") as? LoginViewController {
                
                
                if va != nil {
                    va!.insert(login, at: 0)
                    self.navigationController?.viewControllers = va!
                    let userInfo = UserDefaults.standard
                    userInfo.removeObject(forKey: CConstants.UserInfoTokenKey)
                    userInfo.removeObject(forKey: CConstants.UserInfoTokenScretKey)
                    self.navigationController?.popToRootViewController(animated: true)
                    
                }}
        }
        
    }
    
}

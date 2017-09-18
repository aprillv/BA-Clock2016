//
//  AgreementViewController.swift
//  BA-Clock
//
//  Created by April on 3/11/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit
import Alamofire

protocol afterAgreeDelegate {
func afterAgree()
}
class AgreementViewController: BaseViewController {

    var delegate : afterAgreeDelegate?
    
    @IBOutlet var disagreeBtn: UIButton!{
        didSet{
            disagreeBtn.layer.cornerRadius = 5.0
        }
    }
    @IBOutlet var agreeBtn: UIButton!{
        didSet{
            agreeBtn.layer.cornerRadius = 5.0
        }
    }
    @IBOutlet var contentview: UITextView!{
        didSet{
            contentview.scrollRangeToVisible(NSMakeRange(0, 0))
        }
    }
    @IBAction func DoAgree(_ sender: AnyObject) {
       
            
            self.updateAgreement()
            
        
    }
    
    fileprivate func updateAgreement(){
        let userInfo = UserDefaults.standard
        if let token = userInfo.object(forKey: CConstants.UserInfoTokenKey) as? String{
            if let tokenSecret = userInfo.object(forKey: CConstants.UserInfoTokenScretKey) as? String {
                
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
                
//                var Token : String?
//                var TokenSecret : String?
//                var ClientTime: String?
//                var Email : String?
//                var Password: String?
                
                let param = [
                    "Token": loginRequiredInfo.Token ?? ""
                , "TokenSecret": loginRequiredInfo.TokenSecret ?? ""
                , "ClientTime": loginRequiredInfo.ClientTime ?? ""
                , "Email": loginRequiredInfo.Email ?? ""
                , "Password": loginRequiredInfo.Password ?? ""]
                
                Alamofire.request(CConstants.ServerURL + CConstants.UpdAgreementURL, method:.post, parameters: param).responseJSON{ (response) -> Void in
//                    print0000(response.result.value)
                    self.dismiss(animated: true) { () -> Void in
                        if let del = self.delegate {
                            del.afterAgree()
                        }
                    }
                   
                    
                   
                }
                
            }
        }
       

    }
    
    @IBAction func DoDisAgree(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
   
    

}

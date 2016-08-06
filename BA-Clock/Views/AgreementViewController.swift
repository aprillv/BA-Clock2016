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
    
    @IBOutlet var contentview: UITextView!{
        didSet{
            contentview.scrollRangeToVisible(NSMakeRange(0, 0))
        }
    }
    @IBAction func DoAgree(sender: AnyObject) {
       
            
            self.updateAgreement()
            
        
    }
    
    private func updateAgreement(){
        let userInfo = NSUserDefaults.standardUserDefaults()
        if let token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String{
            if let tokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String {
                
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
                
                Alamofire.request(.POST, CConstants.ServerURL + CConstants.UpdAgreementURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
//                    print0000(response.result.value)
                    self.dismissViewControllerAnimated(true) { () -> Void in
                        if let del = self.delegate {
                            del.afterAgree()
                        }
                    }
                   
                    
                   
                }
                
            }
        }
       

    }
    
    @IBAction func DoDisAgree(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
    

}

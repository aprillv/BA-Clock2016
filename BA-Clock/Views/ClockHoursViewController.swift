//
//  ClockHoursViewController.swift
//  BA-Clock
//
//  Created by April on 8/3/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Alamofire

class ClockHoursViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func checkUpdate(_ sender: AnyObject) {
        let version = Bundle.main.infoDictionary?["CFBundleVersion"]
        let parameter = ["version": (version == nil ?  "" : version!), "appid": "iphone_ClockIn"]
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.labelText = "Checking for update..."
        Alamofire.request(
            CConstants.ServerVersionURL + CConstants.CheckUpdateServiceURL, method:.post,
            parameters: parameter).responseJSON{ (response) -> Void in
                hud?.hide(true)
                if response.result.isSuccess {
                    
                    if let rtnValue = response.result.value{
                        
                        if (rtnValue as? NSNumber ?? 0).intValue == 1 {
                            self.PopMsgWithJustOK(msg: "Now the app is the latest version.", txtField: nil)
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
    
    @IBOutlet var logoutBtn: UIButton!{
        didSet{
            let email = ((UserDefaults.standard.value(forKey: CConstants.UserInfoEmail) ?? "") as AnyObject).lowercased
            if !(email == "xiujun_85@163.com" || email == "april@buildersaccess.com" || email == "350582482@qq.com"
                || email == "john@buildersaccess.com" || email == "bob@buildersaccess.com" || email == "roberto@buildersaccess.com") {
                logoutBtn.isHidden = true
            }
        }
        
    }
    
    
    @IBAction func Logout(_ sender: UIButton) {
        CLocationManager.sharedInstance.stopUpdatingLocation()
        self.popToRootLogin()
    }
    @IBAction func goBack(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    fileprivate struct constants {
        static let headCellIdentifier = "headCell"
        static let contentCellIdentifier = "contentCell"
    }
    
    var hourList : [FrequencyItem]?{
        didSet{
            tablewView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let email = ((UserDefaults.standard.value(forKey: CConstants.UserInfoEmail) ?? "") as AnyObject).lowercased
        if !(email == "xiujun_85@163.com" || email == "april@buildersaccess.com" || email == "350582482@qq.com"
            || email == "john@buildersaccess.com" || email == "bob@buildersaccess.com" || email == "roberto@buildersaccess.com") {
            self.navigationItem.rightBarButtonItems = nil
        }
        
        syncFrequency()
//        let cs = cl_coreData()
//        hourList = cs.getAllFrequency()
//
        
    }
    
    func syncFrequency(){
        let userInfo = UserDefaults.standard
        if let token = userInfo.object(forKey: CConstants.UserInfoTokenKey) as? String{
            if let tokenSecret = userInfo.object(forKey: CConstants.UserInfoTokenScretKey) as? String {
                //                print0000(token, tokenSecret)
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
                //                print0000(loginRequiredInfo.getPropertieNamesAsDictionary())
                
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud?.labelText = CConstants.LoadingMsg
                
                let param = [
                    "Token": token
                    , "TokenSecret": tokenSecret
                    , "ClientTime": loginRequiredInfo.ClientTime ?? ""
                    , "Email": loginRequiredInfo.Email ?? ""
                    , "Password": loginRequiredInfo.Password ?? ""]
                
                Alamofire.request( CConstants.ServerURL + CConstants.SyncScheduleIntervalURL
                    , method:.post
                    , parameters: param).responseJSON{ (response) -> Void in
                    //                    print0000(response.result.value)
                    //                    print0000("syncFrequency")
                    hud?.hide(true)
                    if response.result.isSuccess {
                        if let rtnValue = response.result.value as? [[String: AnyObject]]{
                            //                            print0000(rtnValue)
                            var rtn = [FrequencyItem]()
                            for item in rtnValue{
                                rtn.append(FrequencyItem(dicInfo: item))
                            }
                            self.hourList = rtn
                            let coreData = cl_coreData()
                            coreData.savedFrequencysToDB(rtn)
                        }else{
                            
                        }
                    }else{
                        
                    }
                }
            }
        }
        
    }
    
    
    @IBOutlet var tablewView: UITableView!{
        didSet{
            tablewView.separatorStyle = .none
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: constants.contentCellIdentifier, for: indexPath)
        
        if let cell1 = cell as? ClockHourCell {
            cell1.setCellDetail(hourList![indexPath.row])
        }
         return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: constants.headCellIdentifier)
        let a = UIColor(red: 215/255.0, green: 224/255.0, blue:231/255.0, alpha: 1)
        cell?.backgroundColor = a
        cell?.contentView.backgroundColor = a
        return cell
    }
    
    @IBOutlet var logout1Btn: UIButton!{
        didSet{
            logout1Btn.layer.cornerRadius = 5.0
        }
    }
    @IBOutlet var checkBtn: UIButton!{
        didSet{
            checkBtn.layer.cornerRadius = 5.0
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
}

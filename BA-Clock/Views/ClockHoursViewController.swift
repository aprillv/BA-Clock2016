//
//  ClockHoursViewController.swift
//  BA-Clock
//
//  Created by April on 8/3/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Alamofire

class ClockHoursViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func checkUpdate(sender: AnyObject) {
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"]
        let parameter = ["version": (version == nil ?  "" : version!), "appid": "iphone_ClockIn"]
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.labelText = "Checking for update..."
        Alamofire.request(.POST,
            CConstants.ServerVersionURL + CConstants.CheckUpdateServiceURL,
            parameters: parameter).responseJSON{ (response) -> Void in
                hud.hide(true)
                if response.result.isSuccess {
                    
                    if let rtnValue = response.result.value{
                        
                        if rtnValue.integerValue == 1 {
                            self.PopMsgWithJustOK(msg: "Now the app is the latest version.", txtField: nil)
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
    
    @IBOutlet var logoutBtn: UIButton!{
        didSet{
            let email = (NSUserDefaults.standardUserDefaults().valueForKey(CConstants.UserInfoEmail) ?? "").lowercaseString
            if !(email == "xiujun_85@163.com" || email == "april@buildersaccess.com" || email == "350582482@qq.com"
                || email == "john@buildersaccess.com" || email == "bob@buildersaccess.com" || email == "roberto@buildersaccess.com") {
                logoutBtn.hidden = true
            }
        }
        
    }
    
    
    @IBAction func Logout(sender: UIButton) {
        self.popToRootLogin()
    }
    @IBAction func goBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    private struct constants {
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
        
        let email = (NSUserDefaults.standardUserDefaults().valueForKey(CConstants.UserInfoEmail) ?? "").lowercaseString
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
        let userInfo = NSUserDefaults.standardUserDefaults()
        if let token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String{
            if let tokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String {
                //                print0000(token, tokenSecret)
                let loginRequiredInfo : OAuthTokenItem = OAuthTokenItem(dicInfo: nil)
                loginRequiredInfo.Token = token
                loginRequiredInfo.TokenSecret = tokenSecret
                //                print0000(loginRequiredInfo.getPropertieNamesAsDictionary())
                
                let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                hud.labelText = CConstants.LoadingMsg
                
                Alamofire.request(.POST, CConstants.ServerURL + CConstants.SyncScheduleIntervalURL, parameters: loginRequiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
                    //                    print0000(response.result.value)
                    //                    print0000("syncFrequency")
                    hud.hide(true)
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
            tablewView.separatorStyle = .None
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourList?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(constants.contentCellIdentifier, forIndexPath: indexPath)
        
        if let cell1 = cell as? ClockHourCell {
            cell1.setCellDetail(hourList![indexPath.row])
        }
         return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier(constants.headCellIdentifier)
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
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
}

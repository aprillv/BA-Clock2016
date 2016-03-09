//
//  MoreViewController.swift
//  BA-Clock
//
//  Created by April on 3/8/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit
import Alamofire

class MoreViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var locationTracker : LocationTracker?
    @IBAction func GoBackToList(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBOutlet var tableView: UITableView!
    
    struct constants {
        static let CellIdentifierTrack = "MoreCell"
        static let SegueToGISTrack = "GISTrack"
        
        static let TitleGISTrack = "GIS Track"
        static let TitleLunch = "Lunch"
        static let TitleLunchBreak = "Lunch Break"
        static let TitleLunchReturn = "Lunch Return"
        static let TitlePersonal = "Personal Reason"
        static let TitlePersonal15 = "Out for 15 Mins"
        static let TitlePersonal30 = "Out for 30 Mins"
        static let TitlePersonal1Hour = "Out for 1 Hour"
        static let TitlePersonal1Day = "Out for 1 Day"
        static let TitlePersonalMedical = "Medical Reason"
        
    }
    
    let personalTitle = [constants.TitlePersonal15,
        constants.TitlePersonal30,
        constants.TitlePersonal1Hour,
        constants.TitlePersonal1Day,
        constants.TitlePersonalMedical
    ]
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 3
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section{
//        case 0:
//            return 1
//        case 1:
//            return 2
//        default:
//            return personalTitle.count
//        }
        switch section{
        case 0:
            return 2
        default:
            return personalTitle.count
        }
        
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        print(section)
//        print(section == 0 ? 0 : 30)
//        return section == 0 ? 0.01 : 40
        return 40
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section{
//        case 1:
//            return constants.TitleLunch
//        case 2:
//            return constants.TitlePersonal
//        default:
//            return nil
//        }
        switch section{
        case 0:
            return constants.TitleLunch
        case 1:
            return constants.TitlePersonal
        default:
            return nil
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
//        let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifierTrack, forIndexPath: indexPath)
//        
//        switch indexPath.section {
//        case 0:
//            cell.textLabel?.text = constants.TitleGISTrack
//            cell.imageView?.image = UIImage(named: "location3")
//        case 1:
//            if indexPath.row == 0 {
//                cell.textLabel?.text = constants.TitleLunchBreak
////                cell.imageView?.image = UIImage(named: "location10")
//            }else{
//                cell.textLabel?.text = constants.TitleLunchReturn
////                cell.imageView?.image = UIImage(named: "location")
//            }
//        default:
//            cell.textLabel?.text = personalTitle[indexPath.row]
////            cell.imageView?.image = UIImage(named: "location30")
//        }
//        return cell
        let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifierTrack, forIndexPath: indexPath)
        
        switch indexPath.section {
       
        case 0:
            if indexPath.row == 0 {
                cell.textLabel?.text = constants.TitleLunchBreak
                //                cell.imageView?.image = UIImage(named: "location10")
            }else{
                cell.textLabel?.text = constants.TitleLunchReturn
                //                cell.imageView?.image = UIImage(named: "location")
            }
        default:
            cell.textLabel?.text = personalTitle[indexPath.row]
            //            cell.imageView?.image = UIImage(named: "location30")
        }
        return cell
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        switch indexPath.section {
//        case 0:
//            self.performSegueWithIdentifier(constants.SegueToGISTrack, sender:nil)
//            
//        default:
//            let cell = tableView.cellForRowAtIndexPath(indexPath)
//            callService(cell?.textLabel?.text ?? "")
//            break
//        }
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            callService(cell?.textLabel?.text ?? "")
            
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
   
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        UILabel *lbl = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)] autorelease];
//        lbl.textAlignment = UITextAlignmentCenter;
//        lbl.font = [UIFont systemFontOfSize:12];
        
        let view =  UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40))
        
        let lbl = UILabel()
        lbl.textAlignment = .Left
        if section == 0 {
        lbl.text = constants.TitleLunch.uppercaseString
        }else{
        lbl.text = constants.TitlePersonal.uppercaseString
        }
        lbl.sizeToFit()
        lbl.font = UIFont(name: "System", size: 17)
        lbl.frame = CGRect(x: 16, y: (40-lbl.frame.size.height)/2.0, width: self.view.frame.size.width-40, height: lbl.frame.size.height)
        lbl.textColor = UIColor.darkGrayColor()
        view.addSubview(lbl)
        return view
    }
    private func getUserToken() -> OAuthTokenItem{
        let userInfo = NSUserDefaults.standardUserDefaults()
        let userInfo1 = OAuthTokenItem(dicInfo: nil)
        userInfo1.Token = userInfo.objectForKey(CConstants.UserInfoTokenKey) as? String
        userInfo1.TokenSecret = userInfo.objectForKey(CConstants.UserInfoTokenScretKey) as? String
        return userInfo1
    }
    
    private func callService(actionType : String){
       
        let requiredInfo = MoreActionRequired()
        requiredInfo.ActionType = actionType
        requiredInfo.Latitude = "\(self.locationTracker?.myLastLocation.latitude ?? 0)"
        requiredInfo.Longitude = "\(self.locationTracker?.myLastLocation.longitude ?? 0)"
        requiredInfo.HostName = UIDevice.currentDevice().name
        let tl = Tool()
        requiredInfo.IPAddress = tl.getWiFiAddress()
        let OAuthToken = self.getUserToken()
        requiredInfo.Token = OAuthToken.Token!
        //        clockOutRequiredInfo.Token = "asdfaasdf"
        requiredInfo.TokenSecret = OAuthToken.TokenSecret!
        
        print(requiredInfo.getPropertieNamesAsDictionary())
        Alamofire.request(.POST, CConstants.ServerURL + CConstants.MoreActionServiceURL,
            parameters: requiredInfo.getPropertieNamesAsDictionary()).responseJSON{ (response) -> Void in
            
                if let rtnValue = response.result.value as? Int{
                    if rtnValue == 1 {
                        self.navigationController?.popViewControllerAnimated(true)
                    }else{
                         self.PopServerError()
                    }
                }else{
                    self.PopServerError()
                }
                
           
        }
    }
    
}

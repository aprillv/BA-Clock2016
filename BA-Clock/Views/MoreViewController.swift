//
//  MoreViewController.swift
//  BA-Clock
//
//  Created by April on 3/8/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit

class MoreViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func GoBackToList(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBOutlet var tableView: UITableView!
    
    struct constants {
        static let CellIdentifierTrack = "MoreCell"
        static let SegueToGISTrack = "GISTrack"
        
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            return 2
        default:
            return 1
        }
        
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifierTrack, forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "GIS Track"
        case 1:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Lunch Break"
            }else{
                cell.textLabel?.text = "Lunch Return"
            }
        default:
            cell.textLabel?.text = "Out for Personal Reasons"
        }
        return cell
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            self.performSegueWithIdentifier(constants.SegueToGISTrack, sender:nil)
            
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

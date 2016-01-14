//
//  ClockMapViewController.swift
//  BA-Clock
//
//  Created by April on 1/12/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit

class ClockMapViewController: UITableViewController {
    var clockInfo : LoginedInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userInfo = NSUserDefaults.standardUserDefaults()
        
        title = userInfo.valueForKey(CConstants.UserFullName) as? String
        
        self.tableView.separatorColor = UIColor.clearColor()
    }
    
    private struct constants{
        static let CellIdentifier : String = "clockMapCell"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clockInfo?.ScheduledDay?.count ?? 0
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(constants.CellIdentifier, forIndexPath: indexPath)
        
        if let cellitem = cell as? ClockMapCell {
            if let item : ScheduledDayItem = clockInfo?.ScheduledDay?[indexPath.row] {
                cellitem.clockInfo = item
            }
            
            //            let ddd = CiaNmArray?[CiaNm?[indexPath.section] ?? ""]
            //            cellitem.contractInfo = ddd![indexPath.row]
            //            cell.separatorInset = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 8)
        }
        
        return cell
    }
}

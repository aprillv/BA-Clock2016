//
//  ClockHoursViewController.swift
//  BA-Clock
//
//  Created by April on 8/3/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//


class ClockHoursViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBAction func goBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    private struct constants {
        static let headCellIdentifier = "headCell"
        static let contentCellIdentifier = "contentCell"
    }
    
    var hourList : [FrequencyItem]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cs = cl_coreData()
        hourList = cs.getAllFrequency()
        tablewView.reloadData()
        
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
}

//
//  logFile.swift
//  BA-Clock
//
//  Created by April on 3/30/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit

class logFile: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var logTable: UITableView!{
        didSet{
            logTable.delegate = self
            logTable.dataSource = self
        }
    }
    
    var logc : [logs]?
    override func viewDidLoad() {
        super.viewDidLoad()
        let log = cl_log()
        logc = log.getLogs()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logc?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logcell", for: indexPath)
        let logItem = logc![indexPath.row]
//        let index = logItem.time!.startIndex
        cell.textLabel?.text = "\(logItem.time!) \(logItem.latlng!)"
//        cell.detailTextLabel?.text = "\(logItem.time!)"
        return cell
    }
}

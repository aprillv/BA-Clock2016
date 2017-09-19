//
//  TrackGPSViewController.swift
//  BA-Clock
//
//  Created by April Lv on 9/14/17.
//  Copyright © 2017 BuildersAccess. All rights reserved.
//

import UIKit
import Alamofire

class TrackGPSViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!

    fileprivate struct constants{
        static let CellIdentifier : String = "trackgpscell"
        static let SegueToTrackMap: String = "gototrackmap"
        static let SegueToTrackPerson: String = "gotoperson"
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.doSearch()
    }
    
    @IBAction func goToTrackMap(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: constants.SegueToTrackMap, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TrackGPSMapViewController {
            vc.trackList = self.trackList;
        }else if let vc1 = segue.destination as? TrackPersonViewController {
            if let item = sender as? TrackGPSDat {
                vc1.title = item.name
                vc1.username = item.username ?? ""
            }
            
        }
    }
    
    @IBOutlet weak var tableview: UITableView!
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    var trackList: [TrackGPSDat]? {
        didSet{
            self.doSearch()
        }
    }
    
    private func doSearch(){
        if (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            ftrackList = trackList?.filter({ (md) -> Bool in
                return (md.username ?? "").lowercased().contains(searchBar.text!.lowercased())
            })
        }else{
            ftrackList = trackList;
        }
         self.tableview?.reloadData();
    }
    
    var ftrackList: [TrackGPSDat]? {
        didSet{
            self.tableview?.reloadData();
        }
    }
    
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Track GPS";

        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString.init(string: "Pull to refresh");
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        self.refreshControl = refreshControl;
        
        
        if #available(iOS 10.0, *) {
            tableview.refreshControl = refreshControl
        } else {
            tableview.backgroundView = refreshControl
        }
    
    
        self.getTrackGPS()
        // Do any additional setup after loading the view.
    }
    
    func refresh(_ refreshControl: UIRefreshControl) {
        // Do your job, when done:
        self.refreshControl?.isHidden = false;
        self.getTrackGPS()
       
    }
    
    
    
    private func getTrackGPS(){
        var hud: MBProgressHUD?
        if (!(self.refreshControl?.isRefreshing ?? false)) {
            hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud?.labelText = CConstants.LoginingMsg
        }else{
            self.refreshControl?.attributedTitle = NSAttributedString.init(string: "Refreshing...");
        }
       
        
        
        // do login
        
        let userInfo = UserDefaults.standard
        if let token = userInfo.object(forKey: CConstants.UserInfoTokenKey) as? String,
            let tokenSecret = userInfo.object(forKey: CConstants.UserInfoTokenScretKey) as? String{
            let param = [
                  "Token": token
                , "TokenSecret": tokenSecret
            ]
            
            //                print0000(loginRequiredInfo.getPropertieNamesAsDictionary())
            Alamofire.request(CConstants.ServerURL + "GetTrackGPSList.json"
                , method:.post
                , parameters: param
                ).responseJSON{ (response) -> Void in
                    hud?.hide(true)
                    if (self.refreshControl?.isRefreshing ?? false){
                        self.refreshControl?.attributedTitle = NSAttributedString.init(string: "Refresh successfully.");
                        self.refreshControl?.endRefreshing()
                        self.refreshControl?.isHidden = true;
                        self.refreshControl?.attributedTitle = NSAttributedString.init(string: "Pull to refresh");
                    }
                    print(response.result.value)
                    
                    //                    self.progressBar.dismissViewControllerAnimated(true){
                    if response.result.isSuccess {
                        
                        if let rtnValue = response.result.value as? [String: AnyObject]{
                            if (rtnValue ["validtoken"] as? String ?? "0") == "1" {
                                var tmp = [TrackGPSDat]();
                                if let items = rtnValue["itemlist"] as? [[String: AnyObject]]{
                                    for fitem in items {
                                        tmp.append(TrackGPSDat(dicInfo: fitem))
                                    }
                                
                                }
                                self.trackList = tmp;
                            }
                            
                        }else{
                            self.PopServerError()
                        }
                    }else{
                        self.PopNetworkError()
                    }
                   
            }
        }
        
        
        
        
    
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ftrackList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = self.ftrackList!
        if let item : TrackGPSDat = list[indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: constants.CellIdentifier, for: indexPath)
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.numberOfLines = 2;
            cell.detailTextLabel?.text = "Last GPS \(item.lastgps ?? "")\n\(item.secondsago ?? "")"
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = self.ftrackList!
        if let item : TrackGPSDat = list[indexPath.row] {
            self.performSegue(withIdentifier: constants.SegueToTrackPerson, sender: item)
        
        }
        
    }

}

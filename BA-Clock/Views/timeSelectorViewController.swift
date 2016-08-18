//
//  timeSelectorViewController.swift
//  BA-Clock
//
//  Created by April on 4/29/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit

protocol timeSelectorDelegate {
    func finishSelectTime(xtime: NSDate, isStrat: Bool)
}
class timeSelectorViewController: BaseViewController {

   
    var delegate : timeSelectorDelegate?
    
    @IBAction func selectedTime(sender: UIDatePicker) {
        
    }
    @IBAction func doFinish(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { 
            if let del = self.delegate {
                del.finishSelectTime(self.datePicker.date, isStrat: self.timeLbl.text! == "Start Time")
            }
        }
        
    }
    @IBOutlet var heightS: NSLayoutConstraint!{
        didSet{
            heightS.constant = 1.0/UIScreen.mainScreen().scale
//            self.view.updateConstraintsIfNeeded()
            self.updateViewConstraints()
        }
    }
    @IBOutlet var timeLbl: UILabel!
    @IBOutlet var datePicker: UIDatePicker!
    
    @IBOutlet var okBtn: UIButton!{
        didSet{
            okBtn.layer.cornerRadius = 5.0
        }
    }
    var xtitle : String?
    var xdate : NSDate?
    var xminDate : NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(white: 0.5, alpha: 0.7)
        
        timeLbl.text = xtitle ?? "Start Time"
        datePicker.date = xdate ?? NSDate()
        let now = NSDate()
        
        if let x = xminDate {
            if x.timeIntervalSinceDate(now) < 0 {
                xminDate = now
            }
        }
        datePicker.minimumDate = xminDate ?? NSDate()
        datePicker.minuteInterval = 5
    }
}

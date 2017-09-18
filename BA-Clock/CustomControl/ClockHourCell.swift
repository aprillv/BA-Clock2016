//
//  ClockHourCell.swift
//  BA-Clock
//
//  Created by April on 8/3/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

class ClockHourCell: BaseCell {

    @IBOutlet var timeoutLbl: UILabel!
    @IBOutlet var timeinLbl: UILabel!
    @IBOutlet var dayLbl: UILabel!
    @IBOutlet var speratorWidth: NSLayoutConstraint!{
        didSet{
            speratorWidth.constant = 1.0 / UIScreen.main.scale
        }
    }
    
    func setCellDetail(_ item : FrequencyItem) {
        if item.ScheduledFrom == item.ScheduledTo {
            timeinLbl.text = ""
            timeoutLbl.text = ""
        }else{
            timeinLbl.text = item.ScheduledFrom ?? ""
            timeoutLbl.text = item.ScheduledTo ?? ""
        }
        
        dayLbl.text = item.DayFullName ?? ""
    }
}

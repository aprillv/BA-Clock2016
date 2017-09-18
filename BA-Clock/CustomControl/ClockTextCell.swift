//
//  ClockTextCell.swift
//  BA-Clock
//
//  Created by April on 1/13/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit

class ClockTextCell: UITableViewCell {
//image = [[UIImage imageNamed:@"message_send_box_self1.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:30];
    var clockInfo: ScheduledDayItem?{
        didSet{
            if let item = clockInfo {
                
//                https://maps.google.com/maps/api/staticmap?markers=color:red%7C29.751872,-95.362037&zoom=14&size=200x200&sensor=true
                
                clockInImage.image = UIImage(named: "clockin.png")?.stretchableImage(withLeftCapWidth: 20, topCapHeight: 26)
//                timeLbl.text = item.DayFullName! + ", " + item.Day!
                clockInText.text = "Clock In \n\(item.ClockInDay!)\n@ " + item.ClockIn!
                if item.ClockOut != "" {
                    backGroupImageView.image = UIImage(named: "clockout.png")?.stretchableImage(withLeftCapWidth: 20, topCapHeight: 26)
                    clockOutTextLbl.text = "Clock Out \n\(item.ClockOutDay!)\n@ " + item.ClockOut!
                    backGroupImageView.isHidden = false
                    clockOutTextLbl.isHidden = false
                }else{
                    backGroupImageView.isHidden = true
                    clockOutTextLbl.isHidden = true
                }
            }
        }
    }
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var clockInText: UILabel!
    @IBOutlet weak var clockInImage: UIImageView!
    @IBOutlet weak var clockOutTextLbl: UILabel!
    @IBOutlet weak var backGroupImageView: UIImageView!
}

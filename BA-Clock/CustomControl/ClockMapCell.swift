//
//  ClockMapCell.swift
//  BA-Clock
//
//  Created by April on 1/14/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import UIKit

class ClockMapCell: UITableViewCell {
    var clockInfo: ScheduledDayItem?{
        didSet{
            if let item = clockInfo {
                
                //                https://maps.google.com/maps/api/staticmap?markers=color:red%7C29.751872,-95.362037&zoom=14&size=200x200&sensor=true
                
                clockInImage.image = UIImage(named: "clockin.png")?.stretchableImageWithLeftCapWidth(20, topCapHeight: 26)
                
//                if let cor = item.ClockInCoordinate {
//                    if cor.Latitude == nil {
                    clockInMap.image = UIImage(data: NSData(contentsOfURL: NSURL(string: "https://maps.google.com/maps/api/staticmap?markers=color:red%7C\(item.ClockInCoordinate!.Latitude!),\(item.ClockInCoordinate!.Longitude!)&zoom=14&size=121x74&sensor=true")!)!)
//                    }
//                
//                }
                
                print( "https://maps.google.com/maps/api/staticmap?markers=color:red%7C\(item.ClockInCoordinate!.Latitude!),\(item.ClockInCoordinate!.Longitude!)&zoom=14&size=121x74&sensor=true")
                
                timeLbl.text = item.DayFullName! + ", " + item.Day!
                clockInText.text = "Clock In \n@ " + item.ClockIn!
                if item.ClockOut != "" {
                    backGroupImageView.image = UIImage(named: "clockout.png")?.stretchableImageWithLeftCapWidth(20, topCapHeight: 26)
                    clockOutTextLbl.text = "Clock Out \n@ " + item.ClockOut!
                    if let _ = item.ClockOutCoordinate?.Latitude {
                        print("https://maps.google.com/maps/api/staticmap?markers=color:red%7C\(item.ClockOutCoordinate!.Latitude),\(item.ClockOutCoordinate!.Longitude)&zoom=14&size=121x74&sensor=true")
                        clockOutMap.image = UIImage(data: NSData(contentsOfURL: NSURL(string: "https://maps.google.com/maps/api/staticmap?markers=color:red%7C\(item.ClockOutCoordinate!.Latitude!),\(item.ClockOutCoordinate!.Longitude!)&zoom=14&size=121x74&sensor=true")!)!)
                    }
                    
                }else{
                    backGroupImageView.hidden = true
                    clockOutTextLbl.hidden = true
                }
            }
        }
    }
    @IBOutlet weak var clockOutMap: UIImageView!
    @IBOutlet weak var clockInMap: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var clockInText: UILabel!
    @IBOutlet weak var clockInImage: UIImageView!
    @IBOutlet weak var clockOutTextLbl: UILabel!
    @IBOutlet weak var backGroupImageView: UIImageView!
}

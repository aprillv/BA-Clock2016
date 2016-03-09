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
                
//                print(clockInMap.frame)
                let width = Int(UIScreen.mainScreen().bounds.size.width-93)
                
//                if let cor = item.ClockInCoordinate {
//                    if cor.Latitude == nil {
//                if let data = NSData(contentsOfURL: NSURL(string: "https://maps.google.com/maps/api/staticmap?markers=color:red%7C\(item.ClockInCoordinate!.Latitude!),\(item.ClockInCoordinate!.Longitude!)&zoom=14&size=\(width)x148&sensor=true")!){
//                    clockInMap.image = UIImage(data: data)
//                }
                
//                clockInImage.layer.setValue("\(item.ClockInCoordinate!.Latitude!)", forKey: "lat")
//                clockInImage.layer.setValue("\(item.ClockInCoordinate!.Longitude!)", forKey: "lng")
//                clockInImage.layer.valueForKey("lat") = "\(item.ClockInCoordinate!.Latitude!)"
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                    if let data = NSData(contentsOfURL: NSURL(string: "https://maps.google.com/maps/api/staticmap?markers=color:red%7C\(item.ClockInCoordinate!.Latitude!),\(item.ClockInCoordinate!.Longitude!)&zoom=14&size=\(width)x148&sensor=true")!) {
                        let getImage =  UIImage(data: data)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.clockInMap.image = getImage
                            
                        }
                    }
                    
                }
                
                
//                    }
//                
//                }
                
                
                
//                timeLbl.text = item.DayFullName! + ", " + item.Day!
                clockInText.text = "\(item.ClockInName ?? "Clock In") \n\(item.ClockInDay!)\n@ " + item.ClockIn!
                if item.ClockOut != "" {
                    backGroupImageView.image = UIImage(named: "clockout.png")?.stretchableImageWithLeftCapWidth(20, topCapHeight: 26)
                    clockOutTextLbl.text = "\(item.ClockOutName  ?? "Clock Out") \n\(item.ClockOutDay!)\n@ " + item.ClockOut!
                    if let _ = item.ClockOutCoordinate?.Latitude {
//                        backGroupImageView.layer.setValue("\(item.ClockOutCoordinate!.Latitude!)", forKey: "lat")
//                        backGroupImageView.layer.setValue("\(item.ClockOutCoordinate!.Longitude!)", forKey: "lng")
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                            if let data = NSData(contentsOfURL: NSURL(string: "https://maps.google.com/maps/api/staticmap?markers=color:red%7C\(item.ClockOutCoordinate!.Latitude!),\(item.ClockOutCoordinate!.Longitude!)&zoom=14&size=\(width)x148&sensor=true")!) {
                                let getImage =  UIImage(data: data)
                                
                                
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.clockOutMap.image = getImage
                                    
                                }
                            }
                            
                        }
                    }
                    backGroupImageView.hidden = false
                    clockOutTextLbl.hidden = false
                    self.clockOutMap.hidden = false
                    
                }else{
                    backGroupImageView.hidden = true
                    clockOutTextLbl.hidden = true
                    self.clockOutMap.hidden = true
                }
            }
        }
    }
    
    var superActionView : AnyObject?{
        didSet{
            toADDClockInTap()
            toADDClockOutTap()
        }
    }
    @IBOutlet weak var clockOutMap: UIImageView!{
        didSet{
            toADDClockOutTap()
        }
    }
    @IBOutlet weak var clockInMap: UIImageView! {
        didSet{
            toADDClockInTap()
        }
    }
    
    private func toADDClockInTap(){
        if let _ = superActionView, let _ = clockInMap {
            let tapGestureRecognizer = UITapGestureRecognizer(target:superActionView!, action:Selector("clockInTapped:"))
            clockInMap.userInteractionEnabled = true
            tapGestureRecognizer.numberOfTapsRequired = 1
            clockInMap.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    private func toADDClockOutTap(){
        if let _ = superActionView , let _ = clockOutMap{
            let tapGestureRecognizer = UITapGestureRecognizer(target:superActionView!, action:Selector("clockOutTapped:"))
            tapGestureRecognizer.numberOfTapsRequired = 1
            clockOutMap.userInteractionEnabled = true
            clockOutMap.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var clockInText: UILabel!
    @IBOutlet weak var clockInImage: UIImageView!
    @IBOutlet weak var clockOutTextLbl: UILabel!
    @IBOutlet weak var backGroupImageView: UIImageView!
}

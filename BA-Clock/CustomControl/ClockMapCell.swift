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
                
                clockInImage.image = UIImage(named: "clockin.png")?.stretchableImage(withLeftCapWidth: 20, topCapHeight: 26)
                
//                print0000(clockInMap.frame)
                let width = Int(UIScreen.main.bounds.size.width-93)
                
//                if let cor = item.ClockInCoordinate {
//                    if cor.Latitude == nil {
//                if let data = NSData(contentsOfURL: NSURL(string: "https://maps.google.com/maps/api/staticmap?markers=color:red%7C\(item.ClockInCoordinate!.Latitude!),\(item.ClockInCoordinate!.Longitude!)&zoom=14&size=\(width)x148&sensor=true")!){
//                    clockInMap.image = UIImage(data: data)
//                }
                
//                clockInImage.layer.setValue("\(item.ClockInCoordinate!.Latitude!)", forKey: "lat")
//                clockInImage.layer.setValue("\(item.ClockInCoordinate!.Longitude!)", forKey: "lng")
//                clockInImage.layer.valueForKey("lat") = "\(item.ClockInCoordinate!.Latitude!)"
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//                    if let data = NSData(contentsOfURL: NSURL(string: "https://maps.google.com/maps/api/staticmap?markers=color:red%7C\(item.ClockInCoordinate!.Latitude!),\(item.ClockInCoordinate!.Longitude!)&zoom=14&size=\(width)x148&sensor=true")!) {
//                        let getImage =  UIImage(data: data)
//                        
//                        dispatch_async(dispatch_get_main_queue()) {
//                            self.clockInMap.image = getImage
//                            
//                        }
//                    }
//                    
//                }
                
                
//                    }
//                
//                }
                
                
                
//                timeLbl.text = item.DayFullName! + ", " + item.Day!
                if item.ClockInName != nil  && item.ClockInName != ""{
                    clockInText.text = item.ClockInName!
                    clockInTime.text = "\(item.ClockInDay!)\n" + item.ClockIn!
//                } else if item.ClockInName == "" {
//                    clockInText.text = item.ClockInName!
//                    clockInTime.text = "\(item.ClockInDay!)\n" + item.ClockIn!
                
                }else{
                    tapClockBtn.isHidden = true
                    clockInImage.isHidden = true
                    clockInText.isHidden = true
                    clockInTime.isHidden = true
                    self.clockInMap.isHidden = true
                }
                
                if item.ClockOut != "" {
                    backGroupImageView.image = UIImage(named: "clockout.png")?.stretchableImage(withLeftCapWidth: 20, topCapHeight: 26)
                    clockOutTextLbl.text = "\(item.ClockOutName  ?? "Clock Out")"
                    clockOutTime.text =  "\(item.ClockOutDay!)\n" + item.ClockOut!
//                    if let _ = item.ClockOutCoordinate?.Latitude {
////                        backGroupImageView.layer.setValue("\(item.ClockOutCoordinate!.Latitude!)", forKey: "lat")
////                        backGroupImageView.layer.setValue("\(item.ClockOutCoordinate!.Longitude!)", forKey: "lng")
//                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//                            if let data = NSData(contentsOfURL: NSURL(string: "https://maps.google.com/maps/api/staticmap?markers=color:red%7C\(item.ClockOutCoordinate!.Latitude!),\(item.ClockOutCoordinate!.Longitude!)&zoom=14&size=\(width)x148&sensor=true")!) {
//                                let getImage =  UIImage(data: data)
//                                
//                                
//                                dispatch_async(dispatch_get_main_queue()) {
//                                    self.clockOutMap.image = getImage
//                                    
//                                }
//                            }
//                            
//                        }
//                    }
                    tapClockOutBtn.isHidden = false
                    backGroupImageView.isHidden = false
                    clockOutTextLbl.isHidden = false
                     clockOutTime.isHidden = false
                    self.clockOutMap.isHidden = true
                    
                }else{
                    tapClockOutBtn.isHidden = true
                    backGroupImageView.isHidden = true
                    clockOutTextLbl.isHidden = true
                    clockOutTime.isHidden = true
                    self.clockOutMap.isHidden = true
                }
            }
        }
    }
    
    var superActionView : ClockMapViewController?{
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
    
    fileprivate func toADDClockInTap(){
        if let _ = superActionView, let _ = tapClockBtn {
            
            let tapGestureRecognizer = UITapGestureRecognizer(target:superActionView!, action:#selector(ClockMapViewController.clockInTapped(_:)))
//            let tapGestureRecognizer = UITapGestureRecognizer(target:superActionView!, action:Selector("clockInTapped:"))
            clockInMap.isUserInteractionEnabled = true
            tapGestureRecognizer.numberOfTapsRequired = 1
            clockInMap.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    @IBOutlet var tapClockOutBtn: UIButton!{
        didSet{
            toADDClockOutTap()
        }
    }
    @IBOutlet var tapClockBtn: UIButton! {
        didSet{
            toADDClockInTap()
        }
    }
    @IBAction func tapClockOutCell(_ sender: UIButton) {
        superActionView?.clockInTapped(sender)
    }
    
    @IBAction func tapClockInCell(_ sender: UIButton) {
        superActionView?.clockOutTapped(sender)
    }
    
    fileprivate func toADDClockOutTap(){
        if let _ = superActionView , let _ = tapClockOutBtn{
//            let tapGestureRecognizer = UITapGestureRecognizer(target:superActionView!, action:Selector("clockOutTapped:"))
             let tapGestureRecognizer = UITapGestureRecognizer(target:superActionView!, action:#selector(ClockMapViewController.clockOutTapped(_:)))
            tapGestureRecognizer.numberOfTapsRequired = 1
            clockOutMap.isUserInteractionEnabled = true
            clockOutMap.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    @IBOutlet var clockOutTime: UILabel!
    @IBOutlet var clockInTime: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var clockInText: UILabel!
    @IBOutlet weak var clockInImage: UIImageView!
    @IBOutlet weak var clockOutTextLbl: UILabel!
    @IBOutlet weak var backGroupImageView: UIImageView!
}

//
//  ClockResponse.swift
//  BA-Clock
//
//  Created by April on 1/19/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Foundation

class ClockResponse : BaseObject {
//    Day = "2016-01-19";
//    DayFullName = Tuesday;
//    DayName = Tue;
//    DayOfWeek = 2;
//    Message = "Please wait 23 minutes to clock in. Last clock out @ 01/19/2016 01:42:32 AM";
//    Status = "-2";
    
//    ClockedOutTime = "12:07 AM";
//    Coordinate =     {
//    Latitude = "37.33233141";
//    Longitude = "-122.0312186";
//    };
//    
    
    
    var Day : String?
    var DayFullName : String?
    var DayName : String?
    var DayOfWeek : NSNumber?
    var Message : String?
    var Status : NSNumber?
    
    var ClockedInTime : String?
    var ClockedOutTime : String?
    var Coordinate : CoordinateObject?
    
}

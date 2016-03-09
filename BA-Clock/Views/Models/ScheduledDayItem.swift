//
//  ScheduledDay.swift
//  BA-Clock
//
//  Created by April on 1/13/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Foundation

class ScheduledDayItem: BaseObject {
//    var Day: String?
//    var DayName: String?
//    var DayFullName: String?
//    var DayOfWeek: NSNumber?
    
    var ClockIn: String?
    var ClockInCoordinate : CoordinateObject?
    var ClockInDay : String?
    var ClockInDayFullName : String?
    var ClockInDayName : String?
    var ClockInDayOfWeek : NSNumber?
    
    var ClockOut: String?
    var ClockOutCoordinate : CoordinateObject?
    var ClockOutDay : String?
    var ClockOutDayFullName : String?
    var ClockOutDayName : String?
    var ClockOutDayOfWeek : NSNumber?
    
    var Hours: NSNumber?
    
    var ClockInName: String?
    var ClockOutName: String?
    
}

//
//  ScheduledDay.swift
//  BA-Clock
//
//  Created by April on 1/13/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Foundation

class ScheduledDayItem: BaseObject {
    var Day: String?
    var DayName: String?
    var DayFullName: String?
    var DayOfWeek: NSNumber?
    var ClockIn: String?
    var ClockOut: String?
    var Hours: NSNumber?
    var ClockInCoordinate : CoordinateObject?
    var ClockOutCoordinate : CoordinateObject?
}

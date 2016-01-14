//
//  LoginedInfo.swift
//  BA-Clock
//
//  Created by April on 1/13/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Foundation

class LoginedInfo: BaseObject {
    var UserName: String?
    var CurrentDayOfWeek: NSNumber?
    var CurrentDayName: String?
    var CurrentDayFullName: String?
    var CurrentScheduledInterval: NSNumber?
    var ScheduledDay: [ScheduledDayItem]?
    var IsClockedIn : NSNumber?
    var IsClockedOut : NSNumber?
    var UserFullName : String?
    
}

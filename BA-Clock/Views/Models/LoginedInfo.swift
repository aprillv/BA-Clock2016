//
//  LoginedInfo.swift
//  BA-Clock
//
//  Created by April on 1/13/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Foundation

class LoginedInfo: BaseObject {
    
    var CurrentDayOfWeek: NSNumber?
    var CurrentDayName: String?
    var CurrentDayFullName: String?
    var CurrentScheduledInterval: NSNumber?
    var ScheduledDay: [ScheduledDayItem]?
    var OAuthToken: OAuthTokenItem?
    var Frequency : [FrequencyItem]?
    var ScheduledFrom: String?
    var ScheduledTo : String?
    var UserName: String?
    var UserFullName : String?
    
}

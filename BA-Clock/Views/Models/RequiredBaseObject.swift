//
//  RequiredBaseObject.swift
//  BA-Clock
//
//  Created by April on 1/14/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Foundation
class RequiredBaseObject : NSObject {
    
    func getPropertieNamesAsDictionary() -> [String: String]{
        
        var outCount:UInt32
        outCount = 0
        let peopers:UnsafeMutablePointer<objc_property_t>! =  class_copyPropertyList(self.classForCoder, &outCount)
        let count:Int = Int(outCount);
        var selfDicInfo : [String: String] = [String: String]()
        for i in 0...(count-1) {
            let aPro: objc_property_t = peopers[i]
            let proName: String! = String(UTF8String: property_getName(aPro))
            if let v = valueForKey(proName) as? String {
                selfDicInfo[proName] = v
            }else{
                selfDicInfo[proName] = ""
            }
        }
        return selfDicInfo
        
    }
    
    func getPropertieNamesAsString() -> String{
        
        var outCount:UInt32
        outCount = 0
        let peopers:UnsafeMutablePointer<objc_property_t>! =  class_copyPropertyList(self.classForCoder, &outCount)
        let count:Int = Int(outCount);
        var selfDicInfo : String = "{"
        for i in 0...(count-1) {
            let aPro: objc_property_t = peopers[i]
            let proName: String! = String(UTF8String: property_getName(aPro))
            if let v = valueForKey(proName) {
                selfDicInfo.appendContentsOf("\"" + proName + "\": \"\(v)\"")
            }else{
                selfDicInfo.appendContentsOf("\"" + proName + "\": \"\"")
            }
            if i != count - 1 {
                selfDicInfo.appendContentsOf(", ")
            }
        }
        selfDicInfo.appendContentsOf("}")
        return selfDicInfo
    }
}
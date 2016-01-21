//
//  BaseObject.swift
//  BA-Clock
//
//  Created by April on 1/13/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Foundation

class BaseObject: RequiredBaseObject {
    required init(dicInfo : [String: AnyObject]?){
        super.init()
        if let dic = dicInfo {
        self.setValuesForKeysWithDictionary(dic)
        }
        
    }
    
    private struct constants  {
        static let projectName : String = "BA_Clock."
        //        NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
        static let lastName : String = "Item"
        
    }
    
    
    override func setValue(value0: AnyObject?, forKey key: String) {
        var skey : String
        skey = key
//        print(skey)
        let dic = self.getPropertieNamesAsDictionary()
        if dic.keys.contains(key) {
            if let value = value0{
                if let dic = value as? [Dictionary<String, AnyObject>]{
                    var tmpArray : [BaseObject] = [BaseObject]()
                    for tmp0 in dic{
                        //                    print(NSStringFromClass(BaseObject))
                        let anyobjecType: AnyObject.Type = NSClassFromString(GetCapitalFirstWord(skey)!)!
                        if anyobjecType is BaseObject.Type {
                            let vc = (anyobjecType as! BaseObject.Type).init(dicInfo: tmp0)
                            tmpArray.append(vc)
                        }
                    }
                    super.setValue(tmpArray, forKey: skey)
                
                }else if let dic = value as? Dictionary<String, AnyObject>{
                    if skey.lowercaseString.containsString("coordinate"){
                        let vc : CoordinateObject = CoordinateObject.init(dicInfo: dic)
                        super.setValue(vc, forKey: skey)
                    }else{
                        let anyobjecType: AnyObject.Type = NSClassFromString(GetObjectStr(skey)!)!
                        if anyobjecType is BaseObject.Type {
                            let vc = (anyobjecType as! BaseObject.Type).init(dicInfo: dic)
                            super.setValue(vc, forKey: skey)
                        }
                    }
//                    if skey == "OAuthToken"{
//                        let vc : OAuthTokenItem = OAuthTokenItem.init(dicInfo: dic)
//                        super.setValue(vc, forKey: skey)
//                    }else if skey == "Frequency"{
//                        let vc : FrequencyItem = FrequencyItem.init(dicInfo: dic)
//                        super.setValue(vc, forKey: skey)
//                    
//                    }else{
//                        
//                    }
                    
                }else{
                    super.setValue(value, forKey: skey as String)
                }
            }
        }
        
        
    }
    
    private func GetCapitalFirstWord(str : String?) -> String?{
        if let str0 = str {
            let index = str0.startIndex.advancedBy(1)
            let firstCapitalWord = str0.substringToIndex(index).capitalizedString
            return constants.projectName + firstCapitalWord + str0.substringFromIndex(index) + constants.lastName
        }
        return nil
    }
    
    private func GetObjectStr(str : String) -> String?{
        return constants.projectName + str + constants.lastName
    }
    
}

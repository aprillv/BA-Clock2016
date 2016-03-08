//
//  extensionViewController.swift
//  BA-Clock
//
//  Created by April on 1/26/16.
//  Copyright © 2016 BuildersAccess. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func noticeOnlyText(text: String) {
        SwiftNotice.showText(text)
    }
    
    func clearNotice() {
        SwiftNotice.clear()
    }
    
}

class SwiftNotice: NSObject {
    static let rv = UIApplication.sharedApplication().keyWindow?.subviews.first as UIView!
    //    static var timer: dispatch_source_t!
    //    static var timerTimes = 0
    static var degree: Double {
        get {
            return [0, 0, 180, 270, 90][UIApplication.sharedApplication().statusBarOrientation.hashValue] as Double
        }
    }
    
    static var windows = Array<UIWindow!>()
    
    //    static var center: CGPoint {
    //        get {
    //            var array = [UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height]
    //            array = array.sort(<)
    //            let screenWidth = array[0]
    //            let screenHeight = array[1]
    //            let x = [0, screenWidth/2, screenWidth/2, 10, screenWidth-10][UIApplication.sharedApplication().statusBarOrientation.hashValue] as CGFloat
    //            let y = [0, 10, screenHeight-10, screenHeight/2, screenHeight/2][UIApplication.sharedApplication().statusBarOrientation.hashValue] as CGFloat
    //            return CGPointMake(x, y)
    //        }
    //    }
    
    static func showText(text: String) {
        let window = UIWindow()
        window.backgroundColor = UIColor.clearColor()
        let mainView = UIView()
        mainView.layer.cornerRadius = 12
//        mainView.backgroundColor = UIColor(red:20/255.0, green:72/255.0, blue:116/255.0, alpha: 1)
        mainView.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 1)
//        mainView.backgroundColor = UIColor(red:1, green:1, blue:1, alpha: 0.95)
        
        let spinner1 = UIActivityIndicatorView()
        spinner1.hidesWhenStopped = true
        spinner1.activityIndicatorViewStyle = .White
        spinner1.sizeToFit()
//        print(spinner1)
        mainView.addSubview(spinner1)
        
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(16)
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
//        print(label)
        mainView.addSubview(label)
        
        
        let superFrame = CGRectMake(0, 0, label.frame.width + 50 + spinner1.frame.width + 10 , label.frame.height + 30)
//        window.frame = superFrame
        window.backgroundColor = UIColor(red:0, green:0, blue:0, alpha: 0.2)
        mainView.frame = superFrame
        mainView.center = window.center
        
        spinner1.frame = CGRect(x: 25, y: 15, width: spinner1.frame.size.width, height: spinner1.frame.size.height)
        label.frame = CGRect(x: 35 + spinner1.frame.size.width, y: 15, width: label.frame.size.width, height: label.frame.size.height)
//        label.center = mainView.center
        
        window.windowLevel = UIWindowLevelAlert
        window.center = getRealCenter()
        // change orientation
//        window.transform = CGAffineTransformMakeRotation(CGFloat(degree * M_PI / 180))
        window.hidden = false
        window.addSubview(mainView)
        spinner1.startAnimating()
        windows.append(window)
    }
    
    
    
    // fix orientation problem
    static func getRealCenter() -> CGPoint {
        if UIApplication.sharedApplication().statusBarOrientation.hashValue >= 3 {
            return CGPoint(x: rv.center.y, y: rv.center.x)
        } else {
            return rv.center
        }
    }
    
    static func clear() {
        self.cancelPreviousPerformRequestsWithTarget(self)
//        if let _ = timer {
//            dispatch_source_cancel(timer)
//            timer = nil
//            timerTimes = 0
//        }
        windows.removeAll(keepCapacity: false)
    }
    
}
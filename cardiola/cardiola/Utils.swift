//
//  Utils.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation
import UIKit

class GlobalDispatchUtils {
    
    static var MainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    static var UserInteractiveQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
    }
    
    static var UserInitiatedQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
    }
    
    static var UtilityQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
    }
    
    static var BackgroundQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
    }
}

class Colors {
    
    static var red = UIColor(red: 0.9, green: 0.05, blue: 0.05, alpha: 1.0)
    
    static var lightgray = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    
    static var gray = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    
    static var darkGray = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
    
    static var translucent = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
}


func random(min min: Int, max:Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
}


func formatDate(date: NSDate?, dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String {
    guard let date = date else {
        return ""
    }
    return NSDateFormatter.localizedStringFromDate(date, dateStyle: dateStyle, timeStyle: timeStyle)
}

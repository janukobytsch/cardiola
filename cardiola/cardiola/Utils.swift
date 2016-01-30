//
//  Utils.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation

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


func random(min min: Int, max:Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
}


func formatDate(date: NSDate?, dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String {
    guard let date = date else {
        return ""
    }
    return NSDateFormatter.localizedStringFromDate(date, dateStyle: dateStyle, timeStyle: timeStyle)
}
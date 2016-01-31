//
//  NSDate+SameDay.swift
//  cardiola
//
//  Created by Janusch Jacoby on 31/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation

extension NSDate {
    
    var day: Int {
        let components = self.getAllComponentsForCurrentCalendar()
        return components.day
    }
    
    var month: Int {
        let components = self.getAllComponentsForCurrentCalendar()
        return components.month
    }
    
    var year: Int {
        let components = self.getAllComponentsForCurrentCalendar()
        return components.year
    }
    
    func isSameDayAs(otherDate: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags = NSCalendarUnit(rawValue: UInt.max)
        let comp1 = calendar.components(unitFlags, fromDate: self)
        let comp2 = calendar.components(unitFlags, fromDate: otherDate)
        
        return comp1.day == comp2.day
            && comp1.month == comp2.month
            && comp1.year == comp2.year
    }
    
    func getAllComponentsForCurrentCalendar() -> NSDateComponents {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags = NSCalendarUnit(rawValue: UInt.max)
        return calendar.components(unitFlags, fromDate: self)
    }
    
}
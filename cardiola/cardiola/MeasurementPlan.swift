//
//  MeasurementPlan.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation

class MeasurementPlan: NSObject {
    
    var id: Int?
    var entries: [MeasurementPlanEntry]? {
        didSet {
            self.entries?.sortInPlace({ $0.dueDate < $1.dueDate })
        }
    }
    
    var nextEntry: MeasurementPlanEntry? {
        return entries?.last
    }
    
    init(entries: [MeasurementPlanEntry]) {
        super.init()
        self.entries = entries
    }
    
    /**
     Factory method to create a random plan for demo purposes.
     
     - returns: plan for next week
     */
    static func createRandomWeek() -> MeasurementPlan {
        var entries = [MeasurementPlanEntry]()
        for index in 0...6 {
            let timeInterval = NSTimeInterval(5 * 64 + index * 86400)
            let date = NSDate(timeIntervalSinceNow: timeInterval)
            let entry = MeasurementPlanEntry(dueDate: date)
            entries.append(entry)
        }
        return MeasurementPlan(entries: entries)
    }
}
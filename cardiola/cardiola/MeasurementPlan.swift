//
//  MeasurementPlan.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation
import RealmSwift

class MeasurementPlan: Object, PersistentModel {
    dynamic var id: String = NSUUID().UUIDString
    override static func primaryKey() -> String? {
        return "id"
    }
    
    let entries = List<MeasurementPlanEntry>()
    
    var nextEntry: MeasurementPlanEntry? {
        return entries.last
    }
    
    convenience init(entries: [MeasurementPlanEntry]) {
        self.init()
        self.entries.appendContentsOf(entries)
    }
    
    func prependEntry(entry: MeasurementPlanEntry) {
        self.entries.insert(entry, atIndex: 0)
        entry.save()
    }
    
    /**
     Factory method to create a random plan for demo purposes.
     
     - returns: plan for next week
     */
    static func createRandomWeek() -> MeasurementPlan {
        var entries = [MeasurementPlanEntry]()
        
        // Load from database
        let realm = try! Realm()
        let dbEntries = realm.objects(MeasurementPlanEntry)
        
        entries.appendContentsOf(dbEntries.asArray())
        print("Got from db", entries.count)
        
        for index in 0...6 {
            let timeInterval = NSTimeInterval(5 * 64 + index * 86400)
            let date = NSDate(timeIntervalSinceNow: timeInterval)
            let entry = MeasurementPlanEntry(dueDate: date, isMandatory: true, isBloodPressureEntry: true, isHeartRateEntry: true)
            
            entries.append(entry)
        }
        return MeasurementPlan(entries: entries)
    }
}
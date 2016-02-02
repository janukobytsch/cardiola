//
//  PlanRepository.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import RealmSwift

class PlanRepository {
    
    private var _currentPlan: MeasurementPlan?
    
    var currentPlan: MeasurementPlan {
        if (_currentPlan == nil) {
            // attempt to load from database
            var entries = [MeasurementPlanEntry]()
            let realm = try! Realm()
            let dbEntries = realm.objects(MeasurementPlanEntry)
            
            entries.appendContentsOf(dbEntries.asArray())
            
            if entries.count == 0 {
                // generate mock data
                entries = PlanRepository.createRandomEntries()
            }
            
            let plan = MeasurementPlan(entries: entries)
            self._currentPlan = plan
        }
        return self._currentPlan!
    }
    
    /**
     Factory method to create a random plan for demo purposes.
     
     - returns: plan for next week
     */
    static func createRandomEntries() -> [MeasurementPlanEntry] {
        var entries = [MeasurementPlanEntry]()
        
        for index in 0...3 {
            let timeInterval = NSTimeInterval(5 * 64 + index * 86400)
            let date = NSDate(timeIntervalSinceNow: timeInterval)
            let entry = MeasurementPlanEntry(dueDate: date)
            entry.isBloodPressureEntry = random(min: 0, max: 1) == 0
            entry.isHeartRateEntry = random(min: 0, max: 1) == 0
            entry.pending()
            entry.save()
            entries.append(entry)
        }
        
        return entries
    }
    
    
}
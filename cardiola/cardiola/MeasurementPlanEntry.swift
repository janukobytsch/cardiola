//
//  MeasurementPlanEntry.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation
import RealmSwift

class MeasurementPlanEntry: Object, PersistentModel, Equatable {
    dynamic var id: String = NSUUID().UUIDString
    override static func primaryKey() -> String? {
        return "id"
    }
    
    dynamic var dueDate: NSDate?
    dynamic var isMandatory: Bool = false
    dynamic var data: Measurement?
    dynamic var isBloodPressureEntry = false
    dynamic var isHeartRateEntry = false
    
    var formattedDate: String {
        //        let formatter = NSDateFormatter()
        //        formatter.locale = NSLocale(localeIdentifier: "de_DE")
        return formatDate(self.dueDate, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    
    var formattedTime: String {
        return formatDate(self.dueDate, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.FullStyle)
    }
    
    convenience init(dueDate: NSDate, isMandatory: Bool, isBloodPressureEntry: Bool = false, isHeartRateEntry: Bool = false) {
        self.init()
        self.isMandatory = isMandatory
        self.dueDate = dueDate
        self.data = nil
        
        self.isBloodPressureEntry = isBloodPressureEntry
        self.isHeartRateEntry = isHeartRateEntry
    }
    
    convenience init(dueDate: NSDate) {
        self.init(dueDate: dueDate, isMandatory: true)
    }
    
    func setMeasurement(measurement: Measurement) {
        self.data = measurement
    }
    
    // MARK: Formatting
    
    private func _formatDate(dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String {
        guard let dueDate = self.dueDate else {
            return ""
        }
        return NSDateFormatter.localizedStringFromDate(dueDate, dateStyle: dateStyle,
            timeStyle: timeStyle)
        
    }
    
    // MARK: Creation
    
    internal static func createRandom() -> MeasurementPlanEntry {
        let timeInterval = NSTimeInterval(5 * 64 + random(min: 0, max: 14) * 86400)
        let date = NSDate(timeIntervalSinceNow: timeInterval)
        
        let newEntry = MeasurementPlanEntry(dueDate: date, isMandatory: true, isBloodPressureEntry: true, isHeartRateEntry: true)
        // newEntry.setMeasurement(Measurement.createRandom())
        return newEntry
    }
}

// MARK: Equatable

func ==(lhs: MeasurementPlanEntry, rhs: MeasurementPlanEntry) -> Bool {
    return lhs.id == rhs.id
}
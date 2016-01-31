//
//  MeasurementPlanEntry.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation

enum MeasurementPlanEntryType {
    case BloodPressure, HeartRate
}

class MeasurementPlanEntry: NSObject {
    
    var id: Int?
    var dueDate: NSDate?
    var isMandatory: Bool?
    var data: Measurement?
    var types: [MeasurementPlanEntryType] = [MeasurementPlanEntryType]()
    
    var formattedDate: String {
//        let formatter = NSDateFormatter()
//        formatter.locale = NSLocale(localeIdentifier: "de_DE")
        return formatDate(self.dueDate, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    
    var formattedTime: String {
        return formatDate(self.dueDate, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.FullStyle)
    }
    
    init(dueDate: NSDate, isMandatory: Bool, types : [MeasurementPlanEntryType]? = nil) {
        super.init()
        self.dueDate = dueDate
        self.isMandatory = isMandatory
        self.data = nil
        
        if types != nil {
            self.addTypes(types!)
        }
    }
    
    convenience init(dueDate: NSDate) {
        self.init(dueDate: dueDate, isMandatory: true)
    }
    
    func setMeasurement(measurement: Measurement) {
        self.data = measurement
    }
    
    func setTypes(types: [MeasurementPlanEntryType]) {
        self.types = types
    }
    
    func addTypes(types: [MeasurementPlanEntryType]) {
        self.types += types
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
        
        let newEntry = MeasurementPlanEntry(dueDate: date, isMandatory: true, types: [MeasurementPlanEntryType.HeartRate, MeasurementPlanEntryType.BloodPressure])
        // newEntry.setMeasurement(Measurement.createRandom())
        return newEntry
    }

}
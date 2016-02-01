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

    // MARK: PersistentModel

    dynamic var id: String = NSUUID().UUIDString

    override static func primaryKey() -> String? {
        return "id"
    }

    // MARK: Properties

    dynamic var dueDate: NSDate?
    dynamic var data: Measurement?
    
    // vital parameters that should be included in the entrie's measurement
    dynamic var isBloodPressureEntry = false
    dynamic var isHeartRateEntry = false
    
    // assumes one of the following states
    dynamic var isPending: Bool = false
    dynamic var isActive: Bool = true
    dynamic var isArchived: Bool = false

    var formattedDate: String {
        //        let formatter = NSDateFormatter()
        //        formatter.locale = NSLocale(localeIdentifier: "de_DE")
        return formatDate(self.dueDate, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }

    var formattedTime: String {
        return formatDate(self.dueDate, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.FullStyle)
    }
    
    // MARK: Initializer

    convenience init(dueDate: NSDate, isBloodPressureEntry: Bool = false, isHeartRateEntry: Bool = false) {
        self.init()
        self.dueDate = dueDate
        self.data = nil
        self.isBloodPressureEntry = isBloodPressureEntry
        self.isHeartRateEntry = isHeartRateEntry
    }

    func setMeasurement(measurement: Measurement) {
        self.data = measurement
    }
    
    // MARK: States
    
    func activate() {
        self.isActive = true
        self.isArchived = false
        self.isPending = false
    }
    
    func archive() {
        self.isActive = false
        self.isArchived = true
        self.isPending = false
        self._synchronize()
    }
    
    func pending() {
        self.isActive = false
        self.isArchived = false
        self.isPending = true
    }
    
    private func _synchronize() {
        self.dueDate = self.data!.date ?? NSDate()
        self.data!.date = self.dueDate
        self.isBloodPressureEntry = self.data!.hasBloodPressure
        self.isHeartRateEntry = self.data!.hasHeartRate
    }

    // MARK: Formatting

    private func _formatDate(dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String {
        guard let dueDate = self.dueDate else {
            return ""
        }
        return NSDateFormatter.localizedStringFromDate(dueDate, dateStyle: dateStyle,
            timeStyle: timeStyle)

    }

    // MARK: Factory methods
    
    internal static func createVoluntaryPlanEntry(data: Measurement) -> MeasurementPlanEntry {
        let entry = MeasurementPlanEntry(dueDate: NSDate(), isBloodPressureEntry: true, isHeartRateEntry: true)
        entry.data = data
        return entry
    }
    
    internal static func withMeasurement(measurement: Measurement) -> MeasurementPlanEntry {
        let date = measurement.date ?? NSDate()
        let isBloodPressureEntry = measurement.diastolicPressure != nil || measurement.systolicPressure != nil
        let isHeartRateEntry = measurement.heartRate != nil
        let newEntry = MeasurementPlanEntry(dueDate: date, isBloodPressureEntry: isBloodPressureEntry, isHeartRateEntry: isHeartRateEntry)
        return newEntry
    }
}

// MARK: Equatable

func ==(lhs: MeasurementPlanEntry, rhs: MeasurementPlanEntry) -> Bool {
    return lhs.id == rhs.id
}

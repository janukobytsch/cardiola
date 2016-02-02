//
//  Measurement.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import RealmSwift
import Foundation
import Charts

class Measurement: Object, PersistentModel {
    
    static let SYSTOLIC_MAX = 200
    static let SYSTOLIC_AVG = 120
    static let DIASTOLIC_MAX = 130
    static let DIASTOLIC_AVG = 75
    static let HEART_RATE_MAX = 160
    static let HEART_RATE_RESTING = 70
    static let HEART_RATE_STRESS = 130
    
    // MARK: Properties
    
    dynamic var patient: Patient?
    
    private let _heartRate = RealmOptional<Int>()
    var heartRate: Int? {
        get {
            return _heartRate.value
        }
        set(newValue) {
            _heartRate.value = newValue
        }
    }
    
    private let _systolicPressure = RealmOptional<Int>()
    var systolicPressure: Int? {
        get {
            return _systolicPressure.value
        }
        set(newValue) {
            _systolicPressure.value = newValue
        }
    }
    
    private let _diastolicPressure = RealmOptional<Int>()
    var diastolicPressure: Int? {
        get {
            return _diastolicPressure.value
        }
        set(newValue) {
            _diastolicPressure.value = newValue
        }
    }
    
    var hasBloodPressure: Bool {
        return self.diastolicPressure != nil || self.systolicPressure != nil
    }
    
    var hasHeartRate: Bool {
        return self.heartRate != nil
    }
    
    dynamic var date: NSDate?
    
    var formattedDate: String {
        return formatDate(self.date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    
    var formattedTime: String {
        return formatDate(self.date, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    }
    
    // MARK: Charts
    
    // provides x and y values for plotting the attribute radar
    var attributeRadar: ([String], [ChartDataEntry]) {
        let xValues = ["Systolischer Blutdruck", "Diastolischer Blutdruck", "Pulsrate", "Blutzucker", "Sauferstoffsättigung", "Persönliches Befinden"]
        // TODO: support missing vital parameters
        let properties = [self.systolicPressure, self.diastolicPressure, self.heartRate, 0, 0, 0]
        let yValues = properties.enumerate().map() {
            return ($0.1 != nil) ? ChartDataEntry(value: 1.0, xIndex: $0.0) : ChartDataEntry(value: 0.0, xIndex: $0.0)
        }
        return (xValues, yValues)
    }
    
    // MARK: Initialization
    
    convenience init(heartRate: Int, systolicPressure: Int, diastolicPressure: Int) {
        self.init()
        
        self.heartRate = heartRate
        self.systolicPressure = systolicPressure
        self.diastolicPressure = diastolicPressure
        self.date = NSDate()
    }
    
    convenience init(systolicPressure: Int, diastolicPressure: Int) {
        self.init(heartRate: 0, systolicPressure: systolicPressure, diastolicPressure: diastolicPressure)
    }
    
    convenience init(heartRate: Int) {
        self.init(heartRate: heartRate, systolicPressure: 0, diastolicPressure: 0)
    }
    
    // MARK: Factory methods
    
    internal static func createRandom() -> Measurement {
        let systolic = random(min: 120, max: 180)
        let diastolic = random(min: 70, max: 100)
        let heartRate = random(min: 60, max: 130)
        let measurement = Measurement(heartRate: heartRate, systolicPressure: systolic, diastolicPressure: diastolic)
        return measurement
    }
    
    // MARK: PersistentModel
    
    dynamic var id: String = NSUUID().UUIDString
    
    override static func primaryKey() -> String? {
        return "id"
    }
}


// define convenience methods on measurement arrays
extension _ArrayType where Generator.Element == Measurement {
    
    func averageHeartRate() -> Double? {
        guard self.count != 0 else {
            return nil
        }
        let heartRates = self.flatMap({ $0.heartRate })
        return Double(heartRates.reduce(0, combine: {$0 + $1 })) / Double(self.count)
    }
    
    func maxHeartRate() -> Int? {
        guard self.count != 0 else {
            return nil
        }
        let heartRates = self.flatMap({ $0.heartRate })
        return heartRates.maxElement()
    }
}

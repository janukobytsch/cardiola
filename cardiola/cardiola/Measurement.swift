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
    dynamic var id: String = NSUUID().UUIDString
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
    static let SYSTOLIC_MAX = 200
    static let SYSTOLIC_AVG = 120
    static let DIASTOLIC_MAX = 130
    static let DIASTOLIC_AVG = 75
    static let HEART_RATE_MAX = 160
    static let HEART_RATE_RESTING = 70
    static let HEART_RATE_STRESS = 130
    
    dynamic var patient: Patient?
    let heartRate = RealmOptional<Int>()
    let systolicPressure = RealmOptional<Int>()
    let diastolicPressure = RealmOptional<Int>()
    dynamic var date: NSDate?
    
    var formattedDate: String {
        return formatDate(self.date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    
    var formattedTime: String {
        return formatDate(self.date, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    }
    
    convenience init(heartRate: Int, systolicPressure: Int, diastolicPressure: Int) {
        self.init()
        self.heartRate.value = heartRate
        self.systolicPressure.value = systolicPressure
        self.diastolicPressure.value = diastolicPressure
        self.date = NSDate()
    }
    
    convenience init(systolicPressure: Int, diastolicPressure: Int) {
        self.init(heartRate: 0, systolicPressure: systolicPressure, diastolicPressure: diastolicPressure)
    }
    
    convenience init(heartRate: Int) {
        self.init(heartRate: heartRate, systolicPressure: 0, diastolicPressure: 0)
    }
    
    // MARK: Creation
    
    internal static func createRandom() -> Measurement {
        let systolic = random(min: 120, max: 180)
        let diastolic = random(min: 70, max: 100)
        let heartRate = random(min: 60, max: 130)
        return Measurement(heartRate: heartRate, systolicPressure: systolic, diastolicPressure: diastolic)
    }
}


extension _ArrayType where Generator.Element == Measurement {
    
    func averageHeartRate() -> Double? {
        guard self.count != 0 else {
            return nil
        }
        let heartRates = self.flatMap({ $0.heartRate.value })
        return Double(heartRates.reduce(0, combine: {$0 + $1 })) / Double(self.count)
    }
    
    func maxHeartRate() -> Int? {
        guard self.count != 0 else {
            return nil
        }
        let heartRates = self.flatMap({ $0.heartRate.value })
        return heartRates.maxElement()
    }
}
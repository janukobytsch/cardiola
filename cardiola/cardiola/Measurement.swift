//
//  Measurement.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation


class Measurement: NSObject {
    
    var id: Int?
    var patient: Patient?
    var pulse: Int?
    var systolicPressure: Int?
    var diastolicPressure: Int?
    var date: NSDate?
    
    var formattedDate: String {
        return formatDate(self.date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    
    init(pulse: Int, systolicPressure: Int, diastolicPressure: Int) {
        super.init()
        self.pulse = pulse
        self.systolicPressure = systolicPressure
        self.diastolicPressure = diastolicPressure
        self.date = NSDate()
    }
    
    convenience init(systolicPressure: Int, diastolicPressure: Int) {
        self.init(pulse: 0, systolicPressure: systolicPressure, diastolicPressure: diastolicPressure)
    }
    
    convenience init(pulse: Int) {
        self.init(pulse: pulse, systolicPressure: 0, diastolicPressure: 0)
    }

    static func createRandom() -> Measurement {
        let systolic = random(min: 120, max: 180)
        let diastolic = random(min: 70, max: 100)
        return Measurement(systolicPressure: systolic, diastolicPressure: diastolic)
    }
}
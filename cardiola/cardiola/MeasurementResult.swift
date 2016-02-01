//
//  MeasurementResult.swift
//  cardiola
//
//  Created by Janusch Jacoby on 01/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//


// temporary structs to capture measuremen results
protocol MeasurementResult { }

struct BloodPressureResult: MeasurementResult {
    
    let systolicPressure: Int
    let diastolicPressure: Int
    
    init(systolicPressure: Int, diastolicPressure: Int) {
        self.systolicPressure = systolicPressure
        self.diastolicPressure = diastolicPressure
    }
}

struct HeartRateResult: MeasurementResult {
    
    let heartRate: Int
    
    init(heartRate: Int) {
        self.heartRate = heartRate
    }
}

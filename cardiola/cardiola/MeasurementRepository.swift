//
//  MeasurementRepository.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation


class MeasurementRepository {
    
    // todo: retrieve stored measurements from core data
    // todo: associate measurement with plan entry
    
    static func createRandomDataset() -> [Measurement] {
        var measurements = [Measurement]()
        for _ in 0...7 {
            let measurement = Measurement.createRandom()
            measurements.append(measurement)
        }
        return measurements
    }
}
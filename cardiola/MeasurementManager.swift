//
//  MeasurementManager.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation
import Charts

internal protocol MeasurementManager {

    // MARK: Initializer
    
    init(realtimeChart: ChartViewBase, historyChart: ChartViewBase)
    
    // MARK: Delegate
    
    func startMeasurement()
    func beforeModeChanged()
    func afterModeChanged()
    
    // MARK: Measuring
    
    func updateRealtimeData(with measurement: Measurement)
    func updateHistoryData(with measurements: [Measurement])
    
}
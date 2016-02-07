//
//  MeasurementManager.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation
import Charts

// serves as a sub-controller
protocol MeasurementManager {
    
    // MARK: Properties
    
    var recorder: MeasurementRecorder { get }

    // MARK: Initializer
    
    init(realtimeChart: ChartViewBase, historyChart: ChartViewBase, recorder: MeasurementRecorder)
    
    // MARK: Delegate
    
    func startMeasurement()
    func hasComponent() -> Bool
    func beforeModeChanged()
    func afterModeChanged()
    
    // MARK: Measuring
    
    func updateRealtimeData()
    func updateHistoryData()
    
}
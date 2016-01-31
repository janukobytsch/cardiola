//
//  MeasurementController.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import UIKit
import Charts

class MeasurementController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var historyBarChart: BarChartView!
    @IBOutlet weak var realtimeBarChart: BarChartView!
    @IBOutlet weak var realtimeLineChart: LineChartView!
    @IBOutlet weak var heartRateHistoryChart: CombinedChartView!
    
    var bloodPressureManager: BloodPressureMeasurementManager?
    var heartFrequencyManager: HeartFrequencyMeasurementManager?
    var currentManager: MeasurementManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let measurements = MeasurementRepository.createRandomDataset()
        
        bloodPressureManager = BloodPressureMeasurementManager(realtimeChart: realtimeBarChart, historyChart: historyBarChart)
        bloodPressureManager!.updateHistoryData(with: measurements)
        
        heartFrequencyManager = HeartFrequencyMeasurementManager(realtimeChart: realtimeLineChart, historyChart: heartRateHistoryChart)
        heartFrequencyManager!.updateHistoryData(with: measurements)

        currentManager = bloodPressureManager
        currentManager?.afterModeChanged()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func simulateRealtime() {
        for count in 0...30 {
            let delaySeconds = 600.0 * Double(count)
            let waitTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySeconds * Double(NSEC_PER_MSEC)))
            
            dispatch_after(waitTime, GlobalDispatchUtils.MainQueue) {
                let measurement = Measurement.createRandom()
                self.currentManager?.updateRealtimeData(with: measurement)
            }
        }
    }
    
    @IBAction func startMeasurement(sender: UIButton) {
        sender.enabled = false
        sender.hidden = true
        currentManager?.startMeasurement()
        simulateRealtime()
    }
    
    @IBAction func changeMeasurementMode(sender: UISegmentedControl) {
        currentManager?.beforeModeChanged()
        switch sender.selectedSegmentIndex {
        case 1:
            currentManager = heartFrequencyManager
            simulateRealtime()
        case 0:
            currentManager = bloodPressureManager
        default:
            currentManager = bloodPressureManager
        }
        currentManager?.afterModeChanged()
    }

}

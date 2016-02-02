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
    @IBOutlet weak var indicatorView: UIStackView!
    @IBOutlet weak var measureButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    override var preferredFocusedView: UIView? {
        get {
            return self.segmentedControl
        }
    }
    
    var bloodPressureManager: BloodPressureMeasurementManager?
    var heartFrequencyManager: HeartFrequencyMeasurementManager?
    var currentManager: MeasurementManager?
    
    var measurementRecorder: MeasurementRecorder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let measurements = MeasurementRepository.createRandomDataset()
        
        bloodPressureManager = BloodPressureMeasurementManager(realtimeChart: realtimeBarChart, historyChart: historyBarChart)
        bloodPressureManager!.updateHistoryData(with: measurements)
        
        heartFrequencyManager = HeartFrequencyMeasurementManager(realtimeChart: realtimeLineChart, historyChart: heartRateHistoryChart)
        heartFrequencyManager!.updateHistoryData(with: measurements)
        
        currentManager = bloodPressureManager
        currentManager?.afterModeChanged()
        
        if measurementRecorder?.isRecording() ?? false {
            startMeasuringData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        updateActionButtons()
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateActionButtons() {
        let isRecording = measurementRecorder?.isRecording() ?? false
        measureButton!.hidden = isRecording
        measureButton!.enabled = !isRecording
        cancelButton!.hidden = !isRecording
        cancelButton!.enabled = isRecording
        doneButton!.hidden = !isRecording
        doneButton!.enabled = isRecording
        indicatorView!.hidden = !isRecording
    }
    
    func simulateRealtime() {
        for count in 0...30 {
            let delaySeconds = 600.0 * Double(count)
            let waitTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySeconds * Double(NSEC_PER_MSEC)))
            
            dispatch_after(waitTime, GlobalDispatchUtils.MainQueue) {
                let measurement = Measurement.createRandom()
                self.currentManager?.updateRealtimeData(with: measurement)
                
                self.measurementRecorder?.updateMeasurement(with: BloodPressureResult(measurement: measurement))
                self.measurementRecorder?.updateMeasurement(with: HeartRateResult(measurement: measurement))
            }
        }
    }
    
    func startMeasuringData() {
        currentManager?.startMeasurement()
        simulateRealtime()
    }
    
    @IBAction func startMeasurement(sender: UIButton) {
        measurementRecorder?.start(from: self)
        updateActionButtons()
        startMeasuringData()
    }
    
    @IBAction func cancelMeasurement(sender: UIButton) {
        measurementRecorder?.cancel()
        updateActionButtons()
    }
    
    @IBAction func finishMeasurement(sender: UIButton) {
        measurementRecorder?.finish()
        updateActionButtons()
    }
    
    @IBAction func changeMeasurementMode(sender: UISegmentedControl) {
        currentManager?.beforeModeChanged()
        switch sender.selectedSegmentIndex {
        case 1:
            currentManager = heartFrequencyManager
            measurementRecorder?.measureHeartRate()
        case 0:
            currentManager = bloodPressureManager
            measurementRecorder?.measureBloodPressure()
        default:
            currentManager = bloodPressureManager
            measurementRecorder?.measureBloodPressure()
        }
        currentManager?.afterModeChanged()
    }
    
}

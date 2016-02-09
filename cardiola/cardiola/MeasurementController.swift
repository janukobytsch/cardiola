//
//  MeasurementController.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import UIKit
import Charts

class MeasurementController: UIViewController, RecorderUpdateListener {
    
    let indicatorTextRecording = "Messung läuft"
    let indicatorTextMissing = "Vitalparameter fehlt"
    let indicatorTextDone = "Vitalparameter erfasst"
    
    let measureStartText = "Messen"
    let measureFinishText = "Messung abschließen"
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var historyBarChart: BarChartView!
    @IBOutlet weak var realtimeBarChart: BarChartView!
    @IBOutlet weak var realtimeLineChart: LineChartView!
    @IBOutlet weak var heartRateHistoryChart: CombinedChartView!
    @IBOutlet weak var indicatorView: UIStackView!
    @IBOutlet weak var measureButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var indicatorLabel: UILabel!
    
    override var preferredFocusedView: UIView? {
        get {
            return self.segmentedControl
        }
    }
    
    var bloodPressureManager: BloodPressureMeasurementManager?
    var heartFrequencyManager: HeartFrequencyMeasurementManager?
    var currentManager: MeasurementManager?
    
    // MARK: Injected
    
    var measurementRecorder: MeasurementRecorder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        measurementRecorder?.addUpdateListener(self)
        
        bloodPressureManager = BloodPressureMeasurementManager(realtimeChart: realtimeBarChart,
            historyChart: historyBarChart, recorder: measurementRecorder!)
        heartFrequencyManager = HeartFrequencyMeasurementManager(realtimeChart: realtimeLineChart,
            historyChart: heartRateHistoryChart, recorder: measurementRecorder!)
        
        currentManager = bloodPressureManager
        currentManager?.afterModeChanged()
    }
    
    override func viewWillAppear(animated: Bool) {
        updateViews()
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        measurementRecorder?.removeUpdateListener(self)
    }
    
    // MARK: UI update
    
    private func updateViews() {
        updateActionButtons()
        currentManager!.updateHistoryData()
    }
    
    private func updateActionButtons() {
        let isActive = measurementRecorder?.isActive() ?? false
        let isRecording = measurementRecorder?.isRecording() ?? false
        let hasComponent = currentManager?.hasComponent() ?? false
        
        // textual indicator
        indicatorLabel.text = (isRecording) ? indicatorTextRecording : (hasComponent) ? indicatorTextDone : indicatorTextMissing
        indicatorView!.hidden = !(isRecording || isActive)
        
        // measure button
        let measureTitle = (!hasComponent) ? measureStartText : measureFinishText
        measureButton.setTitle(measureTitle, forState: .Normal)
        measureButton!.hidden = isRecording
        measureButton!.enabled = !isRecording
        
        // component buttons
        cancelButton!.hidden = !isRecording
        cancelButton!.enabled = isRecording
        doneButton!.hidden = !isRecording
        doneButton!.enabled = isRecording
    }
    
    // MARK: RecorderUpdateListener
    
    func update() {
        updateViews()
        
        // managers do not need to register explicitely as listeners to the recorder
        if let manager = currentManager as? RecorderUpdateListener {
            manager.update()
        }
    }
    
    // MARK: Measurement states
    
    @IBAction func startOrFinishMeasurement(sender: UIButton) {
        if currentManager!.hasComponent() {
            // component already recorded
            measurementRecorder?.finishMeasurement()
        } else {
            currentManager?.startMeasurement()
        }
        updateViews()
    }
    
    @IBAction func finishComponent(sender: UIButton) {
        measurementRecorder?.finishComponent()
        updateViews()
    }
    
    @IBAction func cancelComponent(sender: UIButton) {
        measurementRecorder?.cancelComponent()
        updateViews()
    }
    
    @IBAction func changeMeasurementMode(sender: UISegmentedControl) {
        currentManager?.beforeModeChanged()
        switch sender.selectedSegmentIndex {
        case 1:
            currentManager = heartFrequencyManager
            heartFrequencyManager?.startMeasurement()
        case 0:
            currentManager = bloodPressureManager
            bloodPressureManager?.startMeasurement()
        default:
            currentManager = bloodPressureManager
            bloodPressureManager?.startMeasurement()
        }
        currentManager?.afterModeChanged()
        updateViews()
    }
    
}

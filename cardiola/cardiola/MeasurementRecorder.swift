//
//  MeasurementRecorder.swift
//  
//
//  Created by Janusch Jacoby on 01/02/16.
//
//

import UIKit

// MARK: MeasurementComponentDelegate

protocol MeasurementComponentDelegate {
    func startComponent()
    func cancelComponent()
    func finishComponent()
}

// MARK: MeasurementRecorderState

protocol MeasurementRecorderState {
    var measurement: Measurement { get }
    
    init(measurement: Measurement)
    func onNewResult(result: MeasurementResult)
}

// MARK: RecorderUpdateListener

protocol RecorderUpdateListener {
    func update()
}

// the recorder serves as an additional layer to the data providers

class MeasurementRecorder: Recorder, ResultProviderListener, MeasurementComponentDelegate {
    
    // MARK: Recorder states
    
    private class BaseRecorderState: MeasurementRecorderState {
        var measurement: Measurement
        
        required init(measurement: Measurement) {
            self.measurement = measurement
        }
        
        func onNewResult(result: MeasurementResult) {
            // subclass responsibility
        }
    }
    
    private class BloodPressureRecorderState: BaseRecorderState {
        override func onNewResult(result: MeasurementResult) {
            guard let result = result as? BloodPressureResult else {
                return
            }
            measurement.systolicPressure = result.systolicPressure
            measurement.diastolicPressure = result.diastolicPressure
        }
    }
    
    private class HeartRateRecorderState: BaseRecorderState {
        override func onNewResult(result: MeasurementResult) {
            guard let result = result as? HeartRateResult else {
                return
            }
            measurement.heartRate = result.heartRate
        }
    }
    
    // MARK: Properties
    
    private var measurementRepository: MeasurementRepository
    private var planRepository: PlanRepository
    // need to assign default state due to to associated type limitations
    private var _state: MeasurementRecorderState?
    
    // whether a measurement entry is active
    private var _isActive = false
    
    // whether the recorder is listening to a result provider
    private var _isRecording = false
    
    private var _listener = [RecorderUpdateListener]()
    
    private var _currentProvider: ResultProvider?
    
    // the currently active entry
    var currentEntry: MeasurementPlanEntry?
    
    var currentMeasurement: Measurement? {
        get {
            return self.currentEntry?.data
        }
        set(newData) {
            self.currentEntry?.data = newData
        }
    }
    
    var hasHeartRate: Bool {
        return currentMeasurement?.hasHeartRate ?? false
    }
    
    var hasBloodPressure: Bool {
        return currentMeasurement?.hasBloodPressure ?? false
    }

    var currentPlan: MeasurementPlan {
        return self.planRepository.currentPlan
    }
    
    // MARK: Injected 
    
    var networkController: NetworkController?
    var bloodpressureProvider: BloodPressureProvider?
    var heartrateProvider: HeartRateProvider?
    
    // MARK: Initialization
    
    required init(measurementRepository: MeasurementRepository, planRepository: PlanRepository) {
        self.measurementRepository = measurementRepository
        self.planRepository = planRepository
    }
    
    // MARK: Observer
    
    func addUpdateListener(listener: RecorderUpdateListener) {
        self._listener.append(listener)
    }
    
    func removeUpdateListener(listener: RecorderUpdateListener) {
        // TODO
    }
    
    private func notifyListeners() {
        for listener in _listener {
            listener.update()
        }
    }
    
    // MARK: State transitions
    
    func measureBloodPressure() {
        activate(with: currentEntry)
        _state = BloodPressureRecorderState(measurement: currentMeasurement!)
        _currentProvider = bloodpressureProvider
        startComponent()
    }
    
    func measureHeartRate() {
        activate(with: currentEntry)
        _state = HeartRateRecorderState(measurement: currentMeasurement!)
        _currentProvider = heartrateProvider
        startComponent()
    }
    
    // MARK: ResultProviderListener
    
    func onStartProviding() {
        
    }
    
    func onNewResult(result: MeasurementResult) {
        // delegate result unwrapping to current state
        _state?.onNewResult(result)
        notifyListeners()
    }
    
    func onFinishProviding() {
        
    }
    
    // MARK: MeasurementComponentDelegate
    
    func startComponent() {
        _currentProvider!.addListener(self)
        _currentProvider!.startProviding()
    }
    
    func cancelComponent() {
        stopComponent()
    }
    
    func finishComponent() {
        stopComponent()
    }
    
    private func stopComponent() {
        _currentProvider!.removeListener(self)
        _currentProvider!.stopProviding()
    }
    
    // MARK: Recorder
    
    // creates a new measurement with a corresponding plan entry
    func startMeasurement(with planEntry: MeasurementPlanEntry?, from controller: UIViewController) {
        guard !self.isActive() else {
            self.showAlreadyRecordingAlert(controller)
            return
        }
        activate(with: planEntry)
    }
    
    func startMeasurement(from controller: UIViewController) {
        self.startMeasurement(with: nil, from: controller)
    }
    
    func cancelMeasurement() {
        guard self.isActive() else {
            return
        }
        
        // remove entry from plan
        currentPlan.removeEntry(currentEntry!)
        
        // persist models
        //currentPlan.save()
        
        _resetMeasurement()
        notifyListeners()
    }
    
    func finishMeasurement() {
        guard self.isActive() else {
            return
        }
        
        // update models
        currentEntry?.setMeasurement(currentMeasurement)
        currentEntry!.archive()
        
        // upload to server
        _uploadResultToServer()
        
        // persist models
        //currentPlan.save()
        
        _resetMeasurement()
        notifyListeners()
    }
    
    func isRecording() -> Bool {
        return _isRecording
    }
    
    func isActive() -> Bool {
        return _isActive
    }
    
    private func activate(with planEntry: MeasurementPlanEntry?) {
        guard !self.isActive() else {
            return
        }
        
        // activate existing entry or optionally create a new one
        currentEntry = planEntry ?? MeasurementPlanEntry.createVoluntaryPlanEntry(Measurement())
        currentMeasurement = planEntry?.data ?? Measurement()
        currentEntry!.activate()
        
        // update plan container
        currentPlan.prependEntry(currentEntry!)
        
        _isActive = true
        print(String(currentMeasurement!.id))
        notifyListeners()
    }
    
    private func _uploadResultToServer() {
        self.networkController?.uploadResult(self.currentEntry?.data!)
    }
    
    private func _resetMeasurement() {
        print(String(currentMeasurement!.id))
        _isActive = false
        currentEntry = nil
    }
    
    // MARK: Alerts
    
    func showAlreadyRecordingAlert(controller: UIViewController) {
        let alertController = UIAlertController(title: "Aktive Messung",
            message: "Bitte schließe die aktuelle Messung ab, um eine neue Messung zu starten.", preferredStyle: .Alert)
        
        
        let cancelAction = UIAlertAction(title: "Messung verwerfen", style: .Destructive) {
            [weak recorder = self, weak from = controller] (action) in
            recorder?.cancelMeasurement()
            //recorder?.startMeasurement(from: from!)
        }
        alertController.addAction(cancelAction)
        
        let finishAction = UIAlertAction(title: "Messung archivieren", style: .Default) {
            [weak recorder = self, weak from = controller] (action) in
            recorder?.finishMeasurement()
            //recorder?.startMeasurement(from: from!)
        }
        alertController.addAction(finishAction)
        
        let ok = UIAlertAction(title: "Zurück", style: .Default) { (action) in }
        alertController.addAction(ok)
        
        controller.presentViewController(alertController, animated: true) { }
    }
}

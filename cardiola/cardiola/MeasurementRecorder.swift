//
//  MeasurementRecorder.swift
//  
//
//  Created by Janusch Jacoby on 01/02/16.
//
//

import UIKit


protocol MeasurementRecorderState: class {
    // enfore type constraints at runtime due to limitations with associated types
    func update(measurement: Measurement, with result: MeasurementResult)
}


protocol RecorderUpdateListener: class {
    func update()
}

class MeasurementRecorder: Recorder {
    
    // MARK: States
    
    private class BloodPressureRecorderState: MeasurementRecorderState {
        func update(measurement: Measurement, with result: MeasurementResult) {
            guard let result = result as? BloodPressureResult else {
                return
            }
            measurement.systolicPressure = result.systolicPressure
            measurement.diastolicPressure = result.diastolicPressure
        }
    }
    
    private class HeartRateRecorderState: MeasurementRecorderState {
        func update(measurement: Measurement, with result: MeasurementResult) {
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
    private var state: MeasurementRecorderState
    private var _isRecording = false
    private var _listener = [RecorderUpdateListener]()
    
    var currentEntry: MeasurementPlanEntry?
    
    var currentMeasurement: Measurement? {
        get {
            return self.currentEntry?.data
        }
        set(newData) {
            self.currentEntry?.data = newData
        }
    }
    
    var currentPlan: MeasurementPlan {
        return self.planRepository.currentPlan
    }
    
    // MARK: Initialization
    
    required init(measurementRepository: MeasurementRepository, planRepository: PlanRepository, state: MeasurementRecorderState) {
        self.measurementRepository = measurementRepository
        self.planRepository = planRepository
        self.state = state
    }
    
    convenience init(measurementRepository: MeasurementRepository, planRepository: PlanRepository) {
        let defaultState = BloodPressureRecorderState()
        self.init(measurementRepository: measurementRepository, planRepository: planRepository, state: defaultState)
    }
    
    func updateMeasurement(with result: MeasurementResult) {
        guard let measurement = currentMeasurement else {
            return
        }
        state.update(measurement, with: result)
    }
    
    // MARK: Observer
    
    func addUpdateListener(listener: RecorderUpdateListener) {
        self._listener.append(listener)
    }
    
    private func notifyListeners() {
        for listener in _listener {
            listener.update()
        }
    }
    
    // MARK: State transitions
    
    func measureBloodPressure() {
        self.state = BloodPressureRecorderState()
    }
    
    func measureHeartRate() {
        self.state = HeartRateRecorderState()
    }
    
    // MARK: Recorder
    
    // creates a new measurement with a corresponding plan entry
    func start(with planEntry: MeasurementPlanEntry?, from controller: UIViewController) {
        guard !self.isRecording() else {
            self.showAlreadyRecordingAlert(controller)
            return
        }
        
        // activate existing entry or optionally create a new one
        currentEntry = planEntry ?? MeasurementPlanEntry.createVoluntaryPlanEntry(Measurement())
        currentMeasurement = planEntry?.data ?? Measurement()
        currentEntry!.activate()
        
        // update plan container
        currentPlan.prependEntry(currentEntry!)
        
        _isRecording = true
        print(String(currentMeasurement!.id))
        notifyListeners()
    }
    
    func start(from controller: UIViewController) {
        self.start(with: nil, from: controller)
    }
    
    func stop() {
        // not supported
    }
    
    // archives the current plan
    func finish() {
        guard self.isRecording() else {
            return
        }
        
        // update models
        currentEntry?.setMeasurement(currentMeasurement)
        currentEntry!.archive()
        
        // persist models
        //currentPlan.save()
        
        reset()
        notifyListeners()
        
        // TODO: fetch classification results from server
    }
    
    // discards the current plan
    func cancel() {
        guard self.isRecording() else {
            return
        }
        
        // remove entry from plan
        currentPlan.removeEntry(currentEntry!)
        
        // persist models
        //currentPlan.save()
        
        reset()
        notifyListeners()
    }
    
    func isRecording() -> Bool {
        return _isRecording
    }
    
    func reset() {
        print(String(currentMeasurement!.id))
        _isRecording = false
        currentEntry = nil
    }
    
    // MARK: Alerts
    
    func showAlreadyRecordingAlert(controller: UIViewController) {
        let alertController = UIAlertController(title: "Laufende Messung",
            message: "Bitte beende die aktuelle Messung, um eine neue Messung zu starten.", preferredStyle: .Alert)
        
        
        let cancelAction = UIAlertAction(title: "Messung verwerfen", style: .Destructive) {
            [weak recorder = self, weak from = controller] (action) in
            recorder?.cancel()
            //recorder?.start(from: from!)
        }
        alertController.addAction(cancelAction)
        
        let finishAction = UIAlertAction(title: "Messung archivieren", style: .Default) {
            [weak recorder = self, weak from = controller] (action) in
            recorder?.finish()
            //recorder?.start(from: from!)
        }
        alertController.addAction(finishAction)
        
        let ok = UIAlertAction(title: "Zurück", style: .Default) { (action) in }
        alertController.addAction(ok)
        
        controller.presentViewController(alertController, animated: true) { }
    }
}

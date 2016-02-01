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
    
    private var repository: MeasurementRepository
    // need to assign default state due to to associated type limitations
    private var state: MeasurementRecorderState
    private var _isRecording = false
    var currentMeasurement: Measurement?
    
    // MARK: Initialization

    required init(repository: MeasurementRepository, state: MeasurementRecorderState) {
        self.repository = repository
        self.state = state
    }
    
    convenience init(repository: MeasurementRepository) {
        let defaultState = BloodPressureRecorderState()
        self.init(repository: repository, state: defaultState)
    }
    
    func updateMeasurement(with result: MeasurementResult) {
        guard let measurement = currentMeasurement else {
            return
        }
        state.update(measurement, with: result)
    }
    
    // MARK: State transitions
    
    func measureBloodPressure() {
        self.state = BloodPressureRecorderState()
    }
    
    func measureHeartRate() {
        self.state = HeartRateRecorderState()
    }
    
    // MARK: Recorder
    
    func start(with measurement: Measurement, from controller: UIViewController) {
        guard !self.isRecording() else {
            self.showAlreadyRecordingAlert(controller)
            return
        }
        _isRecording = true
        currentMeasurement = measurement
        print(String(currentMeasurement!.id))
    }
    
    func start(from controller: UIViewController) {
        let newMeasurement = Measurement()
        self.start(with: newMeasurement, from: controller)
    }
    
    func stop() {
        // not supported
    }
    
    func finish() {
        guard self.isRecording() else {
            return
        }
        print(String(currentMeasurement!.id))
        _isRecording = false
        currentMeasurement!.date = NSDate()
        // TODO: store to database and upload to server
    }
    
    func cancel() {
        guard self.isRecording() else {
            return
        }
        print(String(currentMeasurement!.id))
        _isRecording = false
        currentMeasurement = nil
    }
    
    func isRecording() -> Bool {
        return _isRecording
    }
    
    // MARK: Alerts
    
    func showAlreadyRecordingAlert(controller: UIViewController) {
        let alertController = UIAlertController(title: "titel", message: "message", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Zurück", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)

        let ok = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(ok)
        
        
        controller.presentViewController(alertController, animated: true) { }
    }
}

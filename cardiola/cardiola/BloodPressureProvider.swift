//
//  BloodPressureProvider.swift
//  cardiola
//
//  Created by Jakob Frick on 02/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

class BloodPressureProvider: ResultProvider {
    
    // MARK: Properties
    
    internal var _listeners = [ResultProviderListener]()
    internal var _isProviding = true
    private var _latestResult: BloodPressureResult? = nil
    var bluetoothController: BluetoothController
    
    // MARK: Init
    
    init(_ bluetoothController: BluetoothController) {
        self.bluetoothController = bluetoothController
        bluetoothController.bloodPressureProvider = self
    }
    
    // MARK: ResultProvider
    
    func startProviding() {
        _isProviding = true
    }
    
    func stopProviding() {
        _isProviding = false
    }
    
    func latestResult() -> MeasurementResult? {
        return _latestResult
    }
    
    // MARK: Observer
    
    func addListener(listener: ResultProviderListener) {
        _listeners.append(listener)
    }
    
    func removeListener(listener: ResultProviderListener) {
        // TODO
    }
    
    
    func notifyListeners(result: BloodPressureResult) {
        for listener in self._listeners {
            listener.onNewResult(result)
        }
    }
    
    // MARK: Data handling
    
    func updateWith(newResult: BloodPressureResult) {
        _latestResult = newResult
        
        if _isProviding {
            notifyListeners(newResult)
        }
    }
    
}

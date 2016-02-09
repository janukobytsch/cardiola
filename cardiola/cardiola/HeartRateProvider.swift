//
//  HeartRateProvider.swift
//  cardiola
//
//  Created by Janusch Jacoby on 07/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

class HeartRateProvider: ResultProvider {
    
    // MARK: Properties
    
    internal var _listeners = [ResultProviderListener]()
    internal var _isProviding = true
    private var _latestResult: HeartRateResult? = nil
    var bluetoothController: BluetoothController
    
    // MARK: Init
    
    init(_ bluetoothController: BluetoothController) {
        self.bluetoothController = bluetoothController
        self.bluetoothController.heartRateProvider = self
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
    
    
    func notifyListeners(result: HeartRateResult) {
        for listener in self._listeners {
            listener.onNewResult(result)
        }
    }
    
    // MARK: Data handling
    
    func updateWith(newResult: HeartRateResult) {
        _latestResult = newResult
        
        if _isProviding {
            notifyListeners(newResult)
        }
    }
    
}
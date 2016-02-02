//
//  BloodPressureProvider.swift
//  cardiola
//
//  Created by Jakob Frick on 02/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

class BloodPressureProvider: ResultProvider {
    
    // MARK: Properties
    
    private var _listener = [UpdateListener]()
    private var _latestResult: BloodPressureResult? = nil
    
    // MARK: Observer
    
    func addUpdateListener(listener: UpdateListener) {
        self._listener.append(listener)
    }
    
    private func notifyListeners() {
        for listener in _listener {
            listener.update()
        }
    }
    
    // MARK: Data handling
    
    private func _saveNewResult(newResult: BloodPressureResult) {
        _latestResult = newResult
        notifyListeners()
    }
    
    func latestResult() -> MeasurementResult? {
        return _latestResult
    }
    
}

//
//  MockedHeartRateProvider.swift
//  cardiola
//
//  Created by Janusch Jacoby on 07/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation

class MockedHeartRateProvider: HeartRateProvider {
    
    // MARK: Properties
    
    private var _listeners = [ResultProviderListener]()
    private var _latestResult: HeartRateResult?
    
    override func startProviding() {
        let numTicks = 10
        for count in 0...numTicks {
            let delaySeconds = 600.0 * Double(count)
            let waitTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delaySeconds * Double(NSEC_PER_MSEC)))
            
            dispatch_after(waitTime, GlobalDispatchUtils.MainQueue) {
                let measurement = Measurement.createRandom()
                let result = HeartRateResult(measurement: measurement)
                self.notifyListeners(result)
                
                if (count == numTicks) {
                    for listener in self._listeners {
                        listener.onFinishProviding()
                    }
                }
            }
        }
    }
    
    override func stopProviding() {
        // todo
    }
    
   override  func latestResult() -> MeasurementResult? {
        // todo
        return nil
    }
    
    override func addListener(listener: ResultProviderListener) {
        self._listeners.append(listener)
    }
    
    override func removeListener(listener: ResultProviderListener) {
        // todo
    }
    
    func notifyListeners(result: HeartRateResult) {
        for listener in self._listeners {
            listener.onNewResult(result)
        }
    }
}
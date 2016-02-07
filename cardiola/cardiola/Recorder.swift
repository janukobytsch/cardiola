//
//  Recorder.swift
//  
//
//  Created by Janusch Jacoby on 01/02/16.
//
//

import UIKit

protocol Recorder: class {
    
    func startMeasurement(from controller: UIViewController)
    func cancelMeasurement()
    func finishMeasurement()
    
    // whether a measurement is attached
    func isActive() -> Bool
    
    // whether a component is being recorded
    func isRecording() -> Bool
}
//
//  Recorder.swift
//  
//
//  Created by Janusch Jacoby on 01/02/16.
//
//

import UIKit

protocol Recorder: class {
    
    func start(from controller: UIViewController)
    func cancel()
    func finish()
    func stop()
    
    func isRecording() -> Bool
}
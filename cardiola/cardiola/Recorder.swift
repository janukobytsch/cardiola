//
//  Recorder.swift
//  
//
//  Created by Janusch Jacoby on 01/02/16.
//
//

import Foundation


protocol Recorder: class {
    
    func start()
    func cancel()
    func finish()
    func stop()
    
    func isRecording() -> Bool
}
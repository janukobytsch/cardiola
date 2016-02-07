//
//  DataProvider.swift
//  cardiola
//
//  Created by Jakob Frick on 02/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

protocol ResultProviderListener: class {
    
    // MARK: ResultProviderListener
    
    func onStartProviding()
    func onNewResult(result: MeasurementResult)
    func onFinishProviding()
}

protocol ResultProvider: class {
    
    // MARK: ResultProvider
    
    func startProviding()
    func stopProviding()
    func latestResult() -> MeasurementResult?
    
    // MARK: Observer
    
    func addListener(listener: ResultProviderListener)
    func removeListener(listener: ResultProviderListener)
}
//
//  DataProvider.swift
//  cardiola
//
//  Created by Jakob Frick on 02/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

protocol ResultProvider: class, UpdateProvider {
    
    func latestResult() -> MeasurementResult?
}
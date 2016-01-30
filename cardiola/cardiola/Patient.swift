//
//  Patient.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation

class Patient: NSObject {
    
    var id: Int?
    var name: String?
    var plans: [MeasurementPlan]?
    var hasChestPain: Bool?
    var hasAngina: Bool?
    var bloodSugar: Int?
    var ecg: Int?
    
    init(name: String) {
        super.init()
        self.name = name
        self.hasChestPain = false
        self.hasAngina = false
    }
    
    static func createDemoPatient() -> Patient {
        return Patient(name: "Pep")
    }
}
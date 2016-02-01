//
//  Patient.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation
import RealmSwift

class Patient: Object, PersistentModel {
    dynamic var id: String = NSUUID().UUIDString
    override static func primaryKey() -> String? {
        return "id"
    }
    
    dynamic var name: String?
    let plans = List<MeasurementPlan>()
    dynamic var hasChestPain: Bool
    dynamic var hasAngina: Bool
    let bloodSugar = RealmOptional<Int>()
    let ecg = RealmOptional<Int>()
    
    init(name: String) {
        self.hasChestPain = false
        self.hasAngina = false
        
        super.init()
        self.name = name
    }
    
    required init() {
        self.hasChestPain = false
        self.hasAngina = false
        
        super.init()
    }
    
    static func createDemoPatient() -> Patient {
        return Patient(name: "Pep")
    }
}
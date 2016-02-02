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
    
    dynamic var hasChestPain: Bool = false
    dynamic var hasAngina: Bool = false
    dynamic var name: String?
    dynamic var serverId: String?
    
    let plans = List<MeasurementPlan>()
    let bloodSugar = RealmOptional<Int>()
    let ecg = RealmOptional<Int>()
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
    
    static func createDemoPatient() -> Patient {
        let demoPatient = Patient(name: "Pep")
        demoPatient.serverId = "1"
        return demoPatient
    }
}
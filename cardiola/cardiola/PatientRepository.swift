//
//  UserRepository.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation

class PatientRepository {
    
    func getCurrentPatient() -> Patient? {
        return Patient.createDemoPatient()
    }
}
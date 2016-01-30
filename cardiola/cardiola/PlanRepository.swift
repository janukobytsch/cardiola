//
//  PlanRepository.swift
//  cardiola
//
//  Created by Janusch Jacoby on 30/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Foundation


class PlanRepository {
    
    func getPlan(from patient: Patient) -> MeasurementPlan? {
        return MeasurementPlan.createRandomWeek()
    }
}
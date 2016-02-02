//
//  SwinjectStoryboard+Setup.swift
//  cardiola
//
//  Created by Janusch Jacoby on 01/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import Swinject


extension SwinjectStoryboard {
    
    // implicitely inject global dependencies
    class func setup() {
        defaultContainer.registerForStoryboard(MeasurementController.self) { r, c in
            c.measurementRecorder = r.resolve(MeasurementRecorder.self)
        }
        //defaultContainer.registerForStoryboard(MeasurementController.self) { r, c in
        //    c.bloodPressureProvider = r.resolve(BloodPressureProvider.self)
        //}
        
        defaultContainer.registerForStoryboard(DashboardController.self) { r, c in
            c.planRepository = r.resolve(PlanRepository.self)
            c.patientRepository = r.resolve(PatientRepository.self)
            c.measurementRecorder = r.resolve(MeasurementRecorder.self)
        }
        
        defaultContainer.register(MeasurementRecorder.self) { r in
            MeasurementRecorder(measurementRepository: r.resolve(MeasurementRepository.self)!,
                planRepository: r.resolve(PlanRepository.self)!)
            }.inObjectScope(ObjectScope.Container)
        
        defaultContainer.register(BloodPressureProvider.self) { _ in BloodPressureProvider() }
        defaultContainer.register(MeasurementRepository.self) { _ in MeasurementRepository() }
        defaultContainer.register(PatientRepository.self) { _ in PatientRepository() }
        defaultContainer.register(PlanRepository.self) { _ in PlanRepository() }
    }
    
}
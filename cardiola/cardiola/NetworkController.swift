//
//  NetworkController.swift
//  cardiola
//
//  Created by Jakob Frick on 02/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import UIKit
import Alamofire

class NetworkController {
    
    // MARK: Class Properties
    static let serverAddress = "172.16.18.134"
    static let serverPort = "5000"
    
    static var serverUrl: String {
        return "https://" + NetworkController.serverAddress + ":" + NetworkController.serverPort
    }
    
    var apiUrl: String {
        return NetworkController.serverUrl + "/api" //user/" + (self.patientRepository?.getCurrentPatient()?.serverId)!
    }

    private static let defaultManager: Alamofire.Manager = {
        // Ignore SSL Certificate
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            NetworkController.serverAddress: .DisableEvaluation
        ]
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        
        return Alamofire.Manager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
    
    // MARK: Injected
    var patientRepository: PatientRepository?
    
    // MARK: Init
    init(patientRepository: PatientRepository) {
        self.patientRepository = patientRepository
    }
    
    // MARK: Server interaction
    
    func uploadResult(data: Measurement?, var sender: UIViewController? = nil) {
        guard let measurement = data else {
            return
        }
        
        if sender == nil {
            sender = getActiveViewController()
        }
        
        print("uploading", data, sender)
        
        // let expectation = expectationWithDescription("request should succeed")
        
        let postPressureURL = self.apiUrl + "/measurements/pressure"
        let dateFormater = NSDateFormatter()
        
        let params: [String: AnyObject] = ["systolic": (measurement.systolicPressure == nil ? random(min: 120, max: 220) : measurement.systolicPressure!),
            "diastolic": (measurement.diastolicPressure == nil ? random(min: 70, max: 140) : measurement.diastolicPressure!),
            "pulse": (measurement.heartRate == nil ? random(min: 60, max: 180) : measurement.heartRate!),
            "user_id": (self.patientRepository?.getCurrentPatient()?.serverId)!,
            "time": dateFormater.stringFromDate(NSDate()),
            "rate": 60]
        
        let predictionURL = self.apiUrl + "/prediction/" + (self.patientRepository?.getCurrentPatient()?.serverId)!
        
        NetworkController.defaultManager.request(.POST, postPressureURL, parameters: params, encoding: .JSON)
            .responseString { response in
        }
        
        NetworkController.defaultManager.request(.GET, predictionURL)
            .responseString { response in
                
                if let result = response.result.value {
                    
                    let result = result.stringByTrimmingCharactersInSet(
                        NSCharacterSet.whitespaceAndNewlineCharacterSet()
                    )
                    
                    switch Int(Float(result)!) {
                    case 0:
                        showAlertMessage(sender!, title: "Gesundheitszustand", message: "Sie sind (vielleicht) gesund")
                        break
                    case 1:
                        showAlertMessage(sender!, title: "Gesundheitzustand", message: "Sie sind (vielleicht) krank")
                        break
                    default:
                        showAlertMessage(sender!, title: "Gesundheitszustand", message: "Sie sind (vielleicht) gesund")
                        break
                    }
                }
        }
        
        // waitForExpectationsWithTimeout(defaultTimeout, handler: nil)
        
        
        
    }
}
//
//  ExtensionTests.swift
//  cardiola
//
//  Created by Janusch Jacoby on 31/01/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import XCTest
@testable import cardiola

class ExtensionTests: XCTestCase {
    
    var strings: [String]?
    var measurements: [Measurement]?
    
    override func setUp() {
        self.strings = ["Lorem", "Ipsum", "Dolor", "Sit", "Amet", "Lorem"]
        self.measurements = [Measurement(heartRate: 70), Measurement(heartRate: 100), Measurement(heartRate: 70)]
    }

    func testBinningForPrimitives() {
        // When
        let binning = strings!.collectSimilar(<) {(s1: String, s2: String) -> Bool in
            return s1 == s2
        }
        // Then
        XCTAssertTrue(binning.count == 5)
    }
    
    func testBinningForComplexObjects() {
        // When
        let binning = measurements!.collectSimilar({ $0.heartRate < $1.heartRate }) {
            $0.heartRate == $1.heartRate
        }
        // Then
        XCTAssertTrue(binning.count == 2)
    }

    func testBinEqualsForPrimitives() {
        // When
        let binning = strings!.collectEquals() { (s: String) -> String in s }
        // Then
        XCTAssertTrue(binning.count == 5)
    }
    
    func testBinEqualsForComplexObjects() {
        // When
        let binning = measurements!.collectEquals() { (m: Measurement) -> Int in m.heartRate! }
        // Then
        XCTAssertTrue(binning.count == 2)
    }
}

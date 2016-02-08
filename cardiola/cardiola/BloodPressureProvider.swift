//
//  BloodPressureProvider.swift
//  cardiola
//
//  Created by Jakob Frick on 02/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import CoreBluetooth

class BloodPressureProvider: NSObject, ResultProvider, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: Class variables
    static let bloodPressureUUID = "2A35"
    
    // MARK: Properties
    
    internal var _listeners = [ResultProviderListener]()
    internal var _isProviding = false
    private var _latestResult: BloodPressureResult? = nil
    private var _manager: CBCentralManager!
    private var _lsBPM: CBPeripheral!
    
    required override init() {
        super.init()
        _manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: ResultProvider
    
    func startProviding() {
        _isProviding = true
    }
    
    func stopProviding() {
        _isProviding = false
    }
    
    func latestResult() -> MeasurementResult? {
        return _latestResult
    }
    
    // MARK: Observer
    
    func addListener(listener: ResultProviderListener) {
        _listeners.append(listener)
    }
    
    func removeListener(listener: ResultProviderListener) {
        // TODO
    }
    
    
    func notifyListeners(result: BloodPressureResult) {
        for listener in self._listeners {
            listener.onNewResult(result)
        }
    }
    
    // MARK: CentralManagerDelegate
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        _lsBPM = peripheral
        _lsBPM.delegate = self
        _manager.stopScan()
        _manager.connectPeripheral(_lsBPM, options: nil)
    }
    
    // MARK: PeripheralDelegate
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let servicePeripherals = peripheral.services as [CBService]!
        {
            for service in servicePeripherals
            {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        if let characterArray = service.characteristics as [CBCharacteristic]!
        {
            for characteristic in characterArray
            {
                // Name: Blood Pressure Measurement - Assigned Number: 0x2A35
                if(characteristic.UUID.UUIDString == BloodPressureProvider.bloodPressureUUID) {
                    peripheral.readValueForCharacteristic(characteristic)
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                }
            }
            
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        guard characteristic.value != nil else {
            return
        }
        
        if(characteristic.UUID.UUIDString == BloodPressureProvider.bloodPressureUUID) {
            // Since lsBPM does use Ints instead of SFloat we just can use UInt16 and have no need for converting
            var systolic: UInt16 = 0
            var diastolic: UInt16 = 0
            var pulse: UInt16 = 0
            var flags: Int8 = 0
            
            characteristic.value?.getBytes(&flags, range: NSRange(location: 0, length: 1))
            characteristic.value?.getBytes(&systolic, range: NSRange(location: 1, length: 2))
            characteristic.value?.getBytes(&diastolic, range: NSRange(location: 3, length: 2))
            characteristic.value?.getBytes(&pulse, range: NSRange(location: 5, length: 2))
            
            _saveNewResult(BloodPressureResult(systolicPressure: Int(systolic), diastolicPressure: Int(diastolic)))
        }
        
    }
    
    // MARK: HandleingStateChange
    
    @objc func centralManagerDidUpdateState(central: CBCentralManager) {
        var status = ""
        
        switch (central.state) {
        case .PoweredOff:
            status = "Bluetooth turned of"
        case .PoweredOn:
            status = "Bluetooth turned on"
            _manager.scanForPeripheralsWithServices(nil, options: nil)
        case .Unsupported:
            status = "Bluetooth not available"
        default: break
        }
        
        print("STAT: \(status)")
    }
    
    // MARK: Data handling
    
    private func _saveNewResult(newResult: BloodPressureResult) {
        _latestResult = newResult
        
        if _isProviding {
            notifyListeners(newResult)
        }
    }
    
}

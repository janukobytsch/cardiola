//
//  HeartRateProvider.swift
//  cardiola
//
//  Created by Janusch Jacoby on 07/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import CoreBluetooth

class HeartRateProvider: NSObject, ResultProvider, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: Class variables
    
    private static let heartRateUUID = "2A37"
    
    // MARK: Properties
    
    internal var _listeners = [ResultProviderListener]()
    internal var _isProviding = false
    private var _latestResult: HeartRateResult? = nil
    private var _manager: CBCentralManager!
    private var _polarH7: CBPeripheral!
    
    override required init() {
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
    
    
    func notifyListeners(result: HeartRateResult) {
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
        
        _polarH7 = peripheral
        _polarH7.delegate = self
        _manager.stopScan()
        _manager.connectPeripheral(_polarH7, options: nil)
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
                // Name: Heart Rate Measurement - Assigned Number: 0x2A37
                if(characteristic.UUID.UUIDString == HeartRateProvider.heartRateUUID) {
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
        
        if(characteristic.UUID.UUIDString == HeartRateProvider.heartRateUUID) {
            var flags: Int8 = 0
            characteristic.value?.getBytes(&flags, range: NSRange(location: 0, length: 1))
            
            var heartRate: Int
            if(flags % 2 == 1) {
                var bufferRate: UInt16 = 0
                characteristic.value?.getBytes(&bufferRate, range: NSRange(location: 1, length: 2))
                heartRate = Int(bufferRate)
            } else {
                var bufferRate: UInt8 = 0
                characteristic.value?.getBytes(&bufferRate, range: NSRange(location: 1, length: 1))
                heartRate = Int(bufferRate)
            }
            
            _saveNewResult(HeartRateResult(heartRate: heartRate))
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
    
    private func _saveNewResult(newResult: HeartRateResult) {
        _latestResult = newResult
        
        if _isProviding {
            notifyListeners(newResult)
        }
    }
    
}
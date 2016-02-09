//
//  BluetoothController.swift
//  cardiola
//
//  Created by Jakob Frick on 09/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import CoreBluetooth

class BluetoothController: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate  {
    // MARK: Class variables
    
    private static let heartRateUUID = "2A37"
    private static let bloodPressureUUID = "2A35"
    
    // MARK: Properties
    
    private var _manager: CBCentralManager!
    private var _polarH7: CBPeripheral?
    private var _lsBPM: CBPeripheral?
    var bloodPressureProvider: BloodPressureProvider?
    var heartRateProvider: HeartRateProvider?
    
    convenience init(bloodPressureProvider: BloodPressureProvider, heartRateProvider :HeartRateProvider) {
        self.init()
        self.bloodPressureProvider = bloodPressureProvider
        self.heartRateProvider = heartRateProvider
    }
    
    override required init() {
        super.init()
        _manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: CentralManagerDelegate
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("connected to ", peripheral.name)
        
        if peripheral.name == "Polar H7 A3EB991D" && _polarH7 == nil {
            _polarH7 = peripheral
            peripheral.delegate = self
            _manager.connectPeripheral(peripheral, options: nil)
        }
        
        if peripheral.name == "LS BPM" && _lsBPM == nil {
            _lsBPM = peripheral
            peripheral.delegate = self
            _manager.connectPeripheral(peripheral, options: nil)
        }
        
        if _polarH7 != nil && _lsBPM != nil {
            _manager.stopScan()
        }
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
                
                if(characteristic.UUID.UUIDString == BluetoothController.heartRateUUID) {
                    peripheral.readValueForCharacteristic(characteristic)
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                }
                
                if(characteristic.UUID.UUIDString == BluetoothController.bloodPressureUUID) {
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
        
        if(characteristic.UUID.UUIDString == BluetoothController.heartRateUUID) {
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
            
            heartRateProvider?.updateWith(HeartRateResult(heartRate: heartRate))
        }
        
        if(characteristic.UUID.UUIDString == BluetoothController.bloodPressureUUID) {
            // Since lsBPM does use Ints instead of SFloat we just can use UInt16 and have no need for converting
            var flags: Int8 = 0
            var systolic: UInt16 = 0
            var diastolic: UInt16 = 0
            var pulse: UInt16 = 0
            
            characteristic.value?.getBytes(&flags, range: NSRange(location: 0, length: 1))
            characteristic.value?.getBytes(&systolic, range: NSRange(location: 1, length: 2))
            characteristic.value?.getBytes(&diastolic, range: NSRange(location: 3, length: 2))
            characteristic.value?.getBytes(&pulse, range: NSRange(location: 5, length: 2))
            
            bloodPressureProvider?.updateWith(BloodPressureResult(systolicPressure: Int(systolic), diastolicPressure: Int(diastolic)))
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
    
}
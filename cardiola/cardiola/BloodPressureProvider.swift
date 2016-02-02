//
//  BloodPressureProvider.swift
//  cardiola
//
//  Created by Jakob Frick on 02/02/16.
//  Copyright © 2016 BPPolze. All rights reserved.
//

import CoreBluetooth

class BloodPressureProvider: NSObject, ResultProvider, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    // MARK: Properties
    
    private var _listener = [UpdateListener]()
    private var _latestResult: BloodPressureResult? = nil
    private var _manager: CBCentralManager!
    private var _andBTCi: CBPeripheral!
    
    required override init() {
        super.init()
        _manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: CentralManagerDelegate
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Connected to peripheral")
        
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("discoverd", peripheral.name)
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
        
        print("discoverd service", service.UUID)
        if let characterArray = service.characteristics as [CBCharacteristic]!
        {
            for cc in characterArray
            {
                if(cc.UUID.UUIDString == "FF06") {
                    print("Schritte gefunden")
                    peripheral.readValueForCharacteristic(cc)
                }
            }
            
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        print("updated value", characteristic.UUID)
        if(characteristic.UUID.UUIDString == "FF06") {
            let value = UnsafePointer<Int>(characteristic.value!.bytes).memory
            print("Gelaufene Schritte heute: \(value)")
        }
        
    }
    
    // MARK: HandleingStateChange
    
    @objc func centralManagerDidUpdateState(central: CBCentralManager) {
        var msg = ""
        switch (central.state) {
            
        case .PoweredOff:
            msg = "Bluetooth leider ausgeschaltet"
        case .PoweredOn:
            msg = "Bluetooth ist eingeschaltet"
            _manager.scanForPeripheralsWithServices(nil, options: nil)
        case .Unsupported:
            msg = "Bluetooth nicht verfügbar"
        default: break
        }
        print("STAT: \(msg)")
    }
    
    // MARK: Observer
    
    func addUpdateListener(listener: UpdateListener) {
        self._listener.append(listener)
    }
    
    private func notifyListeners() {
        for listener in _listener {
            listener.update()
        }
    }
    
    // MARK: Data handling
    
    private func _saveNewResult(newResult: BloodPressureResult) {
        _latestResult = newResult
        notifyListeners()
    }
    
    func latestResult() -> MeasurementResult? {
        return _latestResult
    }
    
}

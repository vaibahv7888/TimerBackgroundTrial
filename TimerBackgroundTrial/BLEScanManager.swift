//
//  BLEScanManager.swift
//  TimerBackgroundTrial
//
//  Created by Swapnil Luktuke on 4/27/17.
//  Copyright © 2017 Swapnil Luktuke. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEScanManager : NSObject, CBCentralManagerDelegate {
    static let shared = BLEScanManager()
    private override init () {
        super.init()
        print("BLE Scanner state : \(getCentralManager ().state)")
    }

    let _BLEScanInterval : Int = 60
    let _BLEScanDuration : Int = 40
    let BLE_SERVICE_UUIDS : [CBUUID] = [CBUUID(string: "0000ff00-0000-1000-8000-00805f9b34fb")] // , CBUUID(string: "00001800-0000-1000-8000-00805f9b34fb")]
    let BLE_SCANNER_RESTORATION_ID = "BLE_SCANNER_RESTORATION_ID"
    var bgBLETimer : Timer?
    var _centralManager: CBCentralManager?

    func getCentralManager () -> CBCentralManager {
        if nil == _centralManager {
            _centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey : BLE_SCANNER_RESTORATION_ID,
                                                                                     CBCentralManagerOptionShowPowerAlertKey : true])
        }
        return _centralManager!
    }
    
    func restartBLEScan() {
        if #available(iOS 9.0, *) {
            if getCentralManager().isScanning {
                getCentralManager().stopScan()
            }
        } else {
            getCentralManager().stopScan()
        }
        checkAndStartBLEScan()
    }
    
    func checkAndStartBLEScan() {
        NSLog("\(#function)")
        getCentralManager().scanForPeripherals(withServices: BLE_SERVICE_UUIDS, options: nil)
        Timer.scheduledTimer(timeInterval: Double(_BLEScanDuration), target: self, selector: #selector(stopBLEScanTimerFunction), userInfo: nil, repeats: false)
    }
    
    func checkAndStopBLEScan() {
        NSLog("\(#function)")
        if #available(iOS 9.0, *) {
            if getCentralManager().isScanning {
                getCentralManager().stopScan()
            }
        } else {
            getCentralManager().stopScan()
        }
    }
    
    func checkAndStartBackgroundBLETimer() {
        NSLog("\(#function)")
        if nil == bgBLETimer || !(bgBLETimer?.isValid)! {
            Logger.println(s: "Timer started at : \(getCurrentTime())")
            bgBLETimer = Timer.scheduledTimer(timeInterval: Double(_BLEScanInterval), target: self, selector: #selector(bgBLETimerFunction), userInfo: nil, repeats: true)
            bgBLETimer?.fire()
        }
    }
    
    func stopBGBLETimer () {
        NSLog("\(#function)")
        if nil != bgBLETimer && (bgBLETimer?.isValid)! {
            bgBLETimer?.invalidate()
            bgBLETimer = nil
        }
        
    }
    
    func bgBLETimerFunction(timer : Timer) {
        NSLog("\(#function)")
        checkAndStartBLEScan()
    }
    
    func stopBLEScanTimerFunction(timer : Timer) {
        NSLog("\(#function)")
        checkAndStopBLEScan()
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){
        }
        else {
            // do something like alert the user that ble is not on
        }
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        if (central.state == .poweredOn){
            checkAndStartBLEScan()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        NSLog("\(#function)")
//        NSLog("BLE didDiscover Peripheral: \(peripheral.identifier.uuidString) | Adv : \(advertisementData)")
        Logger.println(s: "\(getCurrentTime()) | BLE Scan : \(peripheral.identifier.uuidString)")
    }
    
    
}

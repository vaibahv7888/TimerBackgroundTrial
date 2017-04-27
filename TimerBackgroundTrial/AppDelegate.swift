//
//  AppDelegate.swift
//  TimerBackgroundTrial
//
//  Created by Swapnil Luktuke on 4/13/17.
//  Copyright © 2017 Swapnil Luktuke. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let backgroundTaskName = "backgroundTaskName"
    var backgroundTaskId : UIBackgroundTaskIdentifier?
    var counter : Int = 0
    let timerIntervalSeconds : Int = 12
    var timer : Timer?
    
    var _locationManager : CLLocationManager?
    var _deferedLocUpdateAllowed = false
    
    let _BLEScanInterval : Int = 120
    let _BLEScanDuration : Int = 60
    let BLE_SERVICE_UUID = CBUUID(string: "00001800-0000-1000-8000-00805f9b34fb")
    let BLE_SCANNER_RESTORATION_ID = "BLE_SCANNER_RESTORATION_ID"
    var bgBLETimer : Timer?
    var _centralManager: CBCentralManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        #if ALLBGMODES
            Logger.setLogFileName(name :"BGAllModes")
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
            getLocationManager().startUpdatingLocation()
        #elseif BGFETCH
            Logger.setLogFileName(name :"BGFetch")
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        #elseif BGLOC
            Logger.setLogFileName(name :"BGLoc")
            getLocationManager().startUpdatingLocation()
        #elseif BGBLE
            Logger.setLogFileName(name :"BGBLE")
        #else
        #endif
        
        return true
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        if let taskId = backgroundTaskId {
            UIApplication.shared.endBackgroundTask(taskId)
            backgroundTaskId = nil
        }
        #if BGBLE || ALLBGMODES
            getCentralManager ()
            stopBGBLETimer()
        #else
        #endif
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        #if BGFETCH || BGLOC
            print("Background task not required as we will be using a standard background mode.")
        #elseif BGBLE
            checkAndStartBackgroundBLETimer()
        #else
        #endif
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        #if BGLOC
//            getLocationManager().startMonitoringSignificantLocationChanges()
        #elseif BGBLE
        #else
            if nil == backgroundTaskId {
                backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: backgroundTaskName) {
                    print("Background task completed : \(self.backgroundTaskName)")
                }
                print("bg task : \(backgroundTaskId!)")
                self.checkAndStartTimer()
            }
        #endif
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
    }
}


// MARK: Timer
private typealias AppDelegateTimer = AppDelegate
extension AppDelegateTimer {
    func checkAndStartTimer() {
        if nil == timer || !(timer?.isValid)! {
            Logger.println(s: "Timer started at : \(getCurrentTime())")
            if #available(iOS 10.0, *) {
                timer = Timer.scheduledTimer(withTimeInterval: Double(timerIntervalSeconds) as Double, repeats: true) { (timer) in
                    self.timerFunction(timer : timer)
                }
            } else {
                // Fallback on earlier versions
                timer = Timer.scheduledTimer(timeInterval: Double(timerIntervalSeconds), target: self, selector: #selector(timerFunction), userInfo: nil, repeats: true)
            }
        }
    }
    
    func timerFunction(timer : Timer) {
        self.counter += 1
        print("Count - \(self.counter) | Time - \((self.counter * self.timerIntervalSeconds/60)):\((self.counter * self.timerIntervalSeconds)%60))")
        Logger.println(s: "\(getCurrentTime()) | Count - \(self.counter) | Time - \((self.counter * self.timerIntervalSeconds/60)):\((self.counter * self.timerIntervalSeconds)%60))")
    }
    
}


// MARK: Location
private typealias AppDelegateLoc = AppDelegate
extension AppDelegateLoc : CLLocationManagerDelegate {
    func getLocationManager() -> CLLocationManager {
        if nil == _locationManager {
            _locationManager = CLLocationManager()
            _locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            _locationManager?.delegate = self
            _locationManager?.requestAlwaysAuthorization()
            _locationManager?.distanceFilter = kCLDistanceFilterNone
            _deferedLocUpdateAllowed = false
            if #available(iOS 9.0, *) {
                _locationManager!.allowsBackgroundLocationUpdates = true
            } else {
                // Fallback on earlier versions
            }
        }
        return _locationManager!
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        print("didUpdateLocations");
        Logger.println(s: "\(getCurrentTime()) | didUpdateLocations")
        
        for location in locations {
            Logger.println(s: "\t\t\t | Loc(lat:long) -  \(location.coordinate.latitude) : \(location.coordinate.latitude) |  Accuracy : \(location.horizontalAccuracy) | Timestamp : \(location.timestamp) ")
        }
        
        if !_deferedLocUpdateAllowed {
            _locationManager?.allowDeferredLocationUpdates(untilTraveled: CLLocationDistanceMax, timeout: 300)
            _deferedLocUpdateAllowed = true
        }
    }
    
    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidPauseLocationUpdates");
        Logger.println(s: "\(getCurrentTime()) | locationManagerDidPauseLocationUpdates")
    }
    
    
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        print("locationManagerDidResumeLocationUpdates");
        Logger.println(s: "\(getCurrentTime()) | locationManagerDidResumeLocationUpdates")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        if nil != error {
            print("didFinishDeferredUpdatesWithError : \(error!.localizedDescription)");
            Logger.println(s: "\(getCurrentTime()) | didFinishDeferredUpdatesWithError : \(error!.localizedDescription)")
        }
//        manager.startUpdatingLocation()
    }
}


// MARK: BackgroundFetch
private typealias AppDelegateFetch = AppDelegate
extension AppDelegateFetch {
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("In backgroud fetch")
        let urlSession = URLSession.shared
        
        let task : URLSessionDataTask = urlSession.dataTask(with: URL(string: "https://jsonplaceholder.typicode.com/posts/1")!) { (data, response, error) in
            var logData = "Background fetch"
            var fetchResult : UIBackgroundFetchResult = .noData
            if let downloadError = error {
                print("Downloaded error : \(downloadError)")
                logData = logData + " | Error : " + downloadError.localizedDescription
                fetchResult = .failed
            }
            else if let downloadedData = data {
                print("Downloaded data : \(downloadedData)")
                logData = logData + " | Data : \(downloadedData)"
                fetchResult = .newData
            }
            else {
                print("No data")
                logData = logData + " | No data"
            }
            Logger.println(s: "\(getCurrentTime()) | \(logData)")
            completionHandler(fetchResult)
        }
        task.resume()
    }
}

// MARK: BLE
private typealias AppDelegateBLE = AppDelegate
extension AppDelegateBLE: CBCentralManagerDelegate {
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
        if #available(iOS 9.0, *) {
            if !getCentralManager().isScanning {
                getCentralManager().scanForPeripherals(withServices: [BLE_SERVICE_UUID], options: nil)
                bgBLETimer = Timer.scheduledTimer(timeInterval: Double(_BLEScanDuration), target: self, selector: #selector(stopBLEScanTimerFunction), userInfo: nil, repeats: false)
            }
        }
    }

    func checkAndStopBLEScan() {
        if #available(iOS 9.0, *) {
            if getCentralManager().isScanning {
                getCentralManager().stopScan()
            }
        }
    }

    func checkAndStartBackgroundBLETimer() {
        if nil == bgBLETimer || !(bgBLETimer?.isValid)! {
            Logger.println(s: "Timer started at : \(getCurrentTime())")
            bgBLETimer = Timer.scheduledTimer(timeInterval: Double(_BLEScanInterval), target: self, selector: #selector(bgBLETimerFunction), userInfo: nil, repeats: true)
        }
    }
    
    func stopBGBLETimer () {
        if nil != bgBLETimer && (bgBLETimer?.isValid)! {
            bgBLETimer?.invalidate()
            bgBLETimer = nil
        }
        
    }
    
    func bgBLETimerFunction(timer : Timer) {
        checkAndStartBLEScan()
    }
    
    func stopBLEScanTimerFunction(timer : Timer) {
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
        print("BLE didDiscover Peripheral: \(peripheral.identifier.uuidString) | Adv : \(advertisementData)")
        Logger.println(s: "\(getCurrentTime()) | BLE Scan : \(peripheral.identifier.uuidString)")
    }
}



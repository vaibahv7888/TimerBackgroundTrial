//
//  AppDelegate.swift
//  TimerBackgroundTrial
//
//  Created by Swapnil Luktuke on 4/13/17.
//  Copyright © 2017 Swapnil Luktuke. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var _locationManager : CLLocationManager?
    var timer : Timer?

    let backgroundTaskName = "backgroundTaskName"
    var backgroundTaskId : UIBackgroundTaskIdentifier?
    var counter : Int = 0
    let timerIntervalSeconds : Int = 10
    var _logFileName = "BGTimer"
    var _logFilePath : String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        #if BGFETCH
            _logFileName = "BGFetch"
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        #elseif BGLOC
            _logFileName = "BGLoc"
            getLocationManager().startUpdatingLocation()
        #elseif BGBLE
            _logFileName = "BGBLE"
            
        #else
            
        #endif
        
        return true
    }
    
    
    // MARK: Background fetch
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        if(!timer.isValid) {
//            timer.invalidate()
//            self.counter = 0;
//            checkAndStartTimer()
//            print("In background fetch update INVALID TIMER")
//            println(s: "Starting timer from background fetch")
//        }

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
            self.println(s: "\(self.getCurrentTime()) | \(logData)")
            completionHandler(fetchResult)
        }
        task.resume()
        
    }
    
    
    func getLocationManager() -> CLLocationManager {
        if nil == _locationManager {
            _locationManager = CLLocationManager()
            _locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            _locationManager!.delegate = self
            _locationManager!.requestAlwaysAuthorization()
            
            if #available(iOS 9.0, *) {
                _locationManager!.allowsBackgroundLocationUpdates = true
            } else {
                // Fallback on earlier versions
            }
        }
        return _locationManager!
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
//        if(!timer.isValid) {
//            timer.invalidate()
//            self.counter = 0;
//            checkAndStartTimer()
//            print("In Location update INVALID TIMER")
//            println(s: "Starting timer from Location Update")
//        }
        if let currentLocation = locations.first?.coordinate {
            println(s: "\(getCurrentTime()) | Loc (lat:long) -  \(currentLocation.latitude) : \(currentLocation.latitude)")
        }
//        print("Current Location Lat = \(String(describing: currentLocation?.coordinate.latitude))")
//        print("Current Location Long = \(String(describing: currentLocation?.coordinate.longitude))")
//        print("timer isValid= \(timer.isValid)")
//        println(s: "timer isValid= \(timer.isValid)")
//        println(s:"Current Location Lat = \(String(describing: currentLocation?.coordinate.latitude))")
//        println(s:"Current Location Long = \(String(describing: currentLocation?.coordinate.longitude))")
        
    }
    
    func checkAndStartTimer() {
        if nil == timer || (timer?.isValid)! {
            println(s: "Timer started at : \(self.getCurrentTime())")
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
        self.println(s: "\(self.getCurrentTime()) | Count - \(self.counter) | Time - \((self.counter * self.timerIntervalSeconds/60)):\((self.counter * self.timerIntervalSeconds)%60))")
    }
    
    func logFilePath() -> String {
        if nil == _logFilePath {
            var filename = _logFileName
            filename = filename + ".log"
            let paths: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let documentsDirectory: NSString = paths[0] as! NSString
            let logPath: NSString = documentsDirectory.appendingPathComponent(filename) as NSString
            _logFilePath = logPath as String
        }
        return _logFilePath!
    }
    
    func println(s:String) {
        let timestamp = getCurrentTime()
        let logPath = self.logFilePath()
        var dump = "\n\nStarting new log at : \(timestamp)"

        if FileManager.default.fileExists(atPath: logPath) {
            dump =  try! String(contentsOfFile: logPath, encoding: String.Encoding.utf8)
        }
        do {
            // Write to the file
            try  "\(dump)\n\(s)".write(toFile: logPath, atomically: true, encoding: String.Encoding.utf8)
            
        } catch let error as NSError {
            print("Failed writing to log file: \(logPath), Error: " + error.localizedDescription)
        }
    }
    
    func getCurrentTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH.mm.ss"    //"HH.mm dd.MM.yyyy"
        let result = formatter.string(from: date)
        return result
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        #if BGFETCH || BGLOC || BGBLE
            print("Background task not required as we will be using a standard background mode.")
        #else
            if nil == backgroundTaskId {
                backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: backgroundTaskName) {
                    print("Background task : \(self.backgroundTaskName)")
                    self.checkAndStartTimer()
                }
            }
        #endif
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        #if BGLOC
            getLocationManager().startMonitoringSignificantLocationChanges()
        #endif
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
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")
    }

}


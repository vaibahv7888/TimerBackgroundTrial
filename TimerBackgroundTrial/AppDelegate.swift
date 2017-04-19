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
    var manager = CLLocationManager()
    var timer = Timer()

    let backgroundTaskName = "backgroundTaskName"
    var backgroundTaskId : UIBackgroundTaskIdentifier?
    var counter : Int = 0
    let timerIntervalSeconds : Int = 10
    var logFileName = "log.txt"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
       manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        
        if #available(iOS 9.0, *) {
            manager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        
        startTimer()
        
        manager.startUpdatingLocation()
        
        return true
    }
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if(!timer.isValid) {
            timer.invalidate()
            self.counter = 0;
            startTimer()
            print("In background fetch update INVALID TIMER")
            println(s: "Starting timer from background fetch")
        }
        print("In backgroud fetch valid TIMER")
        println(s: "in background fetch")
        completionHandler(.newData)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if(!timer.isValid) {
            timer.invalidate()
            self.counter = 0;
            startTimer()
            print("In Location update INVALID TIMER")
            println(s: "Starting timer from Location Update")
        }
        let currentLocation = locations.first
        print("Current Location Lat = \(String(describing: currentLocation?.coordinate.latitude))")
        print("Current Location Long = \(String(describing: currentLocation?.coordinate.longitude))")
        print("timer isValid= \(timer.isValid)")
        println(s: "timer isValid= \(timer.isValid)")
        println(s:"Current Location Lat = \(String(describing: currentLocation?.coordinate.latitude))")
        println(s:"Current Location Long = \(String(describing: currentLocation?.coordinate.longitude))")
    }
    
    func startTimer() {
        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: Double(timerIntervalSeconds) as Double, repeats: true) { (timer) in
                self.counter += 1
                if(self.counter == 1) {
                    self.logFileName = "\(self.getCurrentTime()).txt"
                }
                print("Count - \(self.counter) | Time - \((self.counter * self.timerIntervalSeconds/60)):\((self.counter * self.timerIntervalSeconds)%60))")
                self.println(s: "Count - \(self.counter) | Time - \((self.counter * self.timerIntervalSeconds/60)):\((self.counter * self.timerIntervalSeconds)%60))")
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func println(s:String) {
        var dump = ""
        if(self.counter == 1) {
            dump = "\(getCurrentTime())"
        }
        
        let paths: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory: NSString = paths[0] as! NSString
        let logPath: NSString = documentsDirectory.appendingPathComponent(logFileName) as NSString
        let path = logPath

        if FileManager.default.fileExists(atPath: path as String) {
            dump =  try! String(contentsOfFile: path as String, encoding: String.Encoding.utf8)
        }
        do {
            // Write to the file
            try  "\(dump)\n\(s)".write(toFile: path as String, atomically: true, encoding: String.Encoding.utf8)
            
        } catch let error as NSError {
            print("Failed writing to log file: \(path), Error: " + error.localizedDescription)
        }
    }
    
    func getCurrentTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH.mm.ss"    //"HH.mm dd.MM.yyyy"
        let result = formatter.string(from: date)
        return result
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: backgroundTaskName) {
            print("backgroundTaskName")
        }
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
        manager.startMonitoringSignificantLocationChanges()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
        if let taskId = backgroundTaskId {
            UIApplication.shared.endBackgroundTask(taskId)
        }
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("applicationWillTerminate")
    }

}


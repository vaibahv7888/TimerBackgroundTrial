//
//  TaskManager.swift
//  TimerBackgroundTrial
//
//  Created by Swapnil Luktuke on 4/27/17.
//  Copyright © 2017 Swapnil Luktuke. All rights reserved.
//

import Foundation
import UIKit

class TaskManager {
    static let shared = TaskManager()
    private init() {}
    
    let backgroundTaskName = "backgroundTaskName"
    var backgroundTaskId : UIBackgroundTaskIdentifier?
    var counter : Int = 0
    let timerIntervalSeconds : Int = 30
    var timer : Timer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        #if ALLBGMODES
            Logger.setLogFileName(name :"BGAllModes")
            application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
            LocationManager.shared.startLocationUpdates()
        #elseif BGFETCH
            Logger.setLogFileName(name :"BGFetch")
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        #elseif BGLOC
            Logger.setLogFileName(name :"BGLoc")
            LocationManager.shared.startLocationUpdates()
        #elseif BGBLE
            Logger.setLogFileName(name :"BGBLE")
        #else
        #endif
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NSLog("\(#function)")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NSLog("\(#function)")
        #if ALLBGMODES
            BLEScanManager.shared.stopBGBLETimer()
        #elseif BGLOC
        #elseif BGFETCH
        #elseif BGBLE
            BLEScanManager.shared.stopBGBLETimer()
        #else
            if let taskId = backgroundTaskId {
                UIApplication.shared.endBackgroundTask(taskId)
                backgroundTaskId = nil
            }
        #endif
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        NSLog("\(#function)")
        #if ALLBGMODES
        #elseif BGLOC
        #elseif BGFETCH
        #elseif BGBLE
        #else
        #endif
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        NSLog("\(#function)")
        #if ALLBGMODES
            BLEScanManager.shared.checkAndStartBackgroundBLETimer()
        #elseif BGLOC
        #elseif BGBLE
            BLEScanManager.shared.checkAndStartBackgroundBLETimer()
        #elseif BGFETCH
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
        #if ALLBGMODES
            LocationManager.shared.startMonitoringSignificantLocationChanges()
        #elseif BGBLE
        #elseif BGFETCH
        #elseif BGLOC
            LocationManager.shared.startMonitoringSignificantLocationChanges()
        #else
        #endif
    }
}


// MARK: Timer
private typealias TaskManagerTimer = TaskManager
extension TaskManagerTimer {
    func checkAndStartTimer() {
        if nil == timer || !(timer?.isValid)! {
            Logger.println(s: "Timer started at : \(getCurrentTime())")
                // Fallback on earlier versions
            timer = Timer.scheduledTimer(timeInterval: Double(timerIntervalSeconds), target: self, selector: #selector(timerFunction), userInfo: nil, repeats: true)
        }
    }
    
    @objc func timerFunction(timer : Timer) {
        self.counter += 1
        print("Count - \(self.counter) | Time - \((self.counter * self.timerIntervalSeconds/60)):\((self.counter * self.timerIntervalSeconds)%60))")
        Logger.println(s: "\(getCurrentTime()) | Count - \(self.counter) | Time - \((self.counter * self.timerIntervalSeconds/60)):\((self.counter * self.timerIntervalSeconds)%60))")
    }
    
}


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
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    let backgroundTaskName = "backgroundTaskName"
    var backgroundTaskId : UIBackgroundTaskIdentifier?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        TaskManager.shared.application(application, didFinishLaunchingWithOptions : launchOptions)
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NSLog("\(#function)")
        TaskManager.shared.applicationWillEnterForeground(application)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NSLog("\(#function)")
        TaskManager.shared.applicationDidBecomeActive(application)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        NSLog("\(#function)")
        TaskManager.shared.applicationWillResignActive(application)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        NSLog("\(#function)")
        TaskManager.shared.applicationDidEnterBackground(application)
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        NSLog("\(#function)")
        TaskManager.shared.applicationWillTerminate(application)
    }
    
    
    // MARK: BackgroundFetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("\(#function)")
        var fetchResult : UIBackgroundFetchResult = .newData

        backgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: backgroundTaskName) {
            print("Background task completed : \(self.backgroundTaskName)")
            if nil != self.backgroundTaskId {
                completionHandler(fetchResult)
                UIApplication.shared.endBackgroundTask(self.backgroundTaskId!)
            }
        }
        
        performFetchOperation(apiCompletionHandler:{(apiFetchResult : UIBackgroundFetchResult) in
            fetchResult = apiFetchResult
        })

    }

}


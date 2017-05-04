//
//  LocationManager.swift
//  TimerBackgroundTrial
//
//  Created by Swapnil Luktuke on 4/27/17.
//  Copyright © 2017 Swapnil Luktuke. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager : NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private override init() {
        super.init()
    }
    
    private var _locationManager : CLLocationManager?
    private var _deferedLocUpdateAllowed = false

    private func getLocationManager() -> CLLocationManager {
        if nil == _locationManager {
            _locationManager = CLLocationManager()
            _locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            _locationManager?.delegate = self
            _locationManager?.requestAlwaysAuthorization()
            _locationManager?.distanceFilter = kCLDistanceFilterNone
            _locationManager?.pausesLocationUpdatesAutomatically = true
            _deferedLocUpdateAllowed = false
            _locationManager!.allowsBackgroundLocationUpdates = true
        }
        return _locationManager!
    }
    
    
    func startLocationUpdates() {
        NSLog("\(#function)")
        getLocationManager().startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        NSLog("\(#function)")
        getLocationManager().stopUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        NSLog("\(#function)")
        getLocationManager().startMonitoringSignificantLocationChanges()
    }

    
    
    // MARK: Location manager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        NSLog("\(#function)")
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
        NSLog("\(#function)")
        Logger.println(s: "\(getCurrentTime()) | locationManagerDidPauseLocationUpdates")
    }
    
    
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        NSLog("\(#function)")
        Logger.println(s: "\(getCurrentTime()) | locationManagerDidResumeLocationUpdates")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        if nil != error {
            NSLog("\(#function) error : \(error!.localizedDescription)")
            Logger.println(s: "\(getCurrentTime()) | didFinishDeferredUpdatesWithError : \(error!.localizedDescription)")
        }
        manager.startUpdatingLocation()
    }
}

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

    private var _lastLocationupdateTimeStamp : TimeInterval = 0
    
    
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

    func stopMonitoringSignificantLocationChanges() {
        NSLog("\(#function)")
        getLocationManager().stopMonitoringSignificantLocationChanges()
    }
    
    
    // MARK: Location manager delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
//        NSLog("\(#function)")
        handleLocationsUpdate(locations: locations)
        if !_deferedLocUpdateAllowed {
            _locationManager?.allowDeferredLocationUpdates(untilTraveled: CLLocationDistanceMax, timeout: 300)
            _deferedLocUpdateAllowed = true
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("\(#function)")
        handleLocationError(error: error)
    }

    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        NSLog("\(#function)")
        Logger.println(s: "\(getCurrentTime()) | \(#function)")
    }
    
    
    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        NSLog("\(#function)")
        Logger.println(s: "\(getCurrentTime()) | \(#function)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        if nil != error {
            NSLog("\(#function) error : \(error!.localizedDescription)")
            handleLocationError(error: error!)
        }
        manager.startUpdatingLocation()
    }
    
    
    
    // MARK: Logging
    public func handleLocationError(error: Error) {
        Logger.println(s: "\(getCurrentTime()) | \(#function) : \(error.localizedDescription)")
    }
    
    public func handleLocationsUpdate(locations: [CLLocation]) {
        Logger.println(s: "\(getCurrentTime()) | \(#function) | _lastLocTmStmp : \(_lastLocationupdateTimeStamp)")
        for location in locations {
            if (location.timestamp.timeIntervalSince1970 - _lastLocationupdateTimeStamp) > 30 {
                _lastLocationupdateTimeStamp = location.timestamp.timeIntervalSince1970
                NSLog("\(#function) | _lastLocTmStmp : \(_lastLocationupdateTimeStamp) | _locTmStmp : \(location.timestamp.timeIntervalSince1970)")
                Logger.println(s: "\t\t\t | Loc(lat:long) -  \(location.coordinate.latitude) : \(location.coordinate.latitude) |  Accuracy : \(location.horizontalAccuracy) | Timestamp : \(location.timestamp) ")
            }
        }
    }
    
    
    
}

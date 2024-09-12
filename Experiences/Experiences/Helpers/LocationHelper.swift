//
//  LocationHelper.swift
//  Experiences
//
//  Created by Hayden Hastings on 7/12/19.
//  Copyright © 2019 Hayden Hastings. All rights reserved.
//

import Foundation
import CoreLocation

class LocationHelper: NSObject, CLLocationManagerDelegate {
    
    static var shared: LocationHelper = LocationHelper()
    
    lazy var locationManager: CLLocationManager = {
        let result = CLLocationManager()
        result.desiredAccuracy = kCLLocationAccuracyKilometer
        result.pausesLocationUpdatesAutomatically = true
        result.delegate = self
        return result
    }()
    
    // MARK: - Get the users location
    var currentLocation: CLLocation? {
        return locationManager.location
    }
    
    override init() {
        super.init()
        requestUserAuthorization()
    }
    
    func requestUserAuthorization() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        startTrackingLocation()
    }
    
    func startTrackingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopTrackingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Delegate Function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let _: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        stopTrackingLocation()
    }
}

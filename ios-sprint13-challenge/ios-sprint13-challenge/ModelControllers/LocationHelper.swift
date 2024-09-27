//
//  LocationHelper.swift
//  ios-sprint13-challenge
//
//  Created by De MicheliStefano on 19.10.18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import Foundation
import CoreLocation

class LocationHelper: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    lazy var locationManager: CLLocationManager = {
        var result = CLLocationManager()
        result.delegate = self
        return result
    }()
    
    // MARK: - Public
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getLocation() -> CLLocation? {
        //locationManager.requestLocation()
        return locationManager.location
    }
    
    // MARK: - CLLocationManagerDelegate
    
}


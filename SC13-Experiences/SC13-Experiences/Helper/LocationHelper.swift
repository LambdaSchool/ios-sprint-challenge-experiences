//
//  LocationHelper.swift
//  LambdaTimeline
//
//  Created by Andrew Dhan on 10/18/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import MapKit

class LocationHelper{
    
    func requestAuthorization(){
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation(){
        locationManager.requestLocation()
    }
    
    let locationManager = CLLocationManager()
}

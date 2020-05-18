//
//  Annotation.swift
//  Experiences
//
//  Created by Joshua Rutkowski on 5/17/20.
//  Copyright © 2020 Josh Rutkowski. All rights reserved.
//

import Foundation
import MapKit

extension Experience: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        name
    }
}

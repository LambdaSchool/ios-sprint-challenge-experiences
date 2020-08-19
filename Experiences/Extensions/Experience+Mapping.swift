//
//  Experience+Mapping.swift
//  Experiences
//
//  Created by TuneUp Shop  on 2/22/19.
//  Copyright © 2019 jkaunert. All rights reserved.
//

import Foundation
import MapKit

extension Experience: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return location
    }
    
    var title: String? {
        return experienceName
    }
    
    
    
    
}

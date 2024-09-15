//
//  Entry+Annotation.swift
//  Experiences
//
//  Created by Alex Shillingford on 2/24/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import Foundation
import MapKit

extension ExperienceEntry: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: (geotag?.coordinate.latitude)!, longitude: (geotag?.coordinate.longitude)!)
    }
    
    var title: String? {
        experienceTitle
    }
}

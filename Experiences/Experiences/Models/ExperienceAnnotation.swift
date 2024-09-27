//
//  ExperienceAnnotation.swift
//  Experiences
//
//  Created by Ufuk Türközü on 14.04.20.
//  Copyright © 2020 Ufuk Türközü. All rights reserved.
//

import Foundation
import MapKit

class ExperienceAnnotation: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
}

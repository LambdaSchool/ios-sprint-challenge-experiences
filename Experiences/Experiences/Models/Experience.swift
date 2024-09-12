//
//  Experience.swift
//  Experiences
//
//  Created by Jessie Ann Griffin on 5/15/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import Foundation
import MapKit

enum MediaType {
    case image
    case audio
    case video
}

class Experience: NSObject {
    let experienceTitle: String
    let latitude: Double
    let longitude: Double
    let media: MediaType
    
    init(title: String, geotag: CLLocationCoordinate2D, media: MediaType) {
        self.experienceTitle = title
        self.latitude = geotag.latitude
        self.longitude = geotag.longitude
        self.media = media
    }
}

extension Experience: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        experienceTitle
    }
}

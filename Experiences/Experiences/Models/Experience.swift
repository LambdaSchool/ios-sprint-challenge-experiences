//
//  Experience.swift
//  Experiences
//
//  Created by Ufuk Türközü on 10.04.20.
//  Copyright © 2020 Ufuk Türközü. All rights reserved.
//

import Foundation
import MapKit
//import CoreLocation

class Experience: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var image: UIImage?
    var audio: URL?
    var video: URL?
    
    init(title: String, coordinate: CLLocationCoordinate2D, image: UIImage?, audio: URL?, video: URL?) {
        self.title = title
        self.coordinate = coordinate
        self.image = image
        self.audio = audio
        self.video = video
    }
}

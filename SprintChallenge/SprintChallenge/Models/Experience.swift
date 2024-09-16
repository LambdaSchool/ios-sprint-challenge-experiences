//
//  Experience.swift
//  SprintChallenge
//
//  Created by Elizabeth Wingate on 4/11/20.
//  Copyright © 2020 Lambda. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class Experience: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var name: String?
    var image: UIImage?
    var audio: URL?
    var video: URL?
    
    init(coordinate: CLLocationCoordinate2D, name: String?, image: UIImage?, audio: URL?, video: URL?) {
        self.coordinate = coordinate
        self.name = name
        self.image = image
        self.audio = audio
        self.video = video
    }    
}

//
//  Experience.swift
//  Experiences
//
//  Created by Enrique Gongora on 4/10/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import Foundation
import MapKit

class Experience: NSObject {
    var expTitle: String?
    var image: UIImage?
    var video: URL?
    var audio: URL?
    var coordinate: CLLocationCoordinate2D
    
    
    init(title: String?, image: UIImage?, video: URL?, audio: URL?, coordinate: CLLocationCoordinate2D) {
        self.expTitle = title
        self.image = image
        self.video = video
        self.audio = audio
        self.coordinate = coordinate
        
    }
}

let mediaAdded = "mediaAdded"
let experienceSaved = "experienceSaved"

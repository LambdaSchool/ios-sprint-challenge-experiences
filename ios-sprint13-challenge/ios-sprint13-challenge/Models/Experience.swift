//
//  Experience.swift
//  ios-sprint13-challenge
//
//  Created by De MicheliStefano on 19.10.18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class Experience: NSObject {
    
//    init(title: String?, audioURL: URL?, videoURL: URL?, image: UIImage?) {
//        self.experienceTitle = title
//        self.audioURL = audioURL
//        self.videoURL = videoURL
//        self.image = image
//    }
    
    var experienceTitle: String?
    var audioURL: URL?
    var videoURL: URL?
    var image: UIImage?
    var geotag: CLLocationCoordinate2D?
    
}

extension Experience: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        guard let geotag = self.geotag else { return kCLLocationCoordinate2DInvalid }
        
        return geotag
    }
    
    var title: String? {
        return self.experienceTitle
    }
    
//    var subtitle: String? {
//        return self.experienceTitle
//    }
    
}

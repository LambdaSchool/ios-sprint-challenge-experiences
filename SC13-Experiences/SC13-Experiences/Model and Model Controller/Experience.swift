//
//  File.swift
//  SC13-Experiences
//
//  Created by Andrew Liao on 10/19/18.
//  Copyright © 2018 Andrew Liao. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Experience: NSObject {
   init(with title:String, audio: URL, image: UIImage, video: URL, location: CLLocationCoordinate2D) {
        self.title = title
        self.audio = audio
        self.image = image
        self.video = video
        self.location = location
    }
    
    
    // MARK: - Properties
    var title: String?
    var audio: URL
    var image: UIImage
    var video: URL
    var location: CLLocationCoordinate2D
}

extension Experience: MKAnnotation{
    var coordinate: CLLocationCoordinate2D {
        return self.location
    }
    var getTitle: String{
        return self.title!
    }
}

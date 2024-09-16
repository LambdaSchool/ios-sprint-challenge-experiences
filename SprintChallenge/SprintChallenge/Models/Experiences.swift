//
//  Experiences.swift
//  SprintChallenge
//
//  Created by Elizabeth Wingate on 4/10/20.
//  Copyright © 2020 Lambda. All rights reserved.
//

import Foundation
import MapKit

class Experience: NSObject {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        subtitle = "\(title) expericence"
        audio = title
        video = title
    }
    var audio: String?
    var video: String?
    var image: UIImage?
}

extension Experience: MKAnnotation {
 //Setting up mapKit with experiences?
}

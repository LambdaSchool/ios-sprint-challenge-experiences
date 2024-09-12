//
//  Experience.swift
//  Experiences
//
//  Created by Hayden Hastings on 7/12/19.
//  Copyright © 2019 Hayden Hastings. All rights reserved.
//

import Foundation
import MapKit

class Experience: NSObject, MKAnnotation {
    var postTitle: String
    var audioURL: URL
    var videoURL: URL
    var image: URL
    var coordinate: CLLocationCoordinate2D
    
    init(postTitle: String, audioURL: URL, videoURL: URL, image: URL, coordinate: CLLocationCoordinate2D) {
        self.postTitle = postTitle
        self.audioURL = audioURL
        self.videoURL = videoURL
        self.image = image
        self.coordinate = coordinate
    }
}

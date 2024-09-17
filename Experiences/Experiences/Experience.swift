//
//  Experience.swift
//  Experiences
//
//  Created by Karen Rodriguez on 5/8/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation
import MapKit
class Experience: NSObject {

    var expTitle: String
    var content: String
    var videoURL: String?
    var imageData: Data?
    var audioURL: String?
    var geoTag: CLLocationCoordinate2D

    internal init(expTitle: String, content: String, geoTag: CLLocationCoordinate2D, videoURL: String? = nil, imageData: Data? = nil, audioURL: String? = nil) {
        self.expTitle = expTitle
        self.content = content
        self.videoURL = videoURL
        self.imageData = imageData
        self.audioURL = audioURL
        self.geoTag = geoTag
    }
}

extension Experience: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        geoTag
    }

    var title: String? {
        expTitle
    }

    var subtitle: String? {
        content
    }

}

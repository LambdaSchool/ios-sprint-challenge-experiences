//
//  ExperienceController.swift
//  Experiences
//
//  Created by Tobi Kuyoro on 08/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import Foundation
import MapKit

class ExperienceController {

    var experiences: [Experience] = []

    func createExperience(called title: String,
                          at coordinate: CLLocationCoordinate2D,
                          image: UIImage? = nil,
                          audioURL: URL? = nil,
                          videoURL: URL? = nil) {

        let experience = Experience(title: title, coordinate: coordinate, image: image, audioURL: audioURL, videoURL: videoURL)
        experiences.append(experience)
    }
}

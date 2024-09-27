//
//  ExperienceController.swift
//  Experiences
//
//  Created by Ufuk Türközü on 10.04.20.
//  Copyright © 2020 Ufuk Türközü. All rights reserved.
//

import Foundation
import MapKit

class ExperienceController {
    
    var experiences: [Experience] = [] {
        didSet {
            print("Experiences: \(experiences)")
        }
    }
    
    func createExperience(title: String, coordinate: CLLocationCoordinate2D, video: URL? = nil, audio: URL? = nil, image: UIImage?) {

        let experience = Experience(title: title, coordinate: coordinate, image: image, audio: audio, video: video)
        experiences.append(experience)
    }
}

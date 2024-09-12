//
//  ExperienceController.swift
//  Experiences
//
//  Created by Hayden Hastings on 7/12/19.
//  Copyright © 2019 Hayden Hastings. All rights reserved.
//

import UIKit
import MapKit

class ExperienceController {
    var newExperiences: Experience?
    
    private(set) var experiences: [Experience] = []
    
    // MARK: - CRUD
    func createExperience(with postTitle: String, audioURL: URL, videoURL: URL, image: URL, coordinate: CLLocationCoordinate2D) {
        let newExperience = Experience(postTitle: postTitle, audioURL: audioURL, videoURL: videoURL, image: image, coordinate: coordinate)
        
        experiences.append(newExperience)
        newExperiences = newExperience
    }
}

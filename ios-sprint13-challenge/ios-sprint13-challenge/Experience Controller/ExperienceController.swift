//
//  ExperienceController.swift
//  ios-sprint13-challenge
//
//  Created by Conner on 10/19/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import Foundation
import MapKit

class ExperienceController {
    func createExperience(title: String, audioURL: URL, videoURL: URL, imageData: Data, coordinate: CLLocationCoordinate2D) {
        let experience = Experience(title: title, audioURL: audioURL, videoURL: videoURL, imageData: imageData, coordinate: coordinate)
        experiences.append(experience)
    }
    
    private(set) var experiences: [Experience] = []
}

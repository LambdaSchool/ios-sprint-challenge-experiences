//
//  ExperienceController.swift
//  Experiences
//
//  Created by macbook on 12/6/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit
import  MapKit

class ExperienceController {
    
    var experiences: [Experience] = []
    var video: URL?
    var image: UIImage?
    var audio: URL?
    var geotag: CLLocationCoordinate2D?

    func createExperience(title: String, note: String?, geotag: CLLocationCoordinate2D?) {
        
        let newExperience = Experience(video: video, image: image, title: title, note: note, audio: audio, geotag: geotag)
        
        experiences.append(newExperience)
        print("Experience with title \(newExperience.title) was created!")
        
        
        // Prints Statements
        if let index = experiences.firstIndex(where: { $0.title == newExperience.title }) {
            let testingExperience = experiences[index]
            
            if video != nil {
                print("Experience \(testingExperience.title) has a video!")
                
            } else {
                print("Experience \(testingExperience.title) does NOT have a video")
            }
            
            if image != nil {
                print("Experience \(testingExperience.title) has an image!")
                
            } else {
                print("Experience \(testingExperience.title) does NOT have an image")
            }
            if audio != nil {
                print("Experience \(testingExperience.title) has audio!")
                
            } else {
                print("Experience \(testingExperience.title) does NOT have audio")
            }
            
            if geotag != nil {
                print("Experience \(testingExperience.title) has a geotag!")
                
            } else {
                print("Experience \(testingExperience.title) does NOT have a geotag")
            }
        }
    }
}

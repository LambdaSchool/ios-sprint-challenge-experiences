//
//  ExperienceController.swift
//  MyExperiences
//
//  Created by Diante Lewis-Jolley on 7/12/19.
//  Copyright © 2019 Diante Lewis-Jolley. All rights reserved.
//

import Foundation
import MapKit

class ExperienceController {

     var experiences: [Experience] = []


   // var newExperience: Experience?
   // var location: CLLocationCoordinate2D!

    func createExperience(title: String?, audio: URL, video: URL, image: UIImage, coordinate: CLLocationCoordinate2D) {

        let newExp = Experience(title: title, audio: audio, image: image, video: video, coordinate: coordinate)

       experiences.append(newExp)
    }





}

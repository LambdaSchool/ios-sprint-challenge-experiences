//
//  ExperienceController.swift
//  SC13-Experiences
//
//  Created by Andrew Liao on 10/19/18.
//  Copyright © 2018 Andrew Liao. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ExperienceController{
    static let shared = ExperienceController()
    
    //MARK: - CRUD
    func create(with title:String, audio: URL, image: UIImage, video: URL, location: CLLocationCoordinate2D){
        let new = Experience(with: title, audio: audio, image: image, video: video, location: location)
        experiences.append(new)
    }
    
    //MARK: - Properties
    private (set) var experiences = [Experience]()
}

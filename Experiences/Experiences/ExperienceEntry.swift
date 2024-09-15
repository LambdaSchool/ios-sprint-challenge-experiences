//
//  ExperienceEntry.swift
//  Experiences
//
//  Created by Alex Shillingford on 2/14/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MapKit

class ExperienceEntry: NSObject {
    var experienceTitle, entryDescription: String
    var photo: UIImage?
    var movie: AVCaptureOutput?
    var audio: AVAudioFile?
    var id: UUID
    var geotag: CLLocation?
    
    init(title: String, description: String, photo: UIImage?, movie: AVCaptureOutput?, audio: AVAudioFile?, id: UUID = UUID(), geotag: CLLocation) {
        self.experienceTitle = title
        self.entryDescription = description
        self.photo = photo
        self.movie = movie
        self.audio = audio
        self.id = id
        self.geotag = geotag
        
        super.init()
    }
}

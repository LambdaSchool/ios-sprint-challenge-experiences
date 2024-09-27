//
//  Experience.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/17/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import Foundation
import AVKit

struct Experience: Hashable {
    var title: String
    var photo: UIImage?
    var audioURL: URL?
    var videoURL: URL?
    var latitude: Double?
    var longitude: Double?
}

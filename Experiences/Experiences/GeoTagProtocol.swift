//
//  GeoTagProtocol.swift
//  Experiences
//
//  Created by Alex Shillingford on 2/15/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import Foundation
import CoreImage
import Photos
import AVFoundation
import MapKit

protocol GeoTagPost {
    func addGeoTagToPost(_ entry: ExperienceEntry, location: CLLocationCoordinate2D)
}

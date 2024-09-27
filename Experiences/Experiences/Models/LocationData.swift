//
//  LocationData.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/24/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import Foundation
import MapKit
import SwiftUI
import Combine

class LocationData: ObservableObject {
    @Published var latitude: Double?
    @Published var longitude: Double?
    @Published var location: CLLocation?
}

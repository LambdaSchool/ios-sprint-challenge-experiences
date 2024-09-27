//
//  ExperienceData.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/23/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import Combine
import SwiftUI

class ExperienceData: ObservableObject {
    @Published var experiences = [Experience]()
}

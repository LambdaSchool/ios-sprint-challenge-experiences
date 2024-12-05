//
//  Experience+MKAnnotation.swift
//  Experiences
//
//  Created by Enrique Gongora on 4/10/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import Foundation
import MapKit

extension Experience: MKAnnotation {
    var title: String? {
        expTitle
    }
}

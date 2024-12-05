//
//  Notification.swift
//  Experiences
//
//  Created by Enrique Gongora on 4/10/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import Foundation

enum myNotificationKeys: String {
    case mediaAdded = "mediaAdded"
    case experienceSaved = "experienceSaved"
}

extension NSNotification.Name {
    static let saveTapped = NSNotification.Name("saveTapped")
    static let mediaAdded = NSNotification.Name("mediaAdded")
}

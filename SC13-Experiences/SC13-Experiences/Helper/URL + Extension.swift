//
//  URL + Extension.swift
//  SC13-Experiences
//
//  Created by Andrew Dhan on 10/19/18.
//  Copyright © 2018 Andrew Liao. All rights reserved.
//

import Foundation

enum MediaType: String{
    case audio = "caf"
    case video = "mov"
}
extension URL{
    static func newRecordingURL(mediaType: MediaType) -> URL {
        let fm = FileManager.default
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension(mediaType.rawValue)
    }
}

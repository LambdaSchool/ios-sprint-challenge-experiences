//
//  Experience.swift
//  Experiences
//
//  Created by Joshua Rutkowski on 5/17/20.
//  Copyright © 2020 Josh Rutkowski. All rights reserved.
//

import Foundation

class Experience: NSObject, Codable {
    
    let name: String
    let id: String = UUID().uuidString
    let date: Date = Date()
    let latitude: Double
    let longitude: Double
    var videoExtension: String
    let audioExtension: String
    var videoURL: URL? {
        if videoExtension.isEmpty {
            return nil
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(videoExtension).appendingPathExtension("mov")
    }
    var audioURL: URL? {
        if audioExtension.isEmpty {
            return nil
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(audioExtension).appendingPathExtension("caf")
    }
    var photoExtension: String
    var photoURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(photoExtension).appendingPathExtension("png")
    }
    
    init(title: String, latitude: Double, longitude: Double, videoExtension: String = "", audioExtension: String = "", photoExtension: String = "") {
        self.name = title
        self.latitude = latitude
        self.longitude = longitude
        self.videoExtension = videoExtension
        self.audioExtension = audioExtension
        self.photoExtension = photoExtension
    }
}

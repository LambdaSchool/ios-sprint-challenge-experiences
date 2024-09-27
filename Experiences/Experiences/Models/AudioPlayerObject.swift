//
//  AudioPlayerObject.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/23/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import Foundation
import AVFoundation
import SwiftUI
import Combine

class AudioPlayerObject: ObservableObject {
    @Published var player: AVAudioPlayer?
    
    func loadAudio(url: URL?) {
        guard let audioURL = url else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: audioURL)
        } catch {
            preconditionFailure("Failure to load audio: \(error)")
        }
    }
}

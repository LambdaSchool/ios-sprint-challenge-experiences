//
//  AudioPlayer.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/17/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import SwiftUI
import AVFoundation

struct AudioPlayer: View {
    @State var sliderValue: Double
    @ObservedObject var audioPlayerObject: AudioPlayerObject
    var player: AVAudioPlayer?
    var audioURL: URL?
    
    var body: some View {
        VStack {
            HStack {
                Text("0:00")
                Slider(value: $sliderValue)
                Text("0:00")
            }
            
            HStack {
                Button(action: {
                    self.audioPlayerObject.player?.play()
                }) {
                    Image(systemName: "play.fill")
                }
                
                Spacer()
                
                Button(action: {
                    self.audioPlayerObject.player?.pause()
                }) {
                    Image(systemName: "pause.fill")
                }
            }
        }
        .frame(height: screen.width / 3)
        .padding(.horizontal)
        .onAppear {
            self.audioPlayerObject.loadAudio(url: self.audioURL)
        }
    }
    
    mutating func loadAudio() {
        guard let audioURL = audioURL else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: audioURL)
        } catch {
            preconditionFailure("Failure to load audio: \(error)")
        }
    }
}

struct AudioPlayer_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE (2nd generation)", "iPhone 11", "iPhone 11 Pro Max"], id: \.self) { deviceName in
            AudioPlayer(sliderValue: 0.0, audioPlayerObject: AudioPlayerObject())
                .previewDevice(PreviewDevice(rawValue: deviceName))
        }
    }
}

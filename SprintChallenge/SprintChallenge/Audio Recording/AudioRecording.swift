//
//  AudioRecording.swift
//  SprintChallenge
//
//  Created by Elizabeth Wingate on 4/10/20.
//  Copyright © 2020 Lambda. All rights reserved.
//

import AVFoundation

class AudioRecording: NSObject {
    let name: String
    private var audioRecording: AVAudioPlayer?
    var timer: Timer?
    
    init(name: String) {
        self.name = name
        
    }
    
    private func setupPlayer() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let url = documentsDirectory.appendingPathComponent(name).appendingPathExtension("caf")
        
        do {
            audioRecording = try AVAudioPlayer(contentsOf: url)
            audioRecording?.delegate = self
        } catch {
            NSLog("audioPlayer: \(error)")
        }
        
        audioRecording?.play()
        print(url)
    }
    
    func play() {
        setupPlayer()
    }
    
    func pause() {
        audioRecording?.pause()
    }

    var isPlaying: Bool {
        return audioRecording?.isPlaying ?? false
    }
    
    var elapsedTime: TimeInterval? {
        return audioRecording?.currentTime
    }
    
    var duration: TimeInterval? {
        return audioRecording?.duration
    }
    
}

extension AudioRecording: AVAudioPlayerDelegate {
    
    func audioRecordingDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            fatalError("audioPlayerDecodeErrorDidOccur: \(error)")
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: .audioRecordingDidFinishPlaying, object: nil)
        print("audioRecordingDidFinishPlaying")
    }
}

extension Notification.Name {
    static let audioRecordingDidFinishPlaying =  Notification.Name("AudioRecordingDidFinishPlaying")
}

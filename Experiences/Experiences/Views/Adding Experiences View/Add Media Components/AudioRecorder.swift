//
//  AudioRecorder.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/20/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class AudioRecorder: ObservableObject {
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    var audioRecorder: AVAudioRecorder!
    var recording = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    var recordingURL: URL? {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session: \(error)")
        }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        recordingURL = createNewRecordingURL()
        
        do {
            guard let recordingURL = recordingURL else { return }
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            audioRecorder.record()
            
            recording = true
        } catch {
            print("Cound not start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        recording = false
    }
    
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
        return file
    }
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}

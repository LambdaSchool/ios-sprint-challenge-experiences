//
//  RecordVideoViewController.swift
//  Experiences-Xcode
//
//  Created by Austin Potts on 3/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewControllerDelegate {
    func setRecordURL(_ recordURL: URL)
    func saveWithNoVideo()
}

class RecordVideoViewController: UIViewController {

    @IBOutlet weak var videoView: CameraView!
    @IBOutlet weak var recordButton: UIButton!
    
    var experienceController: ExperienceController!
    var delegate: CameraViewControllerDelegate!
    
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    var player: AVPlayer!
    var recordURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

         setUpCamera()
    }
    
  override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            captureSession.startRunning()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            if fileOutput.isRecording {
                fileOutput.stopRecording()
            }
            captureSession.stopRunning()
            deletePreviousRecording()
        }
        
        //MARK: Private
        
        private func updateViews() {
            recordButton.isSelected = fileOutput.isRecording
        }
        
        private func setUpCamera() {
            let camera = bestCamera()
            
            captureSession.beginConfiguration()
            guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
                fatalError("Can't create a camera input")
            }
            
            // Add video input
            guard captureSession.canAddInput(cameraInput) else {
                fatalError("Session can't handle this type of input: \(cameraInput)")
            }
            captureSession.addInput(cameraInput)
            
            if captureSession.canSetSessionPreset(.medium) {
                captureSession.sessionPreset = .medium
            }
            
            // Add audio input
            let microphone = bestAudio()
            guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else {
                fatalError("Can't create input from microphone")
            }
            guard captureSession.canAddInput(audioInput) else {
                fatalError("Can't add audio input")
            }
            captureSession.addInput(audioInput)
            
            // Add video output
            guard captureSession.canAddOutput(fileOutput) else {
                fatalError("Cannot record to disk")
            }
            captureSession.addOutput(fileOutput)
            
            captureSession.commitConfiguration()
            
            videoView.session = captureSession
        }

        private func bestCamera() -> AVCaptureDevice {
            if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
                return device
            } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                return device
            }
            
            fatalError("No cameras found")
        }
        
        private func bestAudio() -> AVCaptureDevice {
            if let device = AVCaptureDevice.default(for: .audio) {
                return device
            }
            fatalError("No audio")
        }
        
        private func newRecordingURL() {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            let name = formatter.string(from: Date())
            let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
            
            recordURL = fileURL
        }
        
        private func deletePreviousRecording() {
            let fileManager = FileManager.default
            
            do {
                if let recordURL = recordURL {
                    try fileManager.removeItem(at: recordURL)
                    self.recordURL = nil
                }
            } catch {
                NSLog("Error deleting previous recording: \(error)")
            }
        }
        
        private func toggleRecord() {
            if fileOutput.isRecording {
                fileOutput.stopRecording()
            } else {
                deletePreviousRecording()
                newRecordingURL()
                guard let recordURL = recordURL else { return }
                fileOutput.startRecording(to: recordURL, recordingDelegate: self)
            }
        }
        
        //MARK: Actions
        
   
        
    
    

    @IBAction func recordTapped(_ sender: Any) {
        toggleRecord()
    }
    
    
    
    @IBAction func saveTapped(_ sender: Any) {
        if let recordURL = recordURL {
            recordButton.isEnabled = false
            delegate.setRecordURL(recordURL)
            self.recordURL = nil
        } else {
            delegate.saveWithNoVideo()
        }
    }
    
}

extension RecordVideoViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        }
        
        print(outputFileURL.path)
        updateViews()
    }
}

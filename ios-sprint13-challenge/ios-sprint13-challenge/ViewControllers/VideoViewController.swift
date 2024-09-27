//
//  VideoViewController.swift
//  ios-sprint13-challenge
//
//  Created by De MicheliStefano on 19.10.18.
//  Copyright © 2018 De MicheliStefano. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    // MARK: - Properties
    
    var experienceController: ExperienceController!
    var experience: Experience?
    private var captureSession: AVCaptureSession!
    private var recordOutput: AVCaptureMovieFileOutput!
    
    @IBOutlet weak var previewView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCapture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    @IBAction func toggleRecord(_ sender: Any) {
        if recordOutput.isRecording {
            recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    @IBAction func save(_ sender: Any) {
        self.addExperience()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.updateViews()
            // Save video
            self.experience?.videoURL = outputFileURL
            
            if let _ = self.experience?.videoURL {
                let alert = UIAlertController(title: "Saved video", message: "You shall go on now recording more experiences", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                    self.addExperience()
                    self.dismiss(animated: true, completion: nil)
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    

    // MARK: - Private
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        let recordButtonImageName = recordOutput.isRecording ? "Stop" : "Record"
        recordButton.setImage(UIImage(named: recordButtonImageName), for: .normal)
    }
    
    private func addExperience() {
        if let experience = experience {
            experienceController.experiences.append(experience)
        }
    }
    
    private func setupCapture() {
        let captureSession = AVCaptureSession()
        let device = bestCamera()
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(videoDeviceInput) else {
                fatalError()
        }
        captureSession.addInput(videoDeviceInput)
        
        let fileOutput = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(fileOutput) else { fatalError() }
        captureSession.addOutput(fileOutput)
        recordOutput = fileOutput
        
        captureSession.sessionPreset = .hd1920x1080
        captureSession.commitConfiguration()
        
        self.captureSession = captureSession
        
        previewView.videoPreviewLayer.session = captureSession
    }
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing expected back camera device")
        }
    }

}

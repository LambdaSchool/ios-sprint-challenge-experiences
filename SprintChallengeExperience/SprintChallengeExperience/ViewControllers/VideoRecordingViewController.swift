//
//  VideoRecordingViewController.swift
//  SprintChallengeExperience
//
//  Created by Jerry haaser on 1/17/20.
//  Copyright © 2020 Jerry haaser. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class VideoRecordingViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    private var captureSession: AVCaptureSession!
    private var recordOutput: AVCaptureMovieFileOutput!
    var experienceController: ExperienceController?
    var imageData: Data?
    var experienceTitle: String?
    var audioURL: URL?
    var coordinate: CLLocationCoordinate2D?
    var videoURL: URL?
    
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
    
    @IBAction func toggleRecord(_ sender: UIButton) {
        if recordOutput.isRecording {
            recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    @IBAction func saveExperienceTapped(_ sender: UIBarButtonItem) {
        guard let experienceTitle = experienceTitle,
            let audioURL = audioURL,
            let videoURL = videoURL,
            let imageData = imageData,
            let coordinate = coordinate else { return }
        experienceController?.createExperience(title: experienceTitle, audioURL: audioURL, videoURL: videoURL, imageData: imageData, coordinate: coordinate)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.updateViews()
            PHPhotoLibrary.requestAuthorization { (status) in
                if status != .authorized {
                    NSLog("Please give Experiences access to your photos in settings.")
                    return
                }
                
                PHPhotoLibrary.shared().performChanges({
                    self.videoURL = outputFileURL
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                }, completionHandler: { (success, error) in
                    if let error = error {
                        NSLog("Error saving video to photo library: \(error)")
                    }
                })
            }
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
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing expected back camera device")
        }
    }
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return
            documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    private func updateViews() {
        guard isViewLoaded else { return }
        let recordButtonImageName = recordOutput.isRecording ? "Stop" : "Record"
        recordButton.setImage(UIImage(named: recordButtonImageName)!, for: .normal)
    }

}

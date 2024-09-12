//
//  VideoRecordingViewController.swift
//  Experiences
//
//  Created by Hayden Hastings on 7/12/19.
//  Copyright © 2019 Hayden Hastings. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import CoreLocation

class VideoRecordingViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, CLLocationManagerDelegate {
    
    // MARK: - IBOutlets Properties
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    
    let experienceController = ExperienceController()
    var imageURL: URL?
    var titleTextString: String?
    var audioURL: URL?
    var videoURL: URL?
    var cLLocation: CLLocationCoordinate2D?
    var captureSession = AVCaptureSession()
    var recordOutput = AVCaptureMovieFileOutput()
    var locationManager: CLLocationManager!
    private var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authorizeCameraAccess()
        setupCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    // MARK: - Methods
    
    private func updateViews() {
        let isRecording = recordOutput.isRecording
        
        let recordButtonImage = isRecording ? "Stop" : "Record"
        recordButton.setImage(UIImage(named: recordButtonImage), for: .normal)
    }
    
    private func authorizeCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Authorized")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    print("Authorized")
                } else {
                    print("Not Authorized")
                }
            }
            
        case .restricted:
            return
        case .denied:
            return
        }
    }
    
    func playMovie(url: URL) {
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        var topRect = self.view.bounds
        topRect.size.width = topRect.width / 2
        topRect.size.height = topRect.height / 2
        playerLayer.frame = topRect
        
        view.layer.addSublayer(playerLayer)
        
        player.play()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        self.videoURL = outputFileURL
        DispatchQueue.main.async {
            self.updateViews()
            self.playMovie(url: outputFileURL)
            
            PHPhotoLibrary.requestAuthorization({ (status) in
                guard status == .authorized else {
                    NSLog("Please give video filterd access to photo library in settings")
                    return
                }
                
                PHPhotoLibrary.shared().performChanges({ PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                    
                }, completionHandler: { (success, error) in
                    try! FileManager.default.removeItem(at: outputFileURL)
                    if let error = error {
                        NSLog("Error saving video to photo library: \(error)")
                    }
                })
            })
        }
    }
    
    
    func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        let cameraDevice = bestCamera()
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else { return }
        guard let cameraDeviceInput = try? AVCaptureDeviceInput(device: cameraDevice),
            captureSession.canAddInput(cameraDeviceInput) else { fatalError("Unable to create camera input") }
        
        guard let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice) else { return }
        captureSession.addInput(cameraDeviceInput)
        captureSession.addInput(audioDeviceInput)
        
        let fileOutput = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(fileOutput) else { fatalError("Unable to add movie file output to capture session") }
        
        captureSession.addOutput(fileOutput)
        captureSession.sessionPreset = .hd1920x1080
        captureSession.commitConfiguration()
        
        self.captureSession = captureSession
        self.recordOutput = fileOutput
        
        cameraView.videoPreviewLayer.session = captureSession
    }
    
    
    private func saveVideoRecoding(with url: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }, completionHandler: { (success, error) in
                if let error = error {
                    NSLog("There was an error saving Photo: \(error)")
                } else {
                    
                }
            })
        }
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing expected back camera on device")
        }
    }
    
    private func newRecordingURL() -> URL {
        let documentDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVC" {
            let destinationVC = segue.destination as? MapViewController
            destinationVC?.experienceController = experienceController
            destinationVC?.experience = experienceController.experiences
        }
    }
    
    // MARK: - IBActions Properties
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if recordOutput.isRecording {
            recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextString,
            let audioURL = self.audioURL,
            let videoURL = self.videoURL,
            let imageURL = self.imageURL else { return }
        
        experienceController.createExperience(with: title, audioURL: audioURL, videoURL: videoURL, image: imageURL, coordinate: LocationHelper.shared.currentLocation?.coordinate ?? kCLLocationCoordinate2DInvalid)
        
        performSegue(withIdentifier: "toMapVC", sender: self)
    }
    
}

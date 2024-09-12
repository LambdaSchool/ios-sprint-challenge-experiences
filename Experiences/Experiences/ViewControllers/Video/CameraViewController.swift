//
//  CameraViewController.swift
//  Experiences
//
//  Created by Jessie Ann Griffin on 5/15/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MapKit

class CameraViewController: UIViewController {
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    var delegate: AddExperienceDelegate?
    
    private var player: AVPlayer!
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Resize camera preview to fill the entire screen
        cameraView.videoPlayerLayer.videoGravity = .resizeAspectFill
        setUpCamera()
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapgesture)
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            playRecording()
        }
    }
    
    func playRecording() {
        if let player = player {
            player.seek(to: CMTime(seconds: 0, preferredTimescale: 600)) // N / D, D = 600 gives good resolution in regards to time
            player.play()
        }
    }
    
    func playMovie(url: URL) {
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: url)
        self.present(playerVC, animated: true, completion: nil)
        //        player = AVPlayer(url: url)
        //
        //        let playerView = MoviePlayerView()
        //        playerView.player = player
        //
        //        var topRect = view.bounds
        //        topRect.size.height /= 4
        //        topRect.size.width /= 4
        //        topRect.origin.y = view.layoutMargins.top
        //
        //        playerView.frame = topRect
        //        view.addSubview(playerView)
        //
        //        player.play()
    }
    
    private func setUpCamera() {
        let camera = bestCamera()
        let microphone = bestMicrophone()
        
        captureSession.beginConfiguration()
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            preconditionFailure("Can't create an input from the camera, but we should do something better than crashing!")
        }
        guard let microphoneInput = try? AVCaptureDeviceInput(device: microphone) else {
            preconditionFailure("Can't create an input from the microphone, but we should do something better than crashing!")
        }
        guard captureSession.canAddInput(cameraInput) else {
            preconditionFailure("This session can't handle this type of input: \(cameraInput)")
        }
        guard captureSession.canAddInput(microphoneInput) else {
            preconditionFailure("This session can't handle this type of input: \(microphoneInput)")
        }
        captureSession.addInput(cameraInput)
        captureSession.addInput(microphoneInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        guard captureSession.canAddOutput(fileOutput) else {
            preconditionFailure("The session can't handle this type of output: \(fileOutput)")
        }
        captureSession.addOutput(fileOutput)
        captureSession.commitConfiguration()
        
        cameraView.session = captureSession
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        }
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        preconditionFailure("No cameras on device matched the specs that we need.")
    }
    
    private func bestMicrophone() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        
        preconditionFailure("No microphones on device matched the specs that we need.")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func generateRandomLatitude() -> Double {
        return Double.random(in: -90...90)
    }
    
    private func generateRandomLongitude() -> Double {
        return Double.random(in: -180...180)
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        
        if fileOutput.isRecording {
            fileOutput.stopRecording()
            
            let alert = UIAlertController(title: "Add a Title or Caption",
                                          message: "Describe your experience!",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addTextField { textField in
                textField.placeholder = "Title:"
            }
            
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
                if let experienceTitle = alert.textFields?.first?.text {
                    let experience = Experience(title: experienceTitle,
                                                geotag: CLLocationCoordinate2D(latitude: self.generateRandomLatitude(),
                                                                               longitude: self.generateRandomLongitude()),
                                                media: .image)
                    
                    self.delegate?.experienceWasCreated(experience)
                    self.dismiss(animated: true, completion: nil)
                }
            }))
            self.present(alert, animated: true)
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }


/// Creates a new file URL in the documents directory
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }

    func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        }
        
        print("Video URL: \(outputFileURL)")
        updateViews()
        playMovie(url: outputFileURL)
    }
}


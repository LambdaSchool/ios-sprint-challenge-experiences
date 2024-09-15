//
//  CameraViewController.swift
//  Experiences
//
//  Created by Alex Shillingford on 2/16/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    private var player: AVPlayer!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraView: CameraPreviewView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        
        // TODO - Add setUpCamera() call and tapGestureRecognizer???
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tapGesture:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        captureSession.stopRunning()
    }
    
    // MARK: - Video Preview
    func playMovie(url: URL) {
        player = AVPlayer(url: url)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        var topRect = view.bounds
        topRect.size.height = topRect.height / 3
        topRect.size.width = topRect.width / 3
        topRect.origin.y = view.layoutMargins.top
        
        playerLayer.frame = topRect
        view.layer.addSublayer(playerLayer)
        
        player.play()
    }
    
    // Meant to play the original recording
    @objc func handleTapGesture(tapGesture: UITapGestureRecognizer) {
        
        print("tap")
        
        switch tapGesture.state {
        case .ended: // finished tapping the screen
            replayMovie()
        default:
            print("Handle other states: \(tapGesture.state)")
        }
        
    }
    
    func replayMovie() {
        if let player = player {
            player.seek(to: CMTime.zero) // CMTime(0, 30)
            
            player.play()
        }
    }
    
    // MARK: - CAMERA SETUP METHODS
    private func setUpCamera() {
        
        // Set up camera
        let camera = bestCamera()
        
        captureSession.beginConfiguration()
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            fatalError("Device configured incorrectly")
        }
        
        guard captureSession.canAddInput(cameraInput) else {
            fatalError("Unable to add camera input")
        }
        captureSession.addInput(cameraInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        // Set up Microphone for audio with video captured
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else {
            fatalError("Can't create input from microphone")
        }
        
        guard captureSession.canAddInput(audioInput) else {
            fatalError("Can't add audio input")
        }
        captureSession.addInput(audioInput)
        
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("I know these fatal errors are bad, just trying to reach MVP functionality. Oh also you can't add file output")
        }
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
        cameraView.session = captureSession
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        fatalError("No cameras available on the device")
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
    }
}

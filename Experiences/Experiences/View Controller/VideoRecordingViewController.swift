//
//  VideoRecordingViewController.swift
//  Experiences
//
//  Created by Enrique Gongora on 4/10/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit

class VideoRecordingViewController: UIViewController {
    
    // MARK: - Properties
    lazy var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    var experience: Experience?
    var video: URL!
    var player: AVPlayer!
    
    // MARK: - IBOutlets
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        updateViews()
        toggleRecording()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if let experience = experience {
            experience.video = video
            let experienceDictionary = [mediaAdded : experience]
            NotificationCenter.default.post(name: .mediaAdded, object: nil, userInfo: experienceDictionary)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        replayMovie()
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPermissionAndShowCamera()
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        setupCaptureSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    // MARK: - Functions
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    private func toggleRecording() {
        let url = newRecordingURL()
        if fileOutput.isRecording {
            fileOutput.stopRecording()
            print("Stopped recording")
        } else {
            print("Started recording: \(url)")
            fileOutput.startRecording(to: url, recordingDelegate: self)
        }
    }
    
    private func setupCaptureSession() {
        let camera = bestCamera()
        captureSession.beginConfiguration()
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput) else {
                fatalError("Can't create camera with current input")
        }
        captureSession.addInput(cameraInput)
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(audioInput) else {
                fatalError("Can't create and add input from microphone")
        }
        captureSession.addInput(audioInput)
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("")
        }
        captureSession.addOutput(fileOutput)
        captureSession.commitConfiguration()
        cameraView.session = captureSession
    }
    
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }
    
    private func bestCamera() -> AVCaptureDevice {
        
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        fatalError("No Camera on device(or you're on the simulator and that isn't supported)")
    }
    
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
        if video == nil {
            playButton.isHidden = true
        } else {
            playButton.isHidden = false
        }
    }
    
    func playMovie(url: URL) {
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        var topRect = view.bounds
        topRect.size.height = topRect.height
        topRect.size.width = topRect.width
        topRect.origin.y = view.layoutMargins.top
        playerLayer.frame = topRect
        view.layer.addSublayer(playerLayer)
        player.play()
    }
    
    @objc func handleTapGestureRecognizer(_ tapGesture: UITapGestureRecognizer) {
        print("tap")
        switch(tapGesture.state) {
        case .ended:
            replayMovie()
        default:
            print("Handled other states: \(tapGesture.state)")
        }
    }
    
    func replayMovie() {
        guard let player = player else { return }
        player.seek(to: CMTime.zero)
        player.play()
    }
    
    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            requestPermission()
        case .restricted:
            fatalError("Inform the user they cannot use the camera, they need parental permission ... show some kind of UI message")
        case .denied:
            fatalError("Inform the user to enable camera/audio access in Settings > Privacy")
        case .authorized:
            self.cameraView.isHidden = false
        default:
            fatalError("Unexpected status for AVCaptureDevice authorization")
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            guard granted else {
                fatalError("Inform the user to enable camera/audio access in Settings > Privacy")
            }
            DispatchQueue.main.async {
                self.cameraView.isHidden = false
            }
        }
    }
}

extension VideoRecordingViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        updateViews()
        if let error = error {
            print("Error recording video to \(outputFileURL) \(error)")
            return
        }
        self.video = outputFileURL
        playMovie(url: outputFileURL)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
}

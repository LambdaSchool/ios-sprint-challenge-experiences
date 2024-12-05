//
//  VoiceRecordingViewController.swift
//  Experiences
//
//  Created by Enrique Gongora on 4/10/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit

class VoiceRecordingViewController: UIViewController {
    
    // MARK: - Properties
    var experience: Experience?
    lazy var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    var audio: URL?
    var player: AVPlayer!
    
    // MARK: - IBOutlets
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        if let experience = experience {
            experience.audio = audio
            let experienceDictionary = [mediaAdded : experience]
            NotificationCenter.default.post(name: .mediaAdded, object: nil, userInfo: experienceDictionary)
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        updateViews()
        toggleRecording()
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        replayAudio()
    }
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPermissionAndAllowRecording()
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        setupAudioCaptureSession()
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
    private func setupAudioCaptureSession() {
        captureSession.beginConfiguration()
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
    
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
        if fileOutput.isRecording {
            recordButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        } else {
            recordButton.setImage(UIImage(systemName: "mic"), for: .normal)
        }
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
    
    func playAudio(url: URL) {
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
    
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    @objc func handleTapGestureRecognizer(_ tapGesture: UITapGestureRecognizer) {
        print("tap")
        switch(tapGesture.state) {
        case .ended:
            replayAudio()
        default:
            print("Handled other states: \(tapGesture.state)")
        }
    }
    
    func replayAudio() {
        guard let player = player else { return }
        player.seek(to: CMTime.zero)
        player.play()
    }
    
    private func requestPermissionAndAllowRecording() {
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

// MARK: - Extensions
extension VoiceRecordingViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        updateViews()
        if let error = error {
            print("Error recording video to \(outputFileURL) \(error)")
            return
        }
        self.audio = outputFileURL
        playAudio(url: outputFileURL)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
}

//
//  VideoViewController.swift
//  Experiences
//
//  Created by Tobi Kuyoro on 08/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit
import AVFoundation

protocol PassVideoDelegate {
    func videoURL(_ url: URL)
}

class VideoViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var videoPlayerView: VideoPlayerView!

    // MARK: - Properties

    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput  = AVCaptureMovieFileOutput()

    var player: AVPlayer!
    var delegate: PassVideoDelegate?
    var experienceController: ExperienceController?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }

    // MARK: - IBActions

    @IBAction func recordButtonTapped(_ sender: Any) {
        toggleRecord()
    }

    // MARK: - Actions

    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }

    private func setUpCaptureSession() {
        captureSession.beginConfiguration()
        let camera = bestCamera()

        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput) else {
                fatalError("Error adding camera to capture session")
        }

        captureSession.addInput(cameraInput)

        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }

        guard let microphone = AVCaptureDevice.default(for: .audio),
            let audioInput = try? AVCaptureDeviceInput(device: microphone), captureSession.canAddInput(audioInput) else {
            fatalError("Can't create microphone input")
        }

        captureSession.addInput(audioInput)

        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Error: Cannot save video with capture session")
        }

        captureSession.addOutput(fileOutput)
        captureSession.commitConfiguration()
    }

    private func bestCamera() -> AVCaptureDevice {
        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera
        }

        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideAngleCamera
        }

        fatalError("No camera available. Are you on a simulator?")
    }

    private func toggleRecord() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }

    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        delegate?.videoURL(fileURL)
        return fileURL
    }

    private func playMovie(url: URL) {
        player = AVPlayer(url: url)
        videoPlayerView.player = player
        videoPlayerView.backgroundColor = .white
        player.play()
    }
}

extension VideoViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        } else {
            playMovie(url: outputFileURL)
        }

        updateViews()
    }

    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("Started recording: \(fileURL)")
        updateViews()
    }
}

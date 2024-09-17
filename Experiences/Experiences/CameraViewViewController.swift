//
//  CameraViewViewController.swift
//  Experiences
//
//  Created by Karen Rodriguez on 5/8/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewViewController: UIViewController {

    private var player: AVPlayer!
    private var videoURL: URL?
    var newExpController: NewExpViewController?

    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()

    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Resize camera preview to fill the entire screen
        requestPermissionAndShowCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }

    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }

    // Live Preview + inputs/outputs

    private func setUpCaptureSession() {
        // Add inputs
        captureSession.beginConfiguration()
        // Camera input
        let camera = bestCamera()

        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput) else {
                fatalError("Error adding camera to capture session")
        }
        captureSession.addInput(cameraInput)
        // Microphone input
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }

        // Add outputs
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Error: Cannot save movie")
        }
        captureSession.addOutput(fileOutput)

        captureSession.commitConfiguration()
        cameraView.session = captureSession

        // TODO: Start/Stop session

    }

    private func bestCamera() -> AVCaptureDevice {
        // Ultra-wide lens (iPhone 11 Pro + Pro Max on back)
        if let ultraWideCamera =  AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera
        }
        // Wide angle lens ( available on any iPhone - front/back)
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideAngleCamera
        }
        // No cameras present ( simulator )
        fatalError("No camera available - are you on a simmulator?")
    }

    // Recording

    @IBAction func recordButtonPressed(_ sender: Any) {
        toggleRecord()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        guard let url = videoURL else { return }
        do {
            try FileManager.default.removeItem(at: url)
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        } catch {
            NSLog("error deleting: \(error)")
        }
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let videoURL = videoURL else { return }
        newExpController?.videoURL = videoURL.path
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }

    private func toggleRecord() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
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

    private func playMovie(url: URL) {
        player = AVPlayer(url: url)

        let playerView = VideoPlayerView()
        playerView.player = player

        // top left corner (Fullscreen, you'd need a close button)
        var topRect = view.bounds
        topRect.size.height = topRect.size.height / 4
        topRect.size.width = topRect.size.width / 4 // create a constant for the "magic number"
        topRect.origin.y = view.layoutMargins.top
        playerView.frame = topRect
        view.addSubview(playerView) // FIXME: Don't add every time we play

        player.play()
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
    }

    // MARK: - Camera Permissions
    private func requestPermissionAndShowCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .notDetermined: // first time we've requested access
            requestPermission()
        case .restricted: // parental controls prevent user from using the camera / microphone
            fatalError("Tell user they need to request permission from parent (UI)")
        case .denied:
            fatalError("Tell user to enable in Settings: Popup from Audio to do this, or use a custom view")
        case .authorized:
            cameraView.videoPlayerView.videoGravity = .resizeAspectFill
            setUpCaptureSession()
            showCamera()
        default:
            fatalError("Handle new  case for authorization")
        }
    }

    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else {
                fatalError("Tell user to enable in Settings: Popup from Audio to do this, or use a custom view")
            }
            DispatchQueue.main.async {
                self.cameraView.videoPlayerView.videoGravity = .resizeAspectFill
                self.setUpCaptureSession()
                self.showCamera()
            }
        }
    }

    private func showCamera() {
        cameraView.isHidden = false
    }
}

extension CameraViewViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        } else {
            //save url
            self.videoURL = outputFileURL
            // show movie
            playMovie(url: outputFileURL)
        }
        updateViews()
    }
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("startedRecording: \(fileURL)")
        updateViews()
    }
}

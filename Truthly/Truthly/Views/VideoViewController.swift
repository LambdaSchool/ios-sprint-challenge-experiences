//
//  VideoViewController.swift
//  Truthly
//
//  Created by Ezra Black on 6/7/20.
//  Copyright © 2020 Casanova Studios. All rights reserved.
//

import UIKit
import AVFoundation

protocol VideoDelegate {
    func videoButtonTapped()
}

class VideoViewController: UIViewController, UITextFieldDelegate {
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    // MARK: - Properties
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    var player: AVPlayer?
    var postController: PostController?
    var delegate: VideoDelegate?

    // MARK: - IBOutlets
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var geotagSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraView.videoPlayerView.videoGravity = .resize

        postButton.isEnabled = false
        postButton.tintColor = UIColor.gray

        setupCamera()
        titleTextField.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }

    // MARK: - Methods
    func playRecording() {
        if let player = player {
            player.seek(to: .zero)
            player.play()
        }
    }

    func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }

    func toggleRecording() {
        if fileOutput.isRecording {
            // stop
            fileOutput.stopRecording()
        } else {
            // start
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }

    private func setupCamera() {
        let camera = bestCamera()

        captureSession.beginConfiguration()

        // make changes to the devices connected

        // Video input
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            fatalError("Cannot create camera input")
        }
        guard captureSession.canAddInput(cameraInput) else {
            fatalError("Cannot add camera input to session")
        }
        captureSession.addInput(cameraInput)

        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.canSetSessionPreset(.hd1920x1080)
        }

        // Audio input
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else {
            fatalError("Can't create input from microphone")
        }
        guard captureSession.canAddInput(audioInput) else {
            fatalError("Can't add audio input")
        }
        captureSession.addInput(audioInput)


        // Video output
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Can't setup the file output for the movie")
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

    /// WideAngle lends is on every iPhone thats been shipped through 2019
    private func bestCamera() -> AVCaptureDevice {
        // Fallback camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }

        fatalError("No cameras on the device. Or you are running on the Simulator (not supported)")
    }

    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }

    func playMovie(url: URL) {
        player = AVPlayer(url: url)

        //player?.actionAtItemEnd = .none
        let playerLayer = AVPlayerLayer(player: player)

        playerLayer.frame = cameraView.frame
        playerLayer.videoGravity = .resize
        view.layer.addSublayer(playerLayer)
        player?.play()
    }

    private func postVideo() {
        view.endEditing(true)

        guard let title = titleTextField.text,
            !title.isEmpty else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a caption before posting.")
                return
        }
        
        // TODO: IMPLEMENT LOCATION
        if geotagSwitch.isOn {
            LocationHelper.shared.getCurrentLocation { (coordinate) in
                self.postController?.createPost(with: title, ofType: .image, location: coordinate)
                self.delegate?.videoButtonTapped()
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            self.postController?.createPost(with: title, ofType: .image, location: nil)
            self.delegate?.videoButtonTapped()
            self.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - IBActions
    @IBAction func recordButtonPressed(_ sender: Any) {
        toggleRecording()
    }

    @IBAction func postButtonTapped(_ sender: Any) {
        postVideo()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension VideoViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        }
        updateViews()
        postButton.isEnabled = true
        postButton.tintColor = UIColor.link
        playMovie(url: outputFileURL)
    }

    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
}

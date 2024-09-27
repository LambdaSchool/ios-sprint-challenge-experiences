//
//  VideoPostViewController.swift
//  Experiences
//
//  Created by Ufuk Türközü on 10.04.20.
//  Copyright © 2020 Ufuk Türközü. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit

protocol VideoPostViewControllerDelegate {
    func videoURL(_ url: URL)
}

class VideoPostViewController: UIViewController {
    
    enum RecordingState {
        case preview
        case recording
        case readyToPost
    }
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var preview: CameraPreviewView!
    
    let postViewController = PostViewController()
    var delegate: VideoPostViewControllerDelegate!
    
    var recordingState: RecordingState = .preview {
        didSet {
            print(recordingState)
        }
    }
    
    var video: URL? {
        didSet {
            NSLog("Video: \(video)")
        }
    }
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    private var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        preview.videoPlayerView.videoGravity = .resizeAspectFill
        
        setUpCaptureSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession.startRunning()
        recordingState = .preview
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        captureSession.stopRunning()
    }
    
    private func updateViews() {
        
        switch recordingState {
        case .preview:
            postButton.isHidden = true
            cancelButton.isHidden = false
            recordButton.isHidden = false
            recordingTimeLabel.isHidden = true
        case .recording:
            postButton.isHidden = true
            cancelButton.isHidden = true
            recordButton.isHidden = false
            //recordButton.isSelected
            recordingTimeLabel.isHidden = false
        case .readyToPost:
            postButton.isHidden = false
            cancelButton.isHidden = false
            recordButton.isHidden = true
            //recordButton.isSelected
            recordingTimeLabel.isHidden = false
        }
        
        recordButton.isSelected = fileOutput.isRecording
    }
    
    private func setUpCaptureSession() {
        captureSession.beginConfiguration()
        // Add inouts
        let camera = bestCamera()
        // Video
        guard let captureInput = try? AVCaptureDeviceInput(device: camera), captureSession.canAddInput(captureInput) else {
            fatalError("Can't create the input from the camera")
        }
        captureSession.addInput(captureInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) { // FUTURE: Play with 4k
            captureSession.sessionPreset = .hd1920x1080
        }
        // Audio
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone), captureSession.canAddInput(audioInput) else {
            fatalError("Can't create microphone input")
        }
        captureSession.addInput(audioInput)
        // Add outputs
        // Recording to disk
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Can't record to disk")
        }
        
        captureSession.addOutput(fileOutput)
        captureSession.commitConfiguration()
        // Live preview
        preview.session = captureSession
    }
    
    private func bestCamera() -> AVCaptureDevice {
        // All iPhones have a wide angle camera (front + back)
        if let ultraWideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return ultraWideCamera
        }
        
        if let wideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideCamera
        }
        
        // Future add a button to toggle front/back camera
        
        fatalError("No cameras on the device (or you're running this on a Simulator which isn't supported)")
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }
    
    private func playMovie(url: URL) {
        player = AVPlayer(url: url)
        
        let playerLayer = AVPlayerLayer(player: player)
        // top left corner (Fullscreen, you'd need a close button)
        var topRect = view.bounds
                topRect.size.height = topRect.size.height / 2
                topRect.size.width = topRect.size.width / 2 // create a constant for the "magic number"
        topRect.origin.y = view.layoutMargins.top + 40
        
        playerLayer.frame = topRect
        view.layer.addSublayer(playerLayer)
        
        player.play()
    }
    
    private func replayMovie() {
        guard let player = player else { return }
        
        player.seek(to: CMTime.zero)
        player.play()
    }
    
    @IBAction func cancel(_ sender: Any) {
        switch recordingState {
        case .preview:
            self.dismiss(animated: true, completion: nil)
        case .recording:
            break
        case .readyToPost:
            self.recordingState = .preview
        }
    }
    
    @IBAction func post(_ sender: Any) {
        self.dismiss(animated: true)
        guard let video = video else { return }
        delegate.videoURL(video)
    }
    
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    @IBAction func record(_ sender: Any) {
        if fileOutput.isRecording {
            fileOutput.stopRecording() // FUTURE: Play with pausing using another button
            recordingState = .readyToPost
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
            recordingState = .recording
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension VideoPostViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("didFinishRecording")
        if let error = error {
            NSLog("Video Recording Error: \(error)")
        } else {
            playMovie(url: outputFileURL)
            video = outputFileURL
        }
        updateViews()
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Update UI
        print("didStartRecording")
        updateViews()
    }
}

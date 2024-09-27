//
//  CameraViewController.swift
//  Experiences
//
//  Created by Alex Shillingford on 5/23/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import UIKit
import SwiftUI
import AVKit

final class CameraViewController: UIViewController {
    
    var videoURL: URL?
    let cameraController = CameraController()
    var cameraView = CameraPreviewView()
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    private var player: AVPlayer!
    
    var recordButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.midX - 50, y: UIScreen.main.bounds.height - 200, width: 100, height: 100))
    var recordButtonNormalImage = UIImage(systemName: "largecircle.fill.circle")
    var recordButtonSelectedImage = UIImage(systemName: "stop.circle")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSubViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        captureSession.stopRunning()
    }
    
    func setUpSubViews() {
        view.translatesAutoresizingMaskIntoConstraints = false
        cameraView.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        cameraView.videoPlayerLayer.videoGravity = .resizeAspectFill
        setupCamera()
        view.addSubview(cameraView)
        
        recordButton.addTarget(self, action: #selector(recordButtonPressed), for: .touchUpInside)
        recordButton.imageView?.contentMode = .scaleAspectFill
        recordButton.imageEdgeInsets = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)
        recordButton.setImage(recordButtonNormalImage!, for: .normal)
        recordButton.setImage(recordButtonSelectedImage!, for: .selected)
        recordButton.tintColor = .red
        recordButton.backgroundColor = .clear
        view.addSubview(recordButton)
    }
    
    private func setupCamera() {
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
        captureSession.addInput(cameraInput)
        
        guard captureSession.canAddInput(microphoneInput) else {
            preconditionFailure("This session can't handle this type of input: \(microphoneInput)")
        }
        captureSession.addInput(microphoneInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        guard captureSession.canAddOutput(fileOutput) else {
            preconditionFailure("This session can't handle this type of output: \(fileOutput)")
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
        
        preconditionFailure("No cameras on device match the specs that we need")
    }
    
    private func bestMicrophone() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        
        preconditionFailure("No microphones on device match the specs that we need")
    }
    
    @objc func recordButtonPressed() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
            self.dismiss(animated: true, completion: nil)
        } else {
            let url = newRecordingURL()
            fileOutput.startRecording(to: url, recordingDelegate: self)
            CameraController.shared.videoURL = url
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
        //        playMovie(url: outputFileURL)
    }
}


extension CameraViewController : UIViewControllerRepresentable{
    public typealias UIViewControllerType = CameraViewController
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<CameraViewController>) -> CameraViewController {
        return CameraViewController()
    }
    
    public func updateUIViewController(_ uiViewController: CameraViewController, context: UIViewControllerRepresentableContext<CameraViewController>) {
    }
}

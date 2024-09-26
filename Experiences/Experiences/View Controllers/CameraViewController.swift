//
//  CameraViewController.swift
//  Experiences
//
//  Created by Lotanna Igwe-Odunze on 2/24/19.
//  Copyright © 2019 Sugabelly LLC. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    //Properties
    private var capturesession: AVCaptureSession!
    var recordOutput: AVCaptureMovieFileOutput!
    var videoURL: URL?
    var photoURL: URL?
    var titleText: String?
    var locCoords: CLLocationCoordinate2D?
    
    //Outlets
    @IBOutlet weak var camPreview: CameraPreviewView!
    
    @IBOutlet weak var recordButton: UIButton!
    
    //Actions
    @IBAction func recordButtonClicked(_ sender: Any) {
        if recordOutput.isRecording {
            recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self) }
    }
    
    
    //Overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        capturesession.startRunning()
    }
    
    override func viewDidLoad() {
        setupCapture()
    }
    
    //Stops the session when the camera view controller is not on screen because camera eats CPU power and battery life.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        capturesession.stopRunning()
    }
    
    
    //My Functions
    
    private func updateRecordButton() {
        //Make sure view is loaded first
        guard isViewLoaded else { return }
        
        //Switch between button image names
        let recordButtonImageName = recordOutput.isRecording ? "stop" : "record"
        
        //Change the image based on the current image name
        recordButton.setImage( UIImage(named: recordButtonImageName)!, for: .normal)
        //Force unwrap because we know the image is there since we dragged it into the project.
    }

    
    //Establish a camera
    private func myCamera() -> AVCaptureDevice {
        
    //This works on devices that have two cameras
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            
        return device

        } else {
    //This works for any other device with only one camera
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
        
        return device
            
        } else {
    
    //On devices with no camera, it can't work
        
        fatalError("Device doesn't have a camera") }
        }
    }
    
    
    //Actually Captures the video
    private func setupCapture() {
        
        //This holds all the pieces of the capture - the inputs and outputs
        let captureSession = AVCaptureSession()
        
        //The device I'm using to capture.
        let device = myCamera()
        
        //This handles pulling video in from the camera, and providing it to something else. So I take video from "device" above, and insert it into "captureSession" declared.
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device), captureSession.canAddInput(videoDeviceInput) else { fatalError() } //This part checks that the capture session CAN add the input otherwise it fails.
        
        //Any time you add an input or take output from a capture session, check if it's possible in case of an error.
        
        captureSession.addInput(videoDeviceInput) //Adds the input assuming the check above passes.
        
        //Controls the quality of the video coming in.
        captureSession.sessionPreset = .hd1920x1080
        
        //Prepare to receive video output
        let fileOutput = AVCaptureMovieFileOutput()
        
        //Check if adding output is possible
        guard captureSession.canAddOutput(fileOutput) else { fatalError() }
        
        //Add the output
        captureSession.addOutput(fileOutput)
        
        //Assign the output to the class property for use.
        recordOutput = fileOutput
        
        //Saves the above settings and readies them for use.
        captureSession.commitConfiguration()
        
        //Assign the capture session I've set up to the property declared below
        self.capturesession = captureSession
        
        //Set the capture session of the UIview classed CameraPreviewView to the capture session I've made.
        camPreview.videoPreviewLayer.session = captureSession
    }

    //Creates location to save video
    private func newRecordingURL() -> URL {
        //Invoke File Manager
        let fm = FileManager.default
        
        //Create location on user's disk to store video
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        //Store each video with unique ID and mov extension
        return documentsDir.appendingPathComponent( UUID().uuidString).appendingPathExtension("mov") //pull out the last path component.
        
        //let lastPathComponent = documentsDir.lastPathComponent //Save this to CoreData.
        
        //build video from this using AVPlayer documentsDir.appendingPathComponent(lastPathComponent)
        
        
    }
    
    //Delegate Methods
    //Called when recording begins
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
        DispatchQueue.main.async {
            self.updateRecordButton() }
        
    }
    
    //Called when recording ends.
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        videoURL = outputFileURL

        
        DispatchQueue.main.async {
            self.updateRecordButton()
        }
        
        performSegue(withIdentifier: "reviewVideo", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reviewVideo" {
            let reviewVC = segue.destination as! ReviewViewController
            
            reviewVC.previewVideo = videoURL!
            reviewVC.vidEntryTitle = titleText!
            reviewVC.vidEntryPhoto = photoURL
            reviewVC.vidEntryLocation = locCoords
            }
        }
}

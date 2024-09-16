//
//  AddViewController.swift
//  SC13-Experiences
//
//  Created by Andrew Dhan on 10/19/18.
//  Copyright © 2018 Andrew Liao. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import AVFoundation

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraViewControlDelegate, CLLocationManagerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationHelper.locationManager.delegate = self
        locationHelper.requestAuthorization()
        locationHelper.getCurrentLocation()
        audioResetButton.isHidden = true
        videoResetButton.isHidden = true
        saveButton.isEnabled    = false
        // Do any additional setup after loading the view.
    }

    //MARK: - IBActions
    
    @IBAction func save(_ sender: Any) {
        guard let title = titleLabel.text,
            let image = imageView.image,
            let location = location,
            let audioOutputURL = audioOutputURL,
            let videoOutputURL = videoOutputURL else{
                NSLog("Missing experience components")
                return
        }
        experienceController.create(with: title, audio: audioOutputURL, image: image, video: videoOutputURL, location: location)
        navigationController?.popViewController(animated: true)
        componentCount = 0
        saveButton.isEnabled = false
    }
    @IBAction func addImage(_ sender: Any) {
        choosePhoto()
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        let isRecording = recorder?.isRecording ?? false
        if isRecording{
            recorder?.stop()
            if let url = recorder?.url{
                audioOutputURL = url
                audioPlayer = try! AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            }
            
        } else {
            if let audioPlayer = audioPlayer{
                audioPlayer.stop()
            }
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!
            recorder = try! AVAudioRecorder(url: URL.newRecordingURL(mediaType: .audio), format: format)
            recorder?.record()
        }
        updateAudioView()
    }
    
    @IBAction func resetAudio(_ sender: Any) {
        audioOutputURL = nil
        audioResetButton.isHidden = true
        if componentCount > 0{
            componentCount -= 1
        }
    }
    @IBAction func resetVideo(_ sender: Any) {
        videoOutputURL = nil
        videoResetButton.isHidden = true
        if componentCount > 0{
            componentCount -= 1
        }
    }
    // MARK: - Methods for Image Features
    func choosePhoto(){
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            NSLog("The photo library is unavailable")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    func applyFilter(){
        guard let originalImage = originalImage,
            let cgImage = originalImage.cgImage  else {return}
        
        let ciImage = CIImage(cgImage: cgImage)
        imageFilter.setValue(ciImage, forKey: "inputImage")
        
        guard let outputCIimage = imageFilter.outputImage,
            let outputCGImage = context.createCGImage(outputCIimage, from: outputCIimage.extent) else {return}
        let finalOutput = UIImage(cgImage: outputCGImage)
        imageView.image = finalOutput
        componentCount += 1
        
    }

    //MARK: - UIImagePickerControllerDelegate Mehods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        originalImage = info[.originalImage] as? UIImage
        
    }
    
    
    //MARK: - Methods Audio Recording
    
    private func updateAudioView(){
        guard let isRecording = recorder?.isRecording else {return}
        let title = !isRecording ? "Record Audio" : "Recording..."
        recordAudioButton.setTitle(title, for: .normal)
    }
    
    //MARK: - CamerViewControllerDelegate Method
    func didFinishRecording(atURL url: URL) {
        videoOutputURL = url
    }
    //MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            NSLog("Empty location array")
            return
        }
        self.location = location.coordinate
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Error getting location: \(error)")
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordVideo"{
            let destinationVC = segue.destination as! CameraViewController
            destinationVC.delegate = self
        }
    }
    //MARK: - Properties
    var experienceController = ExperienceController.shared
    private let  locationHelper = LocationHelper()
    //MARK: -Image Adding Properties
    private var originalImage: UIImage?{
        didSet{
            applyFilter()
        }
    }
    private let imageFilter = CIFilter(name: "CIPhotoEffectFade")!
    private let context = CIContext(options: nil)
    
    //MARK: - Save Monitoring
    private var componentCount = 0{
        didSet{
            guard let text = titleLabel.text else {return}
            if componentCount == 3 && !text.isEmpty {
                saveButton.isEnabled = true
            } else {
                saveButton.isEnabled = false
            }
        }
    }
    
    
    //MARK: - Audio Adding
    private var recorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var audioOutputURL: URL?{
        didSet{
            audioResetButton.isHidden = false
            if oldValue == nil{
            componentCount += 1
            }
        }
    }
    
    //MARK: - Video Adding
    private var videoOutputURL: URL?{
        didSet{
            videoResetButton.isHidden = false
            if oldValue == nil {
            componentCount += 1
            }
        }
    }
    
    //MARK: - Location Adding
    private var location: CLLocationCoordinate2D?
    
    //MARK: - IBOutlets
    @IBOutlet weak var audioResetButton: UIButton!
    @IBOutlet weak var videoResetButton: UIButton!
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recordVideoButton: UIButton!
    @IBOutlet weak var recordAudioButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
}

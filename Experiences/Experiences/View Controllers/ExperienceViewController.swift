//
//  ExperienceViewController.swift
//  Experiences
//
//  Created by Thomas Cacciatore on 7/12/19.
//  Copyright © 2019 Thomas Cacciatore. All rights reserved.
//

import UIKit
import Photos
import CoreLocation

class ExperienceViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var experienceController = ExperienceController()
    
    var originalImage: UIImage? {
        didSet {
            updateImage()
        }
    }
    lazy private var recorder = Recorder()
    private let filter = CIFilter(name: "CIPhotoEffectMono")
    private let context = CIContext(options: nil)
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                print(location.coordinate)
            }
        }
        recorder.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    private func updateViews() {
        recordButton.setTitle(recorder.isRecording ? "Stop" : "Record", for: .normal)
    }
    
    func updateImage() {
        if let originalImage = originalImage {
            imageView.image = image(byFiltering: originalImage)
        } else {
            imageView.image = nil
        }
    }
    
    private func image(byFiltering image: UIImage) -> UIImage {
     
        guard let cgImage = image.cgImage else { return image }
        
        let ciImage = CIImage(cgImage: cgImage)
       
        filter?.setValue(ciImage, forKey: "inputImage")
        
        guard let outputCIImage = filter?.outputImage else { return image }
      
        guard let outputCGImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else { return image }
        experienceController.createExperience(title: titleTextField.text ?? "New Experience", image: UIImage(cgImage: outputCGImage), location: locationManager.location!.coordinate)
        return UIImage(cgImage: outputCGImage)
        
    }
 
    @IBAction func textFieldEnter(_ sender: Any) {
        print("title: \(titleTextField.text)")
    }
    

    @IBAction func choosePhotoButtonTapped(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { NSLog("The photo library is not available.")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        recorder.toggleRecording()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CameraSegue" {
            guard let destinationVC = segue.destination as? CameraViewController else { return }
            destinationVC.experienceController = experienceController
            
        }
    }
    
    

}

extension ExperienceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension ExperienceViewController: RecorderDelegate {
    func recorderDidChangeState(recorder: Recorder) {
        updateViews()
    }
}

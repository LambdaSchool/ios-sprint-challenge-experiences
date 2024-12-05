//
//  AddImageViewController.swift
//  Experiences
//
//  Created by Enrique Gongora on 4/10/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins
import MapKit

class AddImageViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: ExperienceMediaDelegate?
    let context = CIContext(options: nil)
    var imageData: Data?
    var experience: Experience?
    var image: UIImage?
    var scaledImage: UIImage?
    var originalImage: UIImage? {
        didSet {
            imageView.image = originalImage?.flattened
            guard let originalImage = originalImage else { return }
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    // MARK: - IBActions
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterSlider: UISlider!
    @IBOutlet weak var savePhotoButton: UIBarButtonItem!
    
    // MARK: - IBActions
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        updateImage()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        let image = imageView.image
        self.experience?.image = image
        let experienceDictionary = [mediaAdded : experience] as! [String : Experience]
        NotificationCenter.default.post(name: .mediaAdded, object: nil, userInfo: experienceDictionary)
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuthorizationStatus()
        updateViews()
    }
    
    // MARK: - Functions
    func checkAuthorizationStatus() {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                self.presentImagePickerController()
            }
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
        @unknown default:
            self.presentInformationalAlertController(title: "Error", message: "Future Unknown Authorization Status")
        }
        presentImagePickerController()
    }
    
    func updateViews() {
        guard let imageData = imageData, let image = UIImage(data: imageData) else { return }
        imageView.image = image
    }
    
    func updateImage() {
        if let scaledImage = scaledImage {
            imageView.image = filterImage(scaledImage)
        } else {
            imageView.image = nil
        }
    }
    
    func filterImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        let filter = CIFilter.colorPosterize()
        filter.inputImage = ciImage
        filter.levels = filterSlider.value
        guard let outputCIImage = filter.outputImage else { return nil }
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }
    
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
}

extension AddImageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { return }
        imageView.image = image
        originalImage = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

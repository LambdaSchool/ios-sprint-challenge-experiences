//
//  ImagePostViewController.swift
//  Experiences
//
//  Created by Jessie Ann Griffin on 5/15/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//


import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {

    var experienceController: ExperienceController?
    var delegate: AddExperienceDelegate?

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    
    // MARK: - Properties
    private let context = CIContext()
    private let noirFilter = CIFilter.photoEffectNoir()
    
    var isFiltering: Bool = false
    
    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale: CGFloat = UIScreen.main.scale
            
            scaledSize = CGSize(width: scaledSize.width*scale,
                                height: scaledSize.height*scale)
            
            guard let scaledUIImage = originalImage.imageByScaling(toSize: scaledSize) else { return }
            
            scaledImage = CIImage(image: scaledUIImage)
        }
    }

    var scaledImage: CIImage? {
        didSet {
            applyFilter()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presentImagePickerController()
        
        originalImage = imageView.image
    }

    private func image(byFiltering inputImage: CIImage) -> UIImage {
        
        noirFilter.inputImage = inputImage
        
        guard let outputImage = noirFilter.outputImage else { return originalImage! }
        
        guard let renderedImage = context.createCGImage(outputImage, from: inputImage.extent) else { return originalImage! }
        
        return UIImage(cgImage: renderedImage)
    }

    private func applyFilter() {
        if let scaledImage = scaledImage {
            imageView.image = image(byFiltering: scaledImage)
        } else {
            imageView.image = nil
        }
    }

    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("The photo library is not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Actions
    
//    @IBAction func selectPhotoButtonPressed(_ sender: UIBarButtonItem) {
//        presentImagePickerController()
//
//      if selectImageButton.title == "Select Image" {
//            selectImageButton.title = "Save Photo"
//        } else {
//            guard let originalImage = originalImage?.flattened, let ciImage = CIImage(image: originalImage) else { return }
//
//            let processedImage = self.image(byFiltering: ciImage)
//
//            PHPhotoLibrary.requestAuthorization { status in
//                guard status == .authorized else { return }
//
//                PHPhotoLibrary.shared().performChanges({
//                    PHAssetChangeRequest.creationRequestForAsset(from: processedImage)
//                }) { (success, error) in
//                    if let error = error {
//                        print("Error saving photo: \(error)")
//                        // NSLog("%@", error)
//                        return
//                    }
//
//                    DispatchQueue.main.async {
//                        self.presentSuccessfulSaveAlert()
//                    }
//                }
//            }
//        }
//    }

    private func generateRandomLatitude() -> Double {
        return Double.random(in: -20...40)
    }
    
    private func generateRandomLongitude() -> Double {
        return Double.random(in: -90...80)
    }
    
    private func presentSuccessfulSaveAlert() {
        let alert = UIAlertController(title: "Photo Saved!", message: "The photo has been saved to your Photo Library!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveImage(_ sender: UIBarButtonItem) {
        
        guard let experienceTitle = captionTextField.text else { return }
        let experience = Experience(title: experienceTitle,
                                    geotag: CLLocationCoordinate2D(latitude: generateRandomLatitude(), longitude: generateRandomLongitude()),
                                    media: .image)
            
        delegate?.experienceWasCreated(experience)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage {
            originalImage = image
        } else if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

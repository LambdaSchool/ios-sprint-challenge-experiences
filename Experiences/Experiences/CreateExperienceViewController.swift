//
//  CreateExperienceViewController.swift
//  Experiences
//
//  Created by Tobi Kuyoro on 08/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos
import AVFoundation
import MapKit

class CreateExperienceViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!

    // MARK: - Properties

    let context = CIContext(options: nil)
    var experienceController: ExperienceController?

    var coordinates: CLLocationCoordinate2D?
    var image: UIImage?
    var audioURL: URL?
    var videoURL: URL?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions

    private func presentImagePickerController() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true

        let alert = UIAlertController(title: "Select Source", message: nil, preferredStyle: .actionSheet)

        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { action in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }

        let camera = UIAlertAction(title: "Camera", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                fatalError("No camera available. Are you on a simulator?")
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(photoLibrary)
        alert.addAction(camera)
        alert.addAction(cancel)

        self.present(alert, animated: true, completion: nil)
    }

    private func filterImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)

        let filter = CIFilter.sepiaTone()
        filter.inputImage = ciImage

        guard let outputCIImage = filter.outputImage,
            let outputCGImage = context.createCGImage(outputCIImage,
                                                      from: CGRect(origin: .zero, size: image.size)) else { return nil }
        return UIImage(cgImage: outputCGImage)
    }

    private func missingPropertiesAlert() {
        if image == nil && videoURL == nil && title == nil {
            let alert = UIAlertController(title: "Missing Image, Video and Title", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if image == nil {
            let alert = UIAlertController(title: "Missing Image", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if videoURL == nil {
            let alert = UIAlertController(title: "Missing Video", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else if title == nil {
            let alert = UIAlertController(title: "Missing Video", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Missing Required Properties", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - IBActions

    @IBAction func addImageTapped(_ sender: Any) {
        presentImagePickerController()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard
            let title = titleTextField.text, !title.isEmpty,
            let coordinates = coordinates,
            let image = image,
            let videoURL = videoURL else {
                missingPropertiesAlert()
                return
        }

        experienceController?.createExperience(called: title, at: coordinates, image: image, audioURL: nil, videoURL: videoURL)
        navigationController?.popViewController(animated: true)
    }

     // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VideoSegue" {
            if let videoVC = segue.destination as? VideoViewController {
                videoVC.delegate = self
                videoVC.experienceController = experienceController
            }
        }
     }
}

extension CreateExperienceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        let filteredImage = filterImage(image)
        self.image = filteredImage
        imageView.image = filteredImage
        imageButton.isHidden = true
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CreateExperienceViewController: PassVideoDelegate {
    func videoURL(_ url: URL) {
        self.videoURL = url
    }
}

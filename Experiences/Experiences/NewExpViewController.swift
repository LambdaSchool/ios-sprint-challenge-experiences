//
//  NewExpViewController.swift
//  Experiences
//
//  Created by Karen Rodriguez on 5/8/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

protocol MediaDelegate {
    func wasAdded()
}

class NewExpViewController: UIViewController {

    // MARK: - Properties
    var experienceController: ExperienceController!
    var videoURL: String?
    var imageData: Data?
    var audioURL: String?
    let context = CIContext(options: nil)

    var originalImage: UIImage? {
        didSet {
            guard let originalImage = originalImage else { return }


            photoButton.setTitle("", for: .normal)
            photoView.image = vignette(originalImage)
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var recordButton: UIButton! // Just in case lol

    override func viewDidLoad() {
        super.viewDidLoad()
        titleField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print(audioURL)
        print(videoURL)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VideoRecordShowSegue" {
            guard let destination = segue.destination as? CameraViewViewController else { fatalError("Programmer error") }
            destination.newExpController = self
        } else if segue.identifier == "AudioRecordShowSegue" {
            guard let destination = segue.destination as? AudioRecordViewController else { fatalError("Programmer error") }
            destination.newExpController = self
        }
    }

    // MARK: - Methods

    func vignette(_ image: UIImage) -> UIImage? {
        // MARK: - UIImage -> CGImage -> CIImage and back

        // UIImage -> CGImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)

        // filter image
        let filter = CIFilter.vignetteEffect()

        // Set values
//        let size = photoView.bounds.size
        filter.inputImage = ciImage
        filter.intensity = 0.5
        filter.radius = 100
//        filter.center = CGPoint(x: size.width / 2, y: size.height / 2)

        // CI -> CG -> UI
        guard let outputCIImage = filter.outputImage else { return nil }

        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size )) else { return nil }

        return UIImage(cgImage: outputCGImage)
    }

    // MARK: - Actions
    @IBAction func addPhotoTapped(_ sender: Any) {
        presentImagePickerController()
    }
    @IBAction func recordButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Record", message: "What kind of recording would you like to add:", preferredStyle: .actionSheet)

        let videoExpAction = UIAlertAction(title: "Video", style: .default) { (_) in
            self.performSegue(withIdentifier: "VideoRecordShowSegue", sender: self)
        }

        let audioExpAction = UIAlertAction(title: "Audio", style: .default) { (_) in
            self.performSegue(withIdentifier: "AudioRecordShowSegue", sender: self)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(videoExpAction)
        alert.addAction(audioExpAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        // I'd usually make locationManager private and only control it through built methods but... time
        experienceController.locationManager.requestLocation()
        guard let title = titleField.text,
            let geoTag = experienceController.locationManager.location?.coordinate else {
                NSLog("Something missing fam")
                return
        }
        let content = "Placeholder descriptions for now."

        experienceController.createExperience(title: title, content: content, videoURL: videoURL, imageData: imageData, audioURL: audioURL, geoTag: geoTag)
        navigationController?.popViewController(animated: true)
    }

}

extension NewExpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func presentImagePickerController() {

        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            NSLog("Error: The photo library is not available")
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self

        present(imagePicker, animated: true, completion: nil)
    }

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

extension NewExpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

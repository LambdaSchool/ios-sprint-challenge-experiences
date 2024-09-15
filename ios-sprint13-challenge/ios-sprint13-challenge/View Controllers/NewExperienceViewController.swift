//
//  NewExperienceViewController.swift
//  ios-sprint13-challenge
//
//  Created by Conner on 10/19/18.
//  Copyright © 2018 Conner. All rights reserved.
//

import UIKit
import Photos

class NewExperienceViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var choosePhotoButton: UIButton!
    @IBOutlet var recordAudioButton: UIButton!

    private var recorder: AVAudioRecorder?
    var experienceController: ExperienceController?
    var coordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func updateViews() {
        guard isViewLoaded else { return }

        let isRecording = recorder?.isRecording ?? false
        let recordButtonTitle = isRecording ? "Stop recording..." : "Record Audio"
        recordAudioButton.setTitle(recordButtonTitle, for: .normal)
    }

    @IBAction func recordAudioTapped(_ sender: Any) {
        let isRecording = recorder?.isRecording ?? false
        if isRecording {
            endRecording()
        } else {
            beginRecording()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "VideoRecordSegue" {
            guard let url = recorder?.url,
                let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
                let coordinate = self.coordinate else { return }

            if let vc = segue.destination as? CameraViewController {
                vc.audioURL = url
                vc.imageData = imageData
                vc.experienceTitle = titleTextField.text
                vc.experienceController = experienceController
                vc.coordinate = coordinate
            }
        }
    }
}

// MARK: - Adding Photo
extension NewExperienceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        choosePhotoButton.setTitle("", for: [])
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }

        imageView?.image = image
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    private func presentInformationalAlertController(title: String?, message: String?, dismissActionCompletion: ((UIAlertAction) -> Void)? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: dismissActionCompletion)

        alertController.addAction(dismissAction)

        present(alertController, animated: true, completion: completion)
    }

    private func presentImagePickerController() {

        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func choosePhoto(_ sender: Any) {
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

        }
        presentImagePickerController()
    }
}

// MARK: - Adding Audio Recording
extension NewExperienceViewController {
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
    }

    private func beginRecording() {
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)!
            recorder = try AVAudioRecorder(url: newRecordingURL(), format: format)
            recorder?.record()
            updateViews()
        } catch {
            NSLog("Error beginning the recording...")
        }
    }

    private func endRecording() {
        recorder?.stop()
        updateViews()
    }
}

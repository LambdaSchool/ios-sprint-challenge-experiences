//
//  PostViewController.swift
//  experiences
//
//  Created by Hector Steven on 7/12/19.
//  Copyright © 2019 Hector Steven. All rights reserved.
//

import UIKit
import MapKit


class PostViewController: UIViewController {
	var postLocation: CLLocationCoordinate2D?
	var experienceController: ExperienceController?
	
	@IBOutlet var recordButton: UIButton!
	@IBOutlet var titleTextField: UITextField!
	@IBOutlet var imageView: UIImageView!
	
	var currentImage: UIImage? {
		didSet {
			print("Prepare for record")
			prepareForRecord()
		}
	}
	
	func prepareForRecord() {
		imageView.image = currentImage!
		recordButton.backgroundColor = .red
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(back))
		
		
	}
	
	
	
	@objc func back() {
		dismiss(animated: true, completion: nil)
	}
	
	@IBAction func addPosterButtonPressed(_ sender: Any) {
		guard let title = titleTextField.text, !title.isEmpty else {
			NSLog("title is empty")
			return
		}
		
		addPhotoRequest()
	}
	
	@IBAction func recordButtonPressed(_ sender: Any) {
		print("recordButtonPressed")
	}
	
	func addPhotoRequest() {
		imageView.image = nil
		
		guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
			fatalError("AddPhoto error")
		}
		
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .photoLibrary
		
		imagePicker.delegate = self
		present(imagePicker, animated: true)
	}
}

extension PostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		picker.dismiss(animated: true) {
			if let image = info[.originalImage] as? UIImage {
				self.currentImage = image.myCIColorControlsFilter()
			}
		}
	}
}

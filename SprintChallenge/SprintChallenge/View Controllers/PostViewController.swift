//
//  PostViewController.swift
//  SprintChallenge
//
//  Created by Elizabeth Wingate on 4/10/20.
//  Copyright © 2020 Lambda. All rights reserved.
//

import UIKit
import MapKit

class DetailView: UIView {
    var experience: Experience?
}

class PostViewController: UIViewController {
    var experiencesController: ExperiencesController?
    
     var postLocation: CLLocationCoordinate2D?
    
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var recordButton: UIButton!
    
     override func viewDidLoad() {
        super.viewDidLoad()
        recordButton.isEnabled = false
        
    }
    
    var currentImage: UIImage? {
        didSet {
            print("Prepare for record")
            prepareForRecord()
        }
    }
    
    func prepareForRecord() {
        imageView.image = currentImage!
        recordButton.isEnabled = true
        recordButton.backgroundColor = .red
    }
    
    @IBAction func addImageButtonPressed(_ sender: Any) {
      guard let title = titleTextField.text, !title.isEmpty else {
            NSLog("title is empty")
            return
        }
        addPhotoRequest()
}

     @IBAction func recordButtonPressed(_ sender: Any) {
         guard currentImage != nil else {
             NSLog("currentImage is empty")
             return
         }
         print("recordButtonPressed")
     }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CameraViewController" {
            guard let vc = segue.destination as? CameraViewController,
                let fileTitle = titleTextField.text, !fileTitle.isEmpty else {
                NSLog("title is empty")
                return
            }
            
            vc.fileTitle = fileTitle
            vc.experiencesController = experiencesController
        }
    }
}

extension PostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       picker.dismiss(animated: true)
   }

   func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       picker.dismiss(animated: true) {
           if let image = info[.originalImage] as? UIImage {
            self.currentImage = image.myCIColorControlsFilter(image: image)
           }
       }
   }
}

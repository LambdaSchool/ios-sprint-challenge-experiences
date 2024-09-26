//
//  EntryViewController.swift
//  Experiences
//
//  Created by Lotanna Igwe-Odunze on 2/22/19.
//  Copyright © 2019 Sugabelly LLC. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit

class EntryViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //Properties
    let mediaPicker = UIImagePickerController()
    var postPhoto: URL?
    var postTitle: String?
    var postLocation: CLLocationCoordinate2D?
    private let cdc = CoreDataController.shared
    
    //Get authorisation to record video
    let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    
    //What to do for each authorisation option
   
    
    
    //Overrides
    override func viewDidLoad() {
        mediaPicker.delegate = self }
    
    //Outlets
    @IBOutlet weak var entryImage: UIImageView!
    
    @IBOutlet weak var chooseButton: UIButton!
    
    @IBOutlet weak var titleField: UITextField!
    
    //Actions
    @IBAction func choosePhoto(_ sender: UIButton) {
        mediaPicker.sourceType = .photoLibrary //Set the photo library as the source
        mediaPicker.allowsEditing = false //Don't allow photo editing.
        
        //Show the Photo Library so the user can pick a photo
        present(mediaPicker, animated: true, completion: nil) }
    
    @IBAction func launchCameraClicked(_ sender: UIButton) {
        switch cameraAuthorizationStatus {
        case .notDetermined:                                                 AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if !granted { fatalError("Didn’t get access") }
            self.showCamera() //Otherwise show camera
            }
        case .authorized:
            showCamera()
            break
        case .denied: fallthrough //Move to next case
        case .restricted: //User can’t grant permission because of parental control
            fatalError("Didn’t get access")
        }
    }
    
    //Display the Camera
    func showCamera() { performSegue(withIdentifier: "recordSegue", sender: nil) }
    
    //MARK: - Delegate Functions.
    //After choosing the photo.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //What happens once the user has selected an image.
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] {
            entryImage.image = selectedImage as? UIImage //Assign to entry image
            
            postPhoto = info[UIImagePickerController.InfoKey.imageURL] as! URL
        }
        
        dismiss(animated: true, completion: nil) //Dismiss the picker
    }
    
    //Saving the Entry
    @IBAction func saveEntry(_ sender: UIBarButtonItem) {
        
        if ((titleField?.text) != nil) && entryImage.image != nil { //Add or video
           
        let currentDate = Date()
            
            cdc.newEntry(entryTitle: titleField.text!, entryPhoto: postPhoto!, entryVid: nil, entryDate: currentDate, entryLocation: postLocation)
            
            print(postPhoto?.absoluteString)
            print(postLocation)
            
        performSegue(withIdentifier: "saveImgEntry", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "recordSegue" {
            let vidVC = segue.destination as! CameraViewController
            
        vidVC.titleText = titleField.text!
        vidVC.photoURL = postPhoto
        vidVC.locCoords = postLocation
        }
    }
}

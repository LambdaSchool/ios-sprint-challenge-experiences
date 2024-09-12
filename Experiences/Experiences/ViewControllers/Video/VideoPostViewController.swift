//
//  VideoPostViewController.swift
//  Experiences
//
//  Created by Jessie Ann Griffin on 5/15/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.


import UIKit
import AVFoundation
import MapKit

class VideoPostViewController: UIViewController {
    
    var experienceController: ExperienceController?
    var delegate: AddExperienceDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestPermissionAndShowCamera()
    }

    private func requestPermissionAndShowCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            requestVideoPermission()
       
        case .restricted:
            // parental controls for example are preventing recording
            preconditionFailure("Video is disabled, please review device restrictions.")
       
        case .denied:
            preconditionFailure("Tell the user they can't use the app without giving permissions via Settings > Privacy > Video.")
        
        case .authorized:
            showCamera()
        @unknown default:
            preconditionFailure("A new stsus code was added that we need to handle")
        }
    }
    
    private func requestVideoPermission() {
        AVCaptureDevice.requestAccess(for: .video) { isGranted in
            guard isGranted else {
                preconditionFailure("UI: Tell user to enable permissions for Video/Camera.")
            }
            
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    
    private func showCamera() {
        performSegue(withIdentifier: "ShowCamera", sender: self)
    }
    
    private func generateRandomLatitude() -> Double {
        return Double.random(in: -90...90)
    }
    
    private func generateRandomLongitude() -> Double {
        return Double.random(in: -180...180)
    }
    
    @IBAction func saveVideo(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: "Add a Title or Caption",
                                      message: "Describe your experience!",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField { textField in
            textField.placeholder = "Title:"
        }
        
        alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { action in
            if let experienceTitle = alert.textFields?.first?.text {
                let experience = Experience(title: experienceTitle,
                                            geotag: CLLocationCoordinate2D(latitude: self.generateRandomLatitude(),
                                                                           longitude: self.generateRandomLongitude()),
                                            media: .image)
                
                self.delegate?.experienceWasCreated(experience)
                self.dismiss(animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

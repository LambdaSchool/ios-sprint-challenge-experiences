//
//  MapViewController.swift
//  SprintChallenge
//
//  Created by Elizabeth Wingate on 4/10/20.
//  Copyright © 2020 Lambda. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation

class MapViewController: UIViewController {
   let experiencesController = ExperiencesController()
    let locationManager = CLLocationManager()
    
    var experiences: [Experience] = []
    
    @IBOutlet var mapview: MKMapView!
    @IBOutlet var postButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      // Do any additional setup after loading the view.
        requestLocationAccess()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapview.reloadInputViews()
        mapview.delegate = self
        mapview?.addAnnotations(experiencesController.experinces)
        mapview.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "ExperienceAnotationView")
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        //print("Post Button was pressed.")
        print((locationManager.location?.coordinate)!)
    }
    
    func requestLocationAccess() {
         let status = CLLocationManager.authorizationStatus()

         switch status {
         case .authorizedAlways, .authorizedWhenInUse:
             return
         case .denied, .restricted:
             print("location access denied")
         default:
             locationManager.requestWhenInUseAuthorization()
         }
     }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PostViewController" {
            guard let vc = segue.destination as? PostViewController else { return }
            experiencesController.currentLocation = locationManager.location?.coordinate
            vc.experiencesController = experiencesController
        }
    }
}

extension MapViewController: MKMapViewDelegate {
   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       if annotation is MKUserLocation { return nil }

       return nil
   }
}

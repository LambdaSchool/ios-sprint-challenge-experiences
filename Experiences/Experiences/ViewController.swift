//
//  ViewController.swift
//  Experiences
//
//  Created by Alex Shillingford on 2/14/20.
//  Copyright © 2020 shillwil. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    static var shared = ViewController()
    
    var userLoc = CLLocation(latitude: 37.785834, longitude: -122.406417)
    
    var experiences = AddMediaPostViewController.experiences {
        didSet {
            for experience in experiences {
                let newAnnotation = MKPointAnnotation()
                newAnnotation.title = experience.title
                newAnnotation.coordinate = experience.coordinate
                mapView.addAnnotation(newAnnotation)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for experience in experiences {
            let newAnnotation = MKPointAnnotation()
            newAnnotation.title = experience.title
            newAnnotation.coordinate = experience.coordinate
            DispatchQueue.main.async {
                self.mapView.addAnnotation(newAnnotation)
            }
            
        }
    }


}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let entry = annotation as? ExperienceEntry else {
            fatalError("Only quake objects are supported right now")
        }
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "QuakeView") as? MKMarkerAnnotationView else {
            fatalError("Missing a registered annotationView")
        }
        
        annotationView.glyphImage = UIImage(named: "place-marker")
        
        annotationView.canShowCallout = true
        let detailView = EntryView()
        detailView.entry = entry
        annotationView.detailCalloutAccessoryView = detailView
        
        return annotationView
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locationValue: CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locationValue.latitude) \(locationValue.longitude)")
        let userLocation = locations.last
//        userLoc = locations.last
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let viewRegion = MKCoordinateRegion(center: userLocation!.coordinate, span: span)
        self.mapView.setRegion(viewRegion, animated: true)
    }
    
}

extension ViewController: ViewButtonTapped {
    func viewButtonWasTapped(sender: Any?) {
        performSegue(withIdentifier: "EntrySegue", sender: sender)
    }
    
    
}

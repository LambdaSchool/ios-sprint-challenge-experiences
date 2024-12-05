//
//  MapKitViewController.swift
//  Experiences
//
//  Created by Enrique Gongora on 4/10/20.
//  Copyright © 2020 Enrique Gongora. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapKitViewController: UIViewController {
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    var coordinate = CLLocationCoordinate2D()
    let regionRadius: CLLocationDistance = 4000
    var experiences: [Experience] = [Experience(title: "Winds Howling", image: UIImage(named: "Geralt"), video: nil, audio: nil, coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437))]
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var getLocationButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func addExperienceButtonTapped(_ sender: Any) {
        checkLocationAuthorizationStatus()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        if let coords = mapView.userLocation.location?.coordinate {
            self.coordinate = coords
            let initialLocation = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
            centerMapOnLocation(location: initialLocation)
        }
        self.performSegue(withIdentifier: "AddExperienceSegue", sender: self)
    }
    
    @IBAction func getLocationButtonTapped(_ sender: UIButton) {
        checkLocationAuthorizationStatus()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        if let coords = mapView.userLocation.location?.coordinate {
            let initialLocation = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
            centerMapOnLocation(location: initialLocation)
        }
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Experience")
        NotificationCenter.default.addObserver(forName: .saveTapped, object: nil, queue: nil) { (catchNotification) in
            let exp = catchNotification.userInfo?[experienceSaved]
            if let savedExperience = exp as? Experience {
                self.experiences.append(savedExperience)
                self.mapView.addAnnotation(savedExperience)
            }
        }
        self.mapView.addAnnotations(self.experiences)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        if let coords = mapView.userLocation.location?.coordinate {
            self.coordinate = coords
            let initialLocation = CLLocation(latitude: coords.latitude, longitude: coords.longitude)
            centerMapOnLocation(location: initialLocation)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Functions
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            if let coords = mapView.userLocation.location?.coordinate {
                mapView.setCenter(coords, animated: true)
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @objc func addLitExperience(_ notification: Notification) {
        let experience = notification.userInfo?["experience"]
        experiences.append(experience as! Experience)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddExperienceSegue" {
            guard let newExperienceVC = segue.destination as? NewExperienceViewController else { return }
            newExperienceVC.coordinate = coordinate
        }
    }
}

// MARK: - Extensions
extension MapKitViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let experience = annotation as? Experience
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Experience", for: annotation) as? MKMarkerAnnotationView else {
            fatalError("Missing a registered map annotation view")
        }
        annotationView.glyphImage = UIImage(systemName: "flame")
        annotationView.glyphTintColor = UIColor.orange
        annotationView.canShowCallout = true
        let detailView = ExperienceDetailView()
        detailView.experience = experience
        annotationView.detailCalloutAccessoryView = detailView
        return annotationView
    }
}

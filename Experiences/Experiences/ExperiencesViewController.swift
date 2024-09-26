//
//  ExperiencesViewController.swift
//  Experiences
//
//  Created by Tobi Kuyoro on 08/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit
import MapKit

class ExperiencesViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Properties

    let experienceController = ExperienceController()
    let locationManager = CLLocationManager()

    var currentCoordinate: CLLocationCoordinate2D?
    var annotations: [MKAnnotation] = []

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAnnotations()
    }

    // MARK: - Actions

    private func configureLocation() {
        locationManager.delegate = self

        let status = CLLocationManager.authorizationStatus()

        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(using: locationManager)
        }
    }

    private func beginLocationUpdates(using locationManager: CLLocationManager) {
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }

    private func addAnnotations() {
        let experiences = experienceController.experiences
        for experience in experiences {
            let annotation = MKPointAnnotation()
            annotation.title = experience.title
            annotation.coordinate = experience.coordinate
            annotations.append(annotation)
        }

        mapView.addAnnotations(annotations)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateExperienceSegue" {
            if let createExperienceVC = segue.destination as? CreateExperienceViewController {
                createExperienceVC.experienceController = experienceController
                createExperienceVC.coordinates = currentCoordinate
            }
        }
    }
}

extension ExperiencesViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(using: locationManager)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }

        if currentCoordinate == nil {
            zoomToLatestLocation(with: latestLocation.coordinate)
            addAnnotations()
        }

        currentCoordinate = latestLocation.coordinate
    }
}

extension ExperiencesViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "ExperienceView")

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "ExperienceView")
        }

        annotationView?.canShowCallout = true
        return annotationView
    }
}

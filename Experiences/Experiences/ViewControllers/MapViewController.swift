//
//  MapViewController.swift
//  Experiences
//
//  Created by Jessie Ann Griffin on 5/15/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

protocol AddExperienceDelegate {
    func experienceWasCreated(_ experience: Experience)
}

extension String {
    static let annotationReuseIdentifier = "ExperienceAnnotationView"
}

class MapViewController: UIViewController {

    let experienceController = ExperienceController()
    var listOfExperiences: [Experience] = [] {
        didSet {
            mapView.addAnnotations(listOfExperiences)
        }
    }
    
    private let locationManager = CLLocationManager()
    private var userTrackingButton: MKUserTrackingButton!

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userTrackingButton)
        
        NSLayoutConstraint.activate([
            userTrackingButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            mapView.bottomAnchor.constraint(equalTo: userTrackingButton.bottomAnchor, constant: 20)
        ])
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: .annotationReuseIdentifier)
    }
    
    @IBAction func addExperience(_ sender: UIBarButtonItem) {
        self.presentMediaOptionsAlertController()
    }
}

extension MapViewController: AddExperienceDelegate {
    func experienceWasCreated(_ experience: Experience) {
        self.listOfExperiences.append(experience)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let experience = annotation as? Experience else { return nil }
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: .annotationReuseIdentifier,
                                                                         for: experience) as? MKMarkerAnnotationView
            else {
            preconditionFailure("Missing annotation view")
        }
        
        annotationView.canShowCallout = true
        let detailView = ExperienceDetailView()
        detailView.experience = experience
        annotationView.detailCalloutAccessoryView = detailView
        
        return annotationView
    }
}

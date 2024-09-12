//
//  MapViewController.swift
//  Experiences
//
//  Created by Hayden Hastings on 7/12/19.
//  Copyright © 2019 Hayden Hastings. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: - IBOutlets Properties
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Properties
    let locationHelper = LocationHelper()
    var experienceController: ExperienceController?
    var experience: [Experience] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "ExperienceAnnotationView")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        zoomToUserLocation()
        addAnnotation()
    }
    
    // MARK: - Methods
    
    func addAnnotation() {
        let myPin = MKPointAnnotation()
        if let myCoordinate = experienceController?.newExperiences?.coordinate {
            myPin.coordinate = myCoordinate
        }
        if let annotationText = experienceController?.newExperiences?.postTitle {
            myPin.title = annotationText
        }
        mapView.addAnnotation(myPin)
    }
    
    func zoomToUserLocation() {
        if let location = locationHelper.currentLocation?.coordinate {
            let viewRegion = MKCoordinateRegion(center: location, latitudinalMeters: 11500, longitudinalMeters: 11500)
            mapView.setRegion(viewRegion, animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate Function
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let experience = annotation as? Experience else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "ExperienceAnnotationView", for: experience) as? MKMarkerAnnotationView
        
        annotationView?.glyphText = experience.postTitle
        annotationView?.glyphTintColor = .gray
        annotationView?.titleVisibility = .visible
        return annotationView
    }
}

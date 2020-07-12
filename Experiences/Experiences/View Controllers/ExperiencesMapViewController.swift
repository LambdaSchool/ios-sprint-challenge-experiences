//
//  ExperiencesMapViewController.swift
//  Experiences
//
//  Created by Cody Morley on 7/10/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

//TODO: Display experiences via dependency injection from home view controller.
//TODO: Stretch: Display detail bubble above map annotation.
class ExperiencesMapViewController: UIViewController {
    //MARK: - Properties -
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backButton: UIButton!
    
    var experiences: [Experience]?
    var locationManager: CLLocationManager?
    
    
    //MARK: - Life Cycles -
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let locationManager = locationManager else {
            fatalError("loacation manager instance not being passed to map view.")
        }
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
        mapView.delegate = self
        if let experiences = experiences {
            self.mapView.addAnnotations(experiences)
        }
    }
    

    //MARK: - Actions -
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension ExperiencesMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedWhenInUse:
            locationManager?.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            NSLog("Error with location manager: \(error)")
    }
}


extension ExperiencesMapViewController: MKMapViewDelegate {
    
    
}

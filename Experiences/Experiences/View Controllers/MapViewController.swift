//
//  MapViewController.swift
//  Experiences
//
//  Created by Lotanna Igwe-Odunze on 2/22/19.
//  Copyright © 2019 Sugabelly LLC. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //Properties
    private let cdc = CoreDataController.shared
    var thumbnail: UIImage?
    let locationManager = CLLocationManager()


    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Display the pins
        DispatchQueue.main.async {
            self.displayPins()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Requesting Location Permission
        locationManager.requestWhenInUseAuthorization()
        
       
    }
    
    func displayPins() {
        for x in cdc.entries {
        /*
        
             IMAGE BUILDING ISN'T WORKING BECAUSE DIRECTORY CHANGES ALL THE TIME.
             NEED TO SAVE ONLY THE STATIC PART OF THE URL, THEN BUILD IMAGE BY APPENDING THAT PART BACK ONTO DIRECTORY WITH EXTENSION.
        
        //Build Image URL
        guard let thumbURL = URL(string: x.picture!) else { return }
        //Build Image Data from URL
        guard let thumbData = try? Data(contentsOf: thumbURL) else {
            print("There was an error!")
            return }
        
        //Build Image from Image data
        thumbnail = UIImage(data: thumbData)
         
            */
            
        //Build location
        let entryCoord = CLLocationCoordinate2D(latitude: x.latitude, longitude: x.longitude)
            
        //Create Annotation
        let entryAnnotation = MKPointAnnotation()
        entryAnnotation.title = x.title
        entryAnnotation.coordinate = entryCoord
        
        //Add Annotation to the map
        //mapView.removeAnnotation(entryAnnotation)
        mapView.addAnnotation(entryAnnotation)
        }
        
    }
    
    //Display Pins on the Map
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation" //Create reuse id for annotation like cell
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            annotationView!.canShowCallout = true
            
            //Make photo appear in callout
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
            imageView.image = thumbnail
            let snapshotView = UIView()
            snapshotView.addSubview(imageView)
            
            annotationView?.detailCalloutAccessoryView = snapshotView
            
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    

    //Hand over the user's location to the entry VC for new entry
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "entrySeg" {
            let entryVC = segue.destination as! EntryViewController
            
            entryVC.postLocation = locationManager.location?.coordinate
            
            print(entryVC.postLocation)
        }
    }

}


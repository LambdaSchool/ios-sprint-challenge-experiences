//
//  VisitsTableViewController.swift
//  Road Trip
//
//  Created by Christy Hicks on 5/17/20.
//  Copyright © 2020 Knight Night. All rights reserved.
//

import UIKit
import MapKit

extension String {
    static let annotationReuseIdentifier = "VisitAnnotationView"
}

class VisitsTableViewController: UITableViewController, VisitDelegate {
    // MARK: - Properties
    var visits: [Visit] = []
    
    var visit: Visit? {
        guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
        let visit = visits[indexPath.row]
        return visit
    }
    
    // Map setup
    @IBOutlet var mapView: MKMapView!
    private var userTrackingButton = MKUserTrackingButton()
    private let locationManager = CLLocationManager()
    var newLocation: CLLocationCoordinate2D?
    
    func loadMap() {
        userTrackingButton = MKUserTrackingButton(mapView: mapView)
        userTrackingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userTrackingButton)
        
        NSLayoutConstraint.activate([
            userTrackingButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            mapView.bottomAnchor.constraint(equalTo: userTrackingButton.bottomAnchor, constant: 20)
        ])
    }
    
    func updateMap() {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: .annotationReuseIdentifier)
        let userLocationCoordinates = CLLocationCoordinate2DMake(locationManager.location?.coordinate.latitude ?? 0, locationManager.location?.coordinate.longitude ?? 0)
        newLocation = userLocationCoordinates
    }
    
    // MARK: - Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMap()
        tableView.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        updateViews()
    }
    
    func updateViews() {
        updateMap()
        tableView.reloadData()
    }
    
    // MARK: - Data Source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visits.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "visitCell", for: indexPath)
        
        let displayedVisit = visits[indexPath.row]
        cell.textLabel?.text = displayedVisit.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let visit = visits[indexPath.row]
            mapView.removeAnnotation(visit)
            
            visits.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }    
    }
    
    func saveNew(visit: Visit) {
        visits.append(visit)
        mapView.addAnnotation(visit)
        updateViews()
    }
    
    func update(visit: Visit, indexPath: IndexPath) {
        visits.remove(at: indexPath.row)
        visits.insert(visit, at: indexPath.row)
        updateViews()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateMap()
        
        if segue.identifier == "viewVisitSegue" {
            let visitVC = segue.destination as! VisitDetailViewController
            visitVC.visitDelegate = self
            visitVC.newLocation = newLocation
            
            visitVC.visit = self.visit
            visitVC.indexPath = tableView.indexPathForSelectedRow
            
            if visit?.videoRecordingURL != nil {
                visitVC.recordingExists = true
            } else {
                visitVC.recordingExists = false
            }
            
        } else if segue.identifier == "addVisitSegue" {
            let addVC = segue.destination as! VisitDetailViewController
            addVC.visitDelegate = self
            addVC.newLocation = newLocation
            addVC.recordingExists = false
        }
    }
}




//
//  MapViewController.swift
//  PlanYourTrip
//
//  Created by Abdelrahman Mohamed on 1/12/17.
//  Copyright © 2017 Abdelrahman Mohamed. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView:MKMapView!
    @IBOutlet var segmentedControl:UISegmentedControl!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    var fromAddressLocation: String = ""
    var toAddressLocation: String = ""
    
    var currentPlacemark:CLPlacemark?
    var currentTransportType = MKDirectionsTransportType.automobile
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl.isHidden = true
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
        
        getGeoCoder(address: fromAddressLocation)
        getGeoCoder(address: toAddressLocation)
    }
    
    // MARK: - getGeoCoder

    func getGeoCoder(address: String) {
        
        // Convert address to coordinate and annotate it on map
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            
            if error != nil {
                
                print(error!)
                return
            }
            
            if let placemarks = placemarks {
                
                // Get the first placemark
                let placemark = placemarks[0]
                self.currentPlacemark = placemark
                
                // Add annotation
                let annotation = MKPointAnnotation()
                annotation.title = "\(placemark.locality!), \(placemark.country!)"
                
                if let location = placemark.location {
                    
                    annotation.coordinate = location.coordinate
                    
                    // Display the annotation
                    self.mapView.showAnnotations([annotation], animated: true)
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let span: MKCoordinateSpan = MKCoordinateSpanMake(1, 1)
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
        
        let region: MKCoordinateRegion = MKCoordinateRegionMake(center, span)
        
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error: " + error.localizedDescription)
    }
    
    // MARK: - showDirection
    
    @IBAction func showDirection(_ sender: Any) {
        
        // Get the selected transport type
        switch segmentedControl.selectedSegmentIndex {
            case 0: currentTransportType = MKDirectionsTransportType.automobile
            case 1: currentTransportType = MKDirectionsTransportType.walking
            default: break
        }
        
        segmentedControl.isHidden = false
        
        guard currentPlacemark != nil else {
            return
        }
        
        let directionsRequest = MKDirectionsRequest()
        
        // Set the source and destination of the route
        directionsRequest.source = MKMapItem.forCurrentLocation()
        let destinationPlacemark = MKPlacemark(placemark: currentPlacemark!)
        directionsRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionsRequest.transportType = currentTransportType
        
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculate { (routeResponse, routeError) in
            
            guard routeResponse != nil else {
                
                if let routeError = routeError {
                    print("Error: \(routeError)")
                }
                
                return
            }
            
            let route = routeResponse?.routes.first
            let ETA = Int((route?.expectedTravelTime)!)
            let eTA = self.timeFormatted(totalSeconds: ETA)
//            print(eTA)
            self.timeLabel.isHidden = false
            self.distanceLabel.isHidden = false
            
            self.distanceLabel.text = "Distance: \(((route?.distance)! / 1000)) KM"
            self.timeLabel.text = "ETA: \(eTA)"
            
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.add((route?.polyline)!, level: MKOverlayLevel.aboveRoads)
            
            let rect = route?.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect!), animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = (currentTransportType == .automobile) ? UIColor.blue : UIColor.orange
        
        renderer.lineWidth = 3.0
        
        return renderer
    }
    
    // MARK: - timeFormatted
    
    func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

}




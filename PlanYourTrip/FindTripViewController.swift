//
//  FindTripViewController.swift
//  PlanYourTrip
//
//  Created by Abdelrahman Mohamed on 1/12/17.
//  Copyright © 2017 Abdelrahman Mohamed. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FindTripViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var fromLocationTextField: UITextField!
    @IBOutlet weak var toLocationTextField: UITextField!
    
    let locationManager = CLLocationManager()
    
    var lat: Double = 0.0
    var long: Double = 0.0
    
    var fromAddress: String?
    var toAddress: String = ""
    var myCurrentLocation: String?
    var flag: Bool? = false
    
    var showMap: MapViewController = MapViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        fromLocationTextField.delegate = self
        toLocationTextField.delegate = self
    }

    @IBAction func useCurrentLocationButton(_ sender: Any) {
        
        let latLocation = locationManager.location?.coordinate.latitude
        let longLocation = locationManager.location?.coordinate.longitude
        
        let location = CLLocation(latitude: latLocation!, longitude: longLocation!) //changed!!!
        print(location)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0 {
                let pm = (placemarks?[0])! as CLPlacemark
                print(pm.locality!)
                self.myCurrentLocation = pm.locality! + "," + pm.country!
                self.fromLocationTextField.text = self.myCurrentLocation
                self.flag = true
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    @IBAction func addLocation(_ sender: Any) {
        
        if flag == false {
            guard let fromLocation = fromLocationTextField.text, !fromLocation.isEmpty else {
                
                let alertController = UIAlertController(title: "My Location", message: "We can't proceed because My Location is blank. Please note that is required.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            fromAddress = fromLocation
            fromLocationTextField.resignFirstResponder()
        } else if flag == true {
            
            fromAddress = myCurrentLocation
//            fromLocationTextField.text = fromAddress
        } else {
            
            let alertController = UIAlertController(title: "Chosse Location", message: "Please Use Current Location or Fill My Location.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return

        }
    }
    
    @IBAction func goToLocationButton(_ sender: Any) {
        
        guard fromAddress != nil else {
            
            let alertController = UIAlertController(title: "My Location", message: "We can't proceed because My Location is blank. Please note that is required.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        guard let toLocation = toLocationTextField.text, !toLocation.isEmpty else {
            
            let alertController = UIAlertController(title: "Destination Location", message: "We can't proceed because Destination Location is blank. Please note that is required.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        toAddress = toLocation
        toLocationTextField.resignFirstResponder()
            
        performSegue(withIdentifier: "showMap", sender: self)
        self.showMap.fromAddressLocation = fromAddress!
        self.showMap.toAddressLocation = toAddress
    }
    
    // MARK: - PrepareForSegue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMap" {
            
            self.showMap = segue.destination as! MapViewController
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        fromLocationTextField.resignFirstResponder()
        toLocationTextField.resignFirstResponder()
        
        return false
    }
    
}

//
//  PostViewController.swift
//  OnTheMap
//
//  Created by Chris Archibald on 7/4/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController, UITextFieldDelegate {
    
    //Outlets for the find location view
    @IBOutlet weak var LocationTextField: UITextField!
    @IBOutlet weak var FindButton: UIButton!
    @IBOutlet weak var FirstView: UIView!
    
    @IBOutlet weak var SecondView: UIView!
    
     override func viewDidLoad() {
        super.viewDidLoad()
        LocationTextField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //If the cancel button is touched, go back to tab bar view
    @IBAction func cancleTouched(sender: AnyObject) {
         self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func FindTouched(sender: UIButton) {
        //First Step display the map view -- going to skip this for now and
        //Just see if the method is working
        
        let address = LocationTextField.text
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: { results, error in
            
            if let error = error {
                println("Something bad happened in finding location")
            } else {
                if let placemarks = results as? [CLPlacemark] {
                    
                    // Get the last location in the placemarks array
                    let placemark = (placemarks.last)!
                    let coordinate = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude)
                    
                    // Store the user coordinates
                    OTMClient.sharedInstance().loggedInUserInfo.latitude = placemark.location.coordinate.latitude
                    OTMClient.sharedInstance().loggedInUserInfo.longitude = placemark.location.coordinate.longitude
                    
                    // Create a annotation
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    
                    let deltaX = 0.01
                    let deltaY = 0.01
                    let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(deltaX, deltaY))
                    
                    // When the array is complete, we add the annotations to the map.
                    dispatch_async(dispatch_get_main_queue()) {
                        // Hide the first view
                        self.FirstView.hidden = true
                        
                        // Place the annotation on the map
                        //self.mapView.addAnnotation(annotation)
                        
                        // Zoom into the location
                        //self.mapView.setRegion(region, animated: true)
                    }
                }
            }
        })
    }
}


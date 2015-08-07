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
    @IBOutlet weak var LInkTextField: UITextField!
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var SubmitTouched: UIButton!
    @IBOutlet weak var Indicator: UIActivityIndicatorView!
    
     override func viewDidLoad() {
        super.viewDidLoad()
        LocationTextField.delegate = self
        LInkTextField.delegate = self
        self.Indicator.hidden = true
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
        //Check to see if there user put a Location or if it blank
        if LocationTextField.text.isEmpty {
            let alertController = UIAlertController(title: "", message: "A location is required", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.Indicator.startAnimating()
            self.Indicator.hidden = false
            let address = LocationTextField.text
            
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address, completionHandler: { results, error in
                
                if let error = error {
                    self.Indicator.hidden = true
                    let alertController = UIAlertController(title: "Location Not Found", message: "Please try again", preferredStyle: .Alert)
                    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    self.Indicator.hidden = true
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
                            self.MapView.addAnnotation(annotation)
                            
                            // Zoom into the location
                            self.MapView.setRegion(region, animated: true)
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func SubmitTouched(sender: UIButton) {
        
        // Check if shareLinkTextField is empty
        if LInkTextField.text.isEmpty {
            let alertController = UIAlertController(title: "", message: "Link is required", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        // Store the map string and media url
        OTMClient.sharedInstance().loggedInUserInfo.mapString = LocationTextField.text
        OTMClient.sharedInstance().loggedInUserInfo.mediaURL = LInkTextField.text
        
        // Check if the user has already posted a location
        if Students.sharedInstance().didStudentPreviouslyPost(OTMClient.sharedInstance().loggedInUserInfo.uniqueKey) {
            
            // Get the student object id
            if let objectID = Students.sharedInstance().getStudentObjectID(OTMClient.sharedInstance().loggedInUserInfo.uniqueKey) {
                
                OTMClient.sharedInstance().loggedInUserInfo.objectId = objectID
                
                // Update previous location
                OTMClient.sharedInstance().updateStudentLocation(OTMClient.sharedInstance().loggedInUserInfo) { success, error in
                    
                    if success {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else {
                        println()
                        println(error)
                        println("Something bad happened in Submit Touch")
                    }
                }
            }
        }
        else {
            // Post new location
            print(OTMClient.sharedInstance().loggedInUserInfo.description())
            
            OTMClient.sharedInstance().postStudentLocation(OTMClient.sharedInstance().loggedInUserInfo) { success, error in
                
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else {
                    println("Something bad happened")
                }
            }
        }
    }
}


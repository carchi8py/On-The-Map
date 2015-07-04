//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Chris Archibald on 7/3/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import UIKit
import MapKit

class MapViewController : UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make a copy of the student information from the model
        self.loadMapData()
        
        // Subscribe to student information refreshed notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "studentInformationRefreshed:", name: OTMClient.Notifications.StudentInformationDownloaded, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unsubscribe to notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: OTMClient.Notifications.StudentInformationDownloaded, object: nil)
    }
    
    func studentInformationRefreshed(notification: NSNotification) {
        // Refresh the table when reload button is pressed
        println("studentInformationRefreshed")
        self.loadMapData()
    }
    
    func loadMapData() {
        
        // Delete any previous annotations
        var annotations = [MKPointAnnotation]()
        let annotationsOnMap = mapView.annotations;
        self.mapView.removeAnnotations(annotationsOnMap)
        
        // 1. Get student information from the model
        
        // Parse the student information to create an array of annotations
        for student in Students.sharedInstance().students {
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(student.firstName) \(student.lastName)"
            annotation.subtitle = student.mediaURL
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
            
        }
        
        // When the array is complete, we add the annotations to the map.
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.addAnnotations(annotations)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            
            // Get the student's URL
            let studentURL = annotationView.annotation.subtitle!
            
            /// Open safari to the students link
            if let url = NSURL(string: studentURL) {
                if UIApplication.sharedApplication().canOpenURL(url){
                    UIApplication.sharedApplication().openURL(url)
                }
                else {
                    println("Somethng bad happned on the map")
                }
            }
        }
    }
}
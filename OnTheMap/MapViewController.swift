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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "studentInformationRefreshed:", name: OTMClient.Notifications.StudentInformationDownloaded, object: nil)
        self.loadMapData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unsubscribe to notifications
       NSNotificationCenter.defaultCenter().removeObserver(self, name: OTMClient.Notifications.StudentInformationDownloaded, object: nil)
    }
    
    func studentInformationRefreshed(notification: NSNotification) {
        // Refresh the table when reload button is pressed
        self.loadMapData()
    }
    
    func loadMapData() {
        
        // Delete any previous annotations
        var annotations = [MKPointAnnotation]()
        //let annotationsOnMap = mapView.annotations;
        //self.mapView.removeAnnotations(annotationsOnMap)
        
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
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView!  {
        println("Here we are")
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinColor = .Red
            println("WE are in")
            pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        println("CLICKED")
        
        if control == annotationView.rightCalloutAccessoryView {
            println("HI")
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: fixLinks(annotationView.annotation.subtitle!))!)
            
            // Get the student's URL
            //let studentURL = annotationView.annotation.subtitle!
            
            // Open safari to the students link
            //let newurl = fixLinks(studentURL)
            //if let newurl = NSURL(string: studentURL) {
            //    print(newurl)
            //    if UIApplication.sharedApplication().canOpenURL(newurl){
            //        UIApplication.sharedApplication().openURL(newurl)
             //   }
             //   else {
            //        println("Somethng bad happned on the map")
            //    }
            //}
        }
    }
    // A lot of people don't include the http part of a link
    // This check see if they have or not. If they haven't automaticly add it
    func fixLinks(urlString: String) -> String
    {
        if urlString.rangeOfString("http://www.") == nil {
            let newString = "http://www." + urlString
            return newString
        }
        return urlString
    }
}
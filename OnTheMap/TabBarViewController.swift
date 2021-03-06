//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by Chris Archibald on 7/3/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add 2 button to the right side
        let pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "pinTouched")
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshTouched")
        self.navigationItem.setRightBarButtonItems([pinButton,refreshButton], animated: true)
        
        self.refreshTouched()
    }
    
    func pinTouched() {
        //Check to see if a user has allready post if not let them post
        if Students.sharedInstance().didStudentPreviouslyPost(OTMClient.sharedInstance().loggedInUserInfo.uniqueKey) {
            let message = "User \"" + OTMClient.sharedInstance().loggedInUserInfo.firstName + " " + OTMClient.sharedInstance().loggedInUserInfo.lastName + "\" Has Already Posted a Student Location. Would You Like to Overwrite Their Location?"
            let alertController = UIAlertController(title: "", message: message, preferredStyle: .Alert)
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .Default, handler: { action in
                
                // Segue to the post view controller
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("toPostViewController", sender: self)
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(overwriteAction)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("toPostViewController", sender: self)
            }
        }
    }
    
    func refreshTouched() {
        // Give an error if there is not network connection
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if Reachability.isConnectedToNetwork() == true {
            // Load the student information
                Students.sharedInstance().getStudentInformation() { success, error in
                if success {
                    NSNotificationCenter.defaultCenter().postNotificationName(OTMClient.Notifications.StudentInformationDownloaded, object: self)
                }
                else {
                    println("Refresh touched failed")
                }
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        } else {
            self.displayUIAlert("No Network Connection", msg: "Must be connected to the internet to use this app")
        }
    }
    
    @IBAction func logOutTouched(sender: AnyObject) {
        // Give an error if there is not network connection
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if Reachability.isConnectedToNetwork() == true {
            //Logs the user out if they push the bottom
            OTMClient.sharedInstance().logOutWithUdacity() { success, error in
                // Check if logout was successful
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else {
                    println("Something bad happened")
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
        } else {
            self.displayUIAlert("No Network Connection", msg: "Must be connected to the internet to use this app")
        }
    }
    
    func displayError()
    {
        self.displayUIAlert("Missing information!", msg: "Must provide username and password to login.")
    }
    
    func displayUIAlert(title: String, msg: String){
        UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: "OK").show()
    }
}

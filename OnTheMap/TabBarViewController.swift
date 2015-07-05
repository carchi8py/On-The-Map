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
            let alertController = UIAlertController(title: "", message: "You have already posted a student location. Would you like to overwrite your current location?", preferredStyle: .Alert)
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .Default, handler: { action in
                
                // Segue to the post view controller
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("toPostViewController", sender: self)
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.addAction(overwriteAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("toPostViewController", sender: self)
            }
        }
    }
    
    func refreshTouched() {
        // Load the student information
            Students.sharedInstance().getStudentInformation() { success, error in
            if success {
                NSNotificationCenter.defaultCenter().postNotificationName(OTMClient.Notifications.StudentInformationDownloaded, object: self)
            }
            else {
                println("Refresh touched failed")
            }
        }
    }
    
    @IBAction func logOutTouched(sender: AnyObject) {
        //Logs the user out if they push the bottom
        OTMClient.sharedInstance().logOutWithUdacity() { success, error in
            // Check if logout was successful
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                println("Something bad happened")
            }
        }
    }
}

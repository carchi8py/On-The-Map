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
        
    }
    
    func pinTouched() {
        
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

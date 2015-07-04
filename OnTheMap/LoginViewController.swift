//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Chris Archibald on 7/3/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func LoginPressed(sender: AnyObject) {
        authenticateWithUdacity()
        
    }
    
    func authenticateWithUdacity() {
        OTMClient.sharedInstance().authenticateWithUdacity(email.text, password: password.text, completionHandler: { success,error in
            
            if success {
                println("w00t it worked")
                self.loginWorked()
            } else {
                println("It failed")
            }
        })

    }
    
    func loginWorked() {
        //This function get called when we have logged in, it segway's us to
        //the map
        
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("toNavigationController", sender: self)
        }
    }
}


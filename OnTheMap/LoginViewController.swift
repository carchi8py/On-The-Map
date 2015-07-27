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
    @IBOutlet weak var waitingOnServer: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.waitingOnServer.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.waitingOnServer.hidden = true
    }
    
    //When the user clicks on login we will start the UIActivityIndicator so
    // that they know we are waiting on server
    @IBAction func LoginPressed(sender: AnyObject) {
        self.waitingOnServer.startAnimating()
        self.waitingOnServer.hidden = false
        authenticateWithUdacity()
    }
    
    func authenticateWithUdacity() {
        //Check to see if we have network connection, If not give the user an error
        if Reachability.isConnectedToNetwork() == true {

            OTMClient.sharedInstance().authenticateWithUdacity(email.text, password: password.text, completionHandler: { success,error in
                
                //Once we get a responce from the server we stop the UIActivityIndicator
                self.waitingOnServer.stopAnimating()
                if success {
                    self.loginWorked()
                } else {
                    self.displayError()
                }
            })
        } else {
            self.displayUIAlert("No Network Connection", msg: "Must be connected to the internet to use this app")
        }
    }
        
    func loginWorked() {
        //This function get called when we have logged in, it segway's us to
        //the map
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("toNavigationController", sender: self)
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


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
    
    @IBAction func LoginPressed(sender: AnyObject) {
        self.waitingOnServer.startAnimating()
        self.waitingOnServer.hidden = false
        authenticateWithUdacity()
        
    }
    
    func authenticateWithUdacity() {
        OTMClient.sharedInstance().authenticateWithUdacity(email.text, password: password.text, completionHandler: { success,error in
            
            self.waitingOnServer.stopAnimating()
            if success {
                println("it worked")
                self.loginWorked()
            } else {
                self.displayError(error!.localizedDescription)
                println("If Failed")
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
    
    func displayError(errorString: String?)
    {
        self.displayUIAlert("Missing information!", msg: "Must provide username and password to login.")
    }
    
    func displayUIAlert(title: String, msg: String){
        UIAlertView(title: title, message: msg, delegate: nil, cancelButtonTitle: "Ok").show()
    }
}


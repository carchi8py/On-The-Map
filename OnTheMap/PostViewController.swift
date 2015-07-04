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
    
    //If the cancel button is touched, go back to tab bar view
    @IBAction func cancleTouched(sender: AnyObject) {
         self.dismissViewControllerAnimated(true, completion: nil)
    }
}


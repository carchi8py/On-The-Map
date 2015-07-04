//
//  OTMConvenience.swift
//  OnTheMap
//
//  Created by Chris Archibald on 7/3/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import Foundation
import UIKit

extension OTMClient {
    
    func authenticateWithUdacity(username : String, password: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [String: AnyObject]()
        
        //Set the username and the password
        let details : [String: AnyObject] = [
            OTMClient.JSONBodyKey.Username: username,
            OTMClient.JSONBodyKey.Password: password
        ]
        
        //Set the Udacity object
        let jsonBody: [String: AnyObject] = [
            OTMClient.JSONBodyKey.Udacity: details]
        
        /* 2. Make the request */
        let task = taskForUdacityPost(Methods.UdacitySession, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
        
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                
                if let session = JSONResult.valueForKey(OTMClient.JSONResponseKeys.Session) as? NSDictionary {
                    
                    //Gets the SessionID
                    if let sessionID = session.valueForKey(OTMClient.JSONResponseKeys.SessionID) as? String {
                        OTMClient.sharedInstance().sessionID = sessionID
                    }
                    if let account = JSONResult.valueForKey(OTMClient.JSONResponseKeys.UdacityAccount) as? NSDictionary {
                        if let udacityKey = account.valueForKey(OTMClient.JSONResponseKeys.UdacityKey) as? String {
                            OTMClient.sharedInstance().loggedInUserInfo.uniqueKey = udacityKey
                            
                            //Get others user for the map
                            self.getUserData(udacityKey) { success, error in
                                if success {
                                    // Successful Login
                                    completionHandler(success: true, error: nil)
                                }
                                else {
                                    completionHandler(success: false, error: nil)
                                }
                            }
                        }
                    }
                } else {
                    
                }
            }
        }
    }
    
    func logOutWithUdacity(completionHandler: (success: Bool, error: NSError?) -> Void) {
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [String: AnyObject]()
    
        /* 2. Make the request */
        taskForUdacityGETMethod(Methods.UdacitySession, parameters: parameters) { JSONResult, error in
            
             /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                // Check if session dictionary exists
                if let session = JSONResult.valueForKey(OTMClient.JSONResponseKeys.Session) as? NSDictionary {
                    if let sessionID = session.valueForKey(OTMClient.JSONResponseKeys.SessionID) as? String {
                        completionHandler(success: true, error: nil)
                    }
                } else {
                    completionHandler(success: false, error: NSError(domain: "logoutUserFromUdacity parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse logoutUserFromUdacity"]))
                }

            }
        }
    }
    
    func getUserData(udacityID: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [String: AnyObject]()
        var mutableMethod : String = Methods.UdacityUserData
        mutableMethod = OTMClient.subtituteKeyInMethod(mutableMethod, key: OTMClient.URLKeys.UserID, value:udacityID)!
        
        /* 2. Make the request */
        taskForUdacityGETMethod(mutableMethod, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                if let userInfo = JSONResult.valueForKey(OTMClient.JSONResponseKeys.UdacityUserInfo) as? NSDictionary {
                    if let firstName = userInfo.valueForKey(OTMClient.JSONResponseKeys.UdacityFirstName) as? String {
                        OTMClient.sharedInstance().loggedInUserInfo.firstName = firstName
                    }
                    if let lastName = userInfo.valueForKey(OTMClient.JSONResponseKeys.UdacityLastName) as? String {
                        OTMClient.sharedInstance().loggedInUserInfo.lastName = lastName
                    }
                }
                completionHandler(success: true, error: error)
            }
        }
    }
}
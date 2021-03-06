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
        println("Hitting post")
        let task = taskForUdacityPost(Methods.UdacitySession, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
        
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                println("Error 1")
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
                                    println("Authenticate worked")
                                    completionHandler(success: true, error: nil)
                                }
                                else {
                                    println("Authenticate Failed")
                                    completionHandler(success: false, error: nil)
                                }
                            }
                        }
                    }
                } else {
                    completionHandler(success: false, error: NSError(domain: "Authentication Failure", code: 8001, userInfo: nil))
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
    
    func getLocationData(udacityID: String, completionHandler: (success: Bool, error: NSError?) -> Void) {
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        let dictionary = [OTMClient.JSONResponseKeys.UniqueKey: udacityID]
        let json = NSJSONSerialization.dataWithJSONObject(dictionary, options: nil, error: nil)
        let parameters = [OTMClient.ParameterKeys.Where: json!]
        
        /* 2. Make the request */
        taskForParseGet(OTMClient.Methods.ParseStudentLocation, parameters: parameters) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                if let results = JSONResult.valueForKey(OTMClient.JSONResponseKeys.StudentResults) as? NSDictionary {
                    if let objectID = results.valueForKey(OTMClient.JSONResponseKeys.ObjectID) as? String {
                        completionHandler(success: true, error: nil)
                    }
                } else {
                    completionHandler(success: false, error: NSError(domain: "getStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocation"]))
                }
            }
        }
    }
    
    func getAllStudentInformation(completionHandler: (success: Bool, result: [StudentInfo]?, error: NSError?) -> Void) {
        
        // First, fetch the total count of all students
        let parameters = [
            OTMClient.ParameterKeys.Limit: 0,
            OTMClient.ParameterKeys.Count: 1
        ]
        
        // Make the request
        taskForParseGet(OTMClient.Methods.ParseStudentLocation, parameters: parameters) { JSONResult, error in
            
            if let error = error {
                // Connection failure or request timeout on POST
                completionHandler(success: false, result: nil, error: error)
            } else {
                
                if let count = JSONResult.valueForKey(OTMClient.JSONResponseKeys.Count) as? Int {
                    // Total number of students
                    //var numberOfFetches = Int(floor( Double(count) / Double(OTMClient.Constants.FetchLimit) ))
                    //for now let limit your self to 1 (100 students)
                    var numberOfFetches = 1
                    
                    var students = [StudentInfo]()
                    self.getStudentInformationBatch(numberOfFetches) { success, results, error in
                        
                        if success {
                            if let result = results {
                                // Combine the arrays together
                                students += result
                                println("Student count: \(students.count)")
                                completionHandler(success: true, result: students, error: nil)
                            }
                            else {
                                completionHandler(success: false, result: nil, error: NSError(domain: "getStudentInformationBatch parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentInformationBatch"]))
                            }
                        }
                    }
                } else {
                    completionHandler(success: false, result: nil, error: NSError(domain: "getAllStudentInformation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getAllStudentInformation"]))
                }
            }
        }
    }
    
    // Retrieve the student information in batches. With the current settings, data is retrieved in batches of 100.
    // So if there are 250 students, information will be retrieved in 3 requests
    func getStudentInformationBatch(repeat: Int, completionHandler: (success: Bool, result: [StudentInfo]?, error: NSError?) -> Void) {
        
        if repeat >= 0 {
            
            getStudentInformationBatch(repeat - 1) { success, result, error in
                completionHandler(success: true, result: result, error: error)
            }
            usleep(20000)
            
            /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
            let parameters = [
                OTMClient.ParameterKeys.Limit: OTMClient.Constants.FetchLimit,
                OTMClient.ParameterKeys.Skip: repeat * OTMClient.Constants.FetchLimit
            ]
            
            /* 2. Make the request */
            taskForParseGet(OTMClient.Methods.ParseStudentLocation, parameters: parameters) { JSONResult, error in
                
                /* 3. Send the desired value(s) to completion handler */
                if let results = JSONResult.valueForKey(OTMClient.JSONResponseKeys.StudentResults) as? [[String : AnyObject]] {
                    // Parse the student information
                    var studentBatch = StudentInfo.studentsFromResults(results)
                    completionHandler(success: true, result: studentBatch, error: error)
                }
                println(parameters)
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
    
    func updateStudentLocation(student: StudentInfo, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [String: AnyObject]()
        var jsonBody: [String:AnyObject] = [
            OTMClient.JSONResponseKeys.UniqueKey: student.uniqueKey,
            OTMClient.JSONResponseKeys.FirstName: student.firstName,
            OTMClient.JSONResponseKeys.LastName: student.lastName,
            OTMClient.JSONResponseKeys.Latitude: student.latitude,
            OTMClient.JSONResponseKeys.Longitude: student.longitude,
            OTMClient.JSONResponseKeys.MapString: student.mapString,
            OTMClient.JSONResponseKeys.MediaURL: student.mediaURL
        ]
        var mutableMethod : String = Methods.ParseUpdateStudentLocation
        mutableMethod = OTMClient.subtituteKeyInMethod(mutableMethod, key: OTMClient.URLKeys.UserID, value:student.objectId)!
        println(mutableMethod)
        
        /* 2. Make the request */
        taskForParsePost("PUT", method: mutableMethod, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                // Connection failure or request timeout on POST
                completionHandler(success: false, error: error)
            }
            else {
                // Check if updatedAt is returned
                println(JSONResult)
                println(JSONResult.valueForKey(OTMClient.JSONResponseKeys.UpdatedAt))
                if let updatedAt = JSONResult.valueForKey(OTMClient.JSONResponseKeys.UpdatedAt) as? NSString {
                    completionHandler(success: true, error:nil)
                }
                else {
                    // Process parsing errors
                    completionHandler(success: false, error: NSError(domain: "updateStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse updateStudentLocation"]))
                }
            }
        }
    }
    
    func postStudentLocation(student: StudentInfo, completionHandler: (success: Bool, error: NSError?) -> Void) {
        
        /* 1. Specify parameters, method (if has {key}), and HTTP body (if POST) */
        var parameters = [String: AnyObject]()
        var jsonBody: [String:AnyObject] = [
            OTMClient.JSONResponseKeys.UniqueKey: student.uniqueKey,
            OTMClient.JSONResponseKeys.FirstName: student.firstName,
            OTMClient.JSONResponseKeys.LastName: student.lastName,
            OTMClient.JSONResponseKeys.Latitude: student.latitude,
            OTMClient.JSONResponseKeys.Longitude: student.longitude,
            OTMClient.JSONResponseKeys.MapString: student.mapString,
            OTMClient.JSONResponseKeys.MediaURL: student.mediaURL
        ]
        
        /* 2. Make the request */
        taskForParsePost("POST", method: OTMClient.Methods.ParseStudentLocation, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
            
            /* 3. Send the desired value(s) to completion handler */
            if let error = error {
                // Connection failure or request timeout on POST
                completionHandler(success: false, error: error)
            }
            else {
                // Check if object ID is returned
                if let objectID = JSONResult.valueForKey(OTMClient.JSONResponseKeys.ObjectID) as? NSString {
                    completionHandler(success: true, error:nil)
                }
                else {
                    // Process parsing errors
                    completionHandler(success: false, error: NSError(domain: "postStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postStudentLocation"]))
                }
            }
        }
    }
    
}
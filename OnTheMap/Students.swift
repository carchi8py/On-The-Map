//
//  Students.swift
//  OnTheMap
//
//  Created by Chris Archibald on 7/3/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import Foundation

class Students {
    var students = [StudentInfo]()
    
    func getStudentInformation(completionHandler: (success: Bool, error: NSError?) -> Void) {
        students = [StudentInfo]()
        
        // Load the student information
        OTMClient.sharedInstance().getAllStudentInformation() { success, results, error in
            
            if success {
                if let students = results {
                    self.students = students
                }
                completionHandler(success: true, error: nil)
            } else {
                completionHandler(success: false, error: error)
            }
        }
    }
    
    class func sharedInstance() -> Students {
        struct Singleton {
            static var sharedInstance = Students()
        }
        return Singleton.sharedInstance
    }
}
//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by Chris Archibald on 7/3/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import Foundation

struct StudentInfo {
    
    var objectId: String = ""
    var uniqueKey: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var mapString: String = ""
    var mediaURL: String = ""
    
    init(){}
    
    init(jsonDisctionary: NSDictionary){
        objectId = jsonDisctionary[OTMClient.JSONResponseKeys.ObjectID] as! String
        uniqueKey = jsonDisctionary[OTMClient.JSONResponseKeys.UniqueKey] as! String
        firstName = jsonDisctionary[OTMClient.JSONResponseKeys.FirstName] as! String
        lastName = jsonDisctionary[OTMClient.JSONResponseKeys.LastName] as! String
        latitude = jsonDisctionary[OTMClient.JSONResponseKeys.Latitude] as! Double
        longitude = jsonDisctionary[OTMClient.JSONResponseKeys.Longitude] as! Double
        mapString = jsonDisctionary[OTMClient.JSONResponseKeys.MapString] as! String
        mediaURL = jsonDisctionary[OTMClient.JSONResponseKeys.MediaURL] as! String
    }
    
    static func studentsFromResults(results: [[String : AnyObject]]) -> [StudentInfo] {
        var students = [StudentInfo]()
        
        for result in results {
            students.append(StudentInfo(jsonDisctionary: result))
        }
        
        return students
    }
    
    func description() -> String {
        
        let studentInfo = "object id: \(objectId)" + "\n" + "unique key: \(uniqueKey)" + "\n" + "first name: \(firstName)" + "\n" + "last name: \(lastName)" + "\n" + "latitude: \(latitude)" + "\n" + "longitude: \(longitude)" + "\n" + "map string: \(mapString)" + "\n" + "media URL: \(mediaURL)"
        
        return studentInfo
        
    }
}
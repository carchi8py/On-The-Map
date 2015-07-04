//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by Chris Archibald on 7/3/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import Foundation

class StudentInfo {
    
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
}
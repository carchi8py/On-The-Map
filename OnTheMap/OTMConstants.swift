//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Chris Archibald on 7/3/15.
//  Copyright (c) 2015 Chris Archibald. All rights reserved.
//

import Foundation

extension OTMClient {
    
    //Constants
    struct Constants {
        static let UdacityBaseURL : String = "https://www.udacity.com/api/"
    }
    //Methods
    struct Methods {
        static let UdacitySession = "session"
        static let UdacityUserData = "users/{id}"
    }
    //URL Keys
    struct URLKeys {
        static let UserID = "id"
    }
    //Parameter Keys
    //JSON Body Keys
    struct  JSONBodyKey {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
    }
    //JSON Response Keys
    struct JSONResponseKeys {
        static let Session = "session"
        static let SessionID = "id"
        static let UdacityAccount = "account"
        static let UdacityKey = "key"
        static let UdacityUserInfo = "user"
        static let UdacityFirstName = "first_name"
        static let UdacityLastName = "last_name"
        
        //Student Info
        static let StudentResults = "results"
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let UpdatedAt = "updatedAt"
        static let Count = "count"
    }
}
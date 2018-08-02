//
//  Location.swift
//  SearchBarPOC
//
//  Created by Ishan Malviya on 3/22/17.
//  Copyright © 2017 ishan. All rights reserved.
//


import SwiftyJSON

class Location {

    var locationID: String
    var locationText: String

    
    
    init(locationData: JSON) {
        let locationJSON = JSON(locationData)
        print(locationJSON)
       
        self.locationText = locationData["text"].string!
        
        
        if self.locationText == "No locations found." {
            self.locationID = "0"
        } else {
            self.locationID = locationData["id"].string!
        }
    }
}

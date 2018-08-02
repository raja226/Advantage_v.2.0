//
//  Country.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/25/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import SwiftyJSON

class Country {
    var countryCode: String
    var countryName: String
    var nativeTongue: String
    
    init(countryData: (String, JSON)) {
        
        var countryDetails = countryData.1
        self.countryCode = countryData.0
        self.countryName = countryDetails["name"].string!
        self.nativeTongue = countryDetails["nativetongue"].string!
    }
}

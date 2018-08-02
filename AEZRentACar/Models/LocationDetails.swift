//
//  LocationDetails.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/13/17.
//  Copyright © 2017 Cybage. All rights reserved.
//


import SwiftyJSON

class LocationDetails {
    var locationCode: String
    var locationName: String
    var latitude: String
    var longitude: String
    var addLine1: String
    var addLine2: String
    var city: String
    var state: String
    var stateName: String
    var postalCode: String
    var country: String
    var countryName: String
    var phoneCountryCode: String
    var phone1: String
    var phone2: String
    var fax: String
    var inTerminal: Int
    var locationType: String
    var shuttleDistance: String
    var shuttleTime: String
    var lastUpdatedOn: String
    var allowPrepaid: Bool
    var allowPrepaidDiscounts: Bool
    var online: Bool
    var brandName: String
    var logTransactions: Bool
    var allowPromos: Bool
    var noRentals: Bool
    
    var isRentalLocation = true
    
    init(locationDetails:JSON) {
        self.locationCode = locationDetails["LocationCode"].string!
        self.locationName = locationDetails["LocationName"].string!
        self.latitude = locationDetails["Latitude"].string!
        self.longitude = locationDetails["Longitude"].string!
        self.addLine1 = locationDetails["AddLine1"].string!
        self.addLine2 = locationDetails["AddLine2"].string!
        self.city = locationDetails["City"].string!
        self.state = locationDetails["State"].string!
        self.stateName = locationDetails["StateName"].string!
        self.postalCode = locationDetails["PostalCode"].string!
        self.country = locationDetails["Country"].string!
        self.countryName = locationDetails["CountryName"].string!
        self.phoneCountryCode = locationDetails["PhoneCountryCode"].string!
        self.phone1 = locationDetails["Phone1"].string!
        self.phone2 = locationDetails["Phone2"].string!
        self.fax = locationDetails["Fax"].string!
        self.inTerminal = locationDetails["InTerminal"].int!
        self.locationType = locationDetails["LocationType"].string!
        self.shuttleDistance = locationDetails["ShuttleDistance"].string!
        self.shuttleTime = locationDetails["ShuttleTime"].string!
        self.lastUpdatedOn = locationDetails["State"].string!
        self.allowPrepaid = locationDetails["AllowPrepaid"].bool!
        self.allowPrepaidDiscounts = locationDetails["AllowPrepaidDiscounts"].bool!
        self.online = locationDetails["Online"].bool!
        self.brandName = locationDetails["BrandName"].string!
        self.logTransactions = locationDetails["LogTransactions"].bool!
        self.allowPromos = locationDetails["AllowPromos"].bool!
        self.noRentals = locationDetails["NoRentals"].bool!
    }
    
}

/*
 "LocationCode": "MCO",
 "LocationName": "Orlando International Airport",
 "Latitude": "28.430959",
 "Longitude": "-81.308076",
 "AddLine1": "1 Airport Blvd",
 "AddLine2": "",
 "City": "Orlando",
 "State": "FL",
 "StateName": "Florida",
 "PostalCode": "32827",
 "Country": "US",
 "CountryName": "United States",
 "PhoneCountryCode": "",
 "Phone1": "(800) 777-5500",
 "Phone2": "407-203-1204",
 "Fax": "",
 "InTerminal": 1,
 "LocationType": "1",
 "ShuttleDistance": "0",
 "ShuttleTime": "0",
 "LastUpdatedOn": null,
 "AllowPrepaid": true,
 "AllowPrepaidDiscounts": true,
 "Online": true,
 "BrandName": "Advantage",
 "LogTransactions": true,
 "AllowPromos": true,
 "NoRentals": false
 
 */

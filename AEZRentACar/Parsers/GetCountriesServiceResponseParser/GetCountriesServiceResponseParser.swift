//
//  GetCountriesServiceResponseParser.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/25/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import SwiftyJSON

class GetCountriesServiceResponseParser: NSObject {
    func parseCountriesServiceResponse(countries: Any) -> (success: Bool, countryList: [Country])  {
        var countriesArray:[Country] = []
        print("parseCountriesServiceResponse")
        let countriesJSON = JSON(countries)
        let status = countriesJSON["status"]
        if status == "success" {
            for country:(String, JSON) in countriesJSON {
                if country.0 == "status" {
                    continue
                }
                //Do something you want
                print(country)
                countriesArray.append(Country(countryData: country))
            }
            return (success: true, countryList: countriesArray)
        } else {
            return (success: false, countryList: countriesArray)
        }
    }
}


/*
 import SwiftyJSON
 
 class GetUSStatesServiceResponseParser: NSObject {
 func parseUSStatesServiceResponse(usstates: Any)->[USState]  {
 var usStatesArray:[USState] = []
 print("parseUSStateServiceResponse")
 let usstatesJSON = JSON(usstates)
 for state:(String, JSON) in usstatesJSON {
 //Do something you want
 print(state)
 usStatesArray.append(USState(stateData: state))
 }
 return usStatesArray
 }
 }
 */

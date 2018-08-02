//
//  SearchLocationServiceResponseParser.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/12/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import SwiftyJSON

class SearchLocationServiceResponseParser {
    func parseSearchServiceResponse(locationData: Any)->[Location]  {
        var locationArray:[Location] = []
        print("parseSearchServiceResponse")
        let locationJSON = JSON(locationData)
        for (key,subJson):(String, JSON) in locationJSON {
            //Do something you want
            print(key)
            for (_,locationObject):(String, JSON) in subJson {
                locationArray.append(Location(locationData: locationObject))
            }
        }
        return locationArray
    }


}

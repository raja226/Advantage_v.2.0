//
//  GetRatesServiceResponseParser.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 5/19/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import SwiftyJSON

class GetRatesServiceResponseParser: NSObject {
    
    func parseGetRatesServiceResponse(response: Any) -> (success: Bool, message: String?, aezCar: AEZRates?)  {
        
        print("parseGetRatesServiceResponse")
        
        let responseInJSON = JSON(response)
        let status = responseInJSON["status"]
        if status == "success" {
            let aezCar = AEZRates(responseJSON: responseInJSON)
            return (success: true, message: nil, aezCar: aezCar)
        } else {
            let message = responseInJSON["error"]["errorMessage"].string!
            return (success: false, message: message, aezCar: nil)
        }
    }
}

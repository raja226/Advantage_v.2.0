//
//  PreReservationResponseParser.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 8/11/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit
import SwiftyJSON

class PreReservationResponseParser: NSObject {
    
    func parsePreReservationServiceResponse(response: Any) -> (success: Bool, message: String?, preReservation:PreReservation?)  {
    
        print("parsePreReservationServiceResponse")
        
        let preReservation = PreReservation()
        
        let responseInJSON = JSON(response)
        
        if let addRezRequest = responseInJSON["AddRezRequest"].string {
            preReservation.addRezRequest = addRezRequest
        }
        
        if let pageURLAsString = responseInJSON["URL"].string {
            preReservation.pageURLAsString = pageURLAsString
        }
        
        if let authToken = responseInJSON["auth_token"].string {
            preReservation.authToken = authToken
        }
        
        return (success: true, message: nil, preReservation:preReservation)
    }
}

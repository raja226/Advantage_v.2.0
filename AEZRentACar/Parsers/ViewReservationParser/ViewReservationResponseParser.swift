//
//  ViewReservationResponseParser.swift
//  Advantage
//
//  Created by macbook on 6/28/18.
//  Copyright © 2018 Anjali Panjawani. All rights reserved.
//

import Foundation
import SwiftyJSON

class ViewReservationResponseParser: NSObject {
    func parseViewReservationResponse(response: Any) -> (success: Bool, message: String?, viewReservationResponse: BillingDetails?) {
        print("ViewReservationResponse")
        
        let responseInJSON = JSON(response)
        let status = responseInJSON["status"]
        if status == "success" {
            let billingData = BillingDetails(responseJSON: responseInJSON)
            return (success: true, message: nil, viewReservationResponse: billingData)
        } else {
            let message = responseInJSON["error"]["errorMessage"].string!
            return (success: false, message: message, viewReservationResponse: nil)
        }
    }
}

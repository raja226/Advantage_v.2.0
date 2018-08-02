//
//  RequestBillServiceResponseParser.swift
//  AEZRentACar
//
//  Created by Anjali Panjwani on 16/06/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import SwiftyJSON

class RequestBillServiceResponseParser: NSObject {
    
    func parseRequestBillServiceResponse(response: Any) -> (success: Bool, message: String?, billingDataResponse: BillingDetails?) {
        
        print("parseRequestBillServiceResponse")
       
        let responseInJSON = JSON(response)
        print("resquestBill:\(responseInJSON)")
        let status = responseInJSON["status"]
        if status == "success" {
            let billingData = BillingDetails(responseJSON: responseInJSON)
            return (success: true, message: nil, billingDataResponse: billingData)
        } else {
            let message = responseInJSON["error"]["errorMessage"].string!
            return (success: false, message: message, billingDataResponse: nil)
        }
    }
}

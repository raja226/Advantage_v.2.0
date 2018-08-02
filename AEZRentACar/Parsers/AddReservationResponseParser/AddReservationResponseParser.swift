//
//  AddReservationResponseParser.swift
//  AEZRentACar
//
//  Created by Anjali Panjwani on 14/06/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddReservationResponseParser: NSObject {

    func parseAddReservationServiceResponse(response: Any) -> (success: Bool, message: String?, confirmationNumb:String?)  {
        
        print("parseAddReservationServiceResponse")
        var confirmNumb: String?
        
        let responseInJSON = JSON(response)
        let status = responseInJSON["status"]
       
        if status == "success" {
            if let confirmatinonNumber = responseInJSON["ConfirmNum"].string {
                 confirmNumb = confirmatinonNumber
            }
          return (success:true, message: nil, confirmationNumb: confirmNumb)
        } else {
            let message = responseInJSON["error"]["errorMessage"].string!
            return (success: false, message: message,confirmationNumb: nil)
        }
    }
}

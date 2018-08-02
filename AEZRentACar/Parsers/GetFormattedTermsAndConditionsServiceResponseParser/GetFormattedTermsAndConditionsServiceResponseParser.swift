//
//  GetFormattedTermsAndConditionsServiceResponseParser.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/25/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import SwiftyJSON

class GetFormattedTermsAndConditionsServiceResponseParser: NSObject {
    func parseFormattedTermsAndConditionsServiceResponse(policyData: Any)-> (success: Bool, termsText: String)  {
        print("parseFormattedTermsAndConditionsServiceResponse")
        let responseJSON = JSON(policyData)
        let status = responseJSON["status"].string!
        if status == "error" {
            let message = responseJSON["error"]["errorMessage"].string!
            return (success: false, termsText: message)
        } else {
            var termsText = responseJSON["terms"].string!
            termsText = "<font face='Montserrat' size='2' color='666666'> \(termsText)"
            return (success: true, termsText: termsText)
        }
    }
}

//
//  LoyaltyProfileServiceResponseParser.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 26/04/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import SwiftyJSON

class LoyaltyProfileServiceResponseParser: NSObject {
    
    func parseGetLoyaltyProfileServiceResponse(loyaltyProfileData: Any) -> (success: Bool, message: String?,loyaltyProfile: UserLoyaltyProfile?)  {
        print("parseGetTravelPreferencesServiceResponse")
        let loyaltyProfileJSON = JSON(loyaltyProfileData)
        let status = loyaltyProfileJSON["status"]
        if status == "success" {
            let loyaltyProfile = UserLoyaltyProfile(loyaltyJSON: loyaltyProfileJSON)
            return (success: true, message: nil, loyaltyProfile:loyaltyProfile)
        } else {
            let message = loyaltyProfileJSON["error"]["errorMessage"].string!
            return (success: false, message: message, loyaltyProfile:nil)
        }
    }
    
}

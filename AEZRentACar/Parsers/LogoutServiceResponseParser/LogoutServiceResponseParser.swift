//
//  LogoutServiceResponseParser.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 5/10/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import SwiftyJSON

class LogoutServiceResponseParser: NSObject {
    func parsePostLogoutServiceResponse(response: Any) -> (success: Bool, message: String) {
        
        print("parsePostLogoutServiceResponse")
        
        let responseInJSON = JSON(response)
        let status = responseInJSON["status"]
        if status == "success" {
            let message = responseInJSON["success"].string!
            return (success: true, message: message)
        } else {
            let message = responseInJSON["error"]["errorMessage"].string!
            return (success: false, message: message)
        }
    }

}

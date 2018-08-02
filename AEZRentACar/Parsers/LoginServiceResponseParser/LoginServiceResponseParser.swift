//
//  LoginServiceResponseParser.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/12/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import SwiftyJSON

class LoginServiceResponseParser {
    
    func parseLoginServiceResponse(loginData: Any) -> (success: Bool, message: String?, login: Login?)  {
        print("parseSearchServiceResponse")
        let loginJSON = JSON(loginData)
        print(loginJSON)
        let status = loginJSON["status"]
        if status == "success" {
            let login = Login(loginData: loginJSON)
            return (success: true, message: nil, login: login)
        } else {
            let message = loginJSON["error"]["errorMessage"].string!
            return (success: false, message: message, login: nil)
        }
    }
}

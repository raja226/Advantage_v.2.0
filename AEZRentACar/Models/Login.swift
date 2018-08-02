//
//  Login.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/12/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import SwiftyJSON

class Login {

    var token_type:String
    var expires_in:Double
    var access_token:String
    var refresh_token:String
    var aez_message:String
    var loyalty_message:String
    var memberNumber:String
    var userGUID:String
    var SSO_HASH:String
    
    init(loginData:JSON) {
        
        self.token_type = loginData["token_type"].string!
        self.expires_in = loginData["expires_in"].double!
        
        self.access_token = loginData["access_token"].string!
        self.refresh_token = loginData["refresh_token"].string!
        
        self.aez_message = loginData["aez_message"].string!
        self.loyalty_message = loginData["loyalty_message"].string!
        
        self.memberNumber = loginData["memberNumber"].string!
        self.userGUID = loginData["userGUID"].string!
        
        self.SSO_HASH = loginData["SSO_HASH"].string!
    }
}

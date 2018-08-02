//
//  UserServiceResponseParser.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/26/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserServiceResponseParser: NSObject {
    func parseUserServiceResponse(userData: Any)-> (success: Bool, user: User?)  {
        print("parseSearchServiceResponse")
        let userJSON = JSON(userData)
        let status = userJSON["status"]
        if status == "success" {
            let user = User(userData: userJSON)
            return (success: true, user: user)
        } else {
            return (success: false, user: nil)
        }
    }
}

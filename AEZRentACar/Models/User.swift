//
//  User.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/26/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject {
    var id: Double?
    var name: String?
    var email: String?
    
    var created_at: String?
    var updated_at: String?
    var first_name: String?
    
    var last_name: String?
    var legacy_user: String?
    var legacy_password: String?
    
    var legacy_status: String?
    
    init(userData: (JSON)) {
        
        if let id = userData["id"].double {
            self.id = id
        }
        
        if let name = userData["name"].string {
            self.name = name
        }
        
        if let email = userData["email"].string {
            self.email = email
        }
        
        if let created_at = userData["created_at"].string {
            self.created_at = created_at
        }
       
        if let updated_at = userData["updated_at"].string {
            self.updated_at = updated_at
        }
        
        if let first_name = userData["first_name"].string {
            self.first_name = first_name
        }
        
        if let last_name = userData["last_name"].string {
            self.last_name = last_name
        }
       
        if let legacy_user = userData["legacy_user"].string {
            self.legacy_user = legacy_user
        }
        
        if let legacy_password = userData["legacy_password"].string {
            self.legacy_password = legacy_password
        }
        
        if let legacy_status = userData["legacy_status"].string {
            self.legacy_status = legacy_status
        }
        
        
    }
}



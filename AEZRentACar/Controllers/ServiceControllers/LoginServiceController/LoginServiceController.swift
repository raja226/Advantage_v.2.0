//
//  LoginServiceController.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/12/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import Alamofire

class LoginServiceController: NSObject {
    var request: DataRequest?
    
    func login(_ username: String, _ password: String, serviceSuccessHandler:@escaping (_ responseValue:Any) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
       
        let passwordHash = Utilities.sharedInstance.generatePasswordHash(password)
        
        let parameters = ["email": username,"password": password,"username": username,"grant_type": "password", "client_id" : username, "client_secret" : passwordHash , "services_url":ServiceConstants.kServicesURL,"logging_url":ServiceConstants.kLogginURL]
        
        request = Alamofire.request(ServiceConstants.userLogin, method: .post, parameters: parameters).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                print("Validation Successful")
                serviceSuccessHandler(value)
            case .failure(let error):
                print("Validation Failed")
                serviceFailureHnadler(error)
            }
        }
        
    }
    
}



//
//  UserServiceController.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/26/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import Alamofire

class UserServiceController: NSObject {
    var request: DataRequest?
    
    func getUser( _ token: String, serviceSuccessHandler:@escaping (_ responseValue:Any) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        
        let parameters = ["services_url":ServiceConstants.kServicesURL,"logging_url":ServiceConstants.kLogginURL]
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " +  token,
            "Accept": "application/json"
        ]
        
        request = Alamofire.request(ServiceConstants.user, method: .get, parameters: parameters, headers: headers).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                print("Validation Successful")
                print("User Response : \(value)")
                serviceSuccessHandler(value)
            case .failure(let error):
                print("Validation Failed")
                serviceFailureHnadler(error)
            }
        }
        
    }
}


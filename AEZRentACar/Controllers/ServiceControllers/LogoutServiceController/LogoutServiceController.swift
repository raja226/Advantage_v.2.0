//
//  LogoutServiceController.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 5/10/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import Alamofire

class LogoutServiceController: NSObject {
    var request: DataRequest?
    
    func postLogoutData(accessToken: String, emailAddress: String, serviceSuccessHandler:@escaping (_ responseValue:Any) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        
        let parameters = ["username": emailAddress, "services_url": ServiceConstants.kServicesURL,"logging_url": ServiceConstants.kLogginURL]
        
        request = Alamofire.request("\(ServiceConstants.logoutUser)/\(accessToken)", method: .post, parameters: parameters).responseJSON { response in
            
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

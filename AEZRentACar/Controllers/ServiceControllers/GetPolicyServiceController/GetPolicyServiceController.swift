//
//  GetPolicyServiceController.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 5/24/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import Alamofire

class GetPolicyServiceController: NSObject {
    var request: DataRequest?
    
    func getPolicy(rentalLocationID: String, serviceSuccessHandler:@escaping (_ responseValue:Any) -> Void, serviceFailureHandler:@escaping (_ errorValue:Any) -> Void) {
        
        let parameters = ["rental_location_id": rentalLocationID, "services_url":ServiceConstants.kServicesURL,"logging_url": ServiceConstants.kLogginURL]
        
        request = Alamofire.request(ServiceConstants.getPolicy, parameters: parameters).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                print("Validation Successful")
                serviceSuccessHandler(value)
            case .failure(let error):
                print("Validation Failed")
                serviceFailureHandler(error)
            }
        }
    }
}

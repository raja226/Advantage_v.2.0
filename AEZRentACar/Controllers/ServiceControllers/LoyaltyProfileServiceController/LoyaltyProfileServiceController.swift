//
//  LoyaltyProfileServiceController.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 26/04/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import Alamofire

class LoyaltyProfileServiceController: NSObject {

    var request: DataRequest?
    
    func getLoyaltyProfile (memberNumber: Double, serviceSuccessHandler:@escaping (_ responseValue:Any) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        let parameters = ["memberNumber": memberNumber, "services_url": ServiceConstants.kServicesURL,"logging_url": ServiceConstants.kLogginURL] as [String : Any]
        
        request = Alamofire.request(ServiceConstants.getLoyaltyProfile, parameters: parameters).responseJSON { response in
            
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

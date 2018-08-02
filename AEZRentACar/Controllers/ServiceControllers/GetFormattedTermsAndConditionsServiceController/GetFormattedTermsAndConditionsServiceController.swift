//
//  GetFormattedTermsAndConditionsServiceController.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/25/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import Alamofire

class GetFormattedTermsAndConditionsServiceController: NSObject {
    var request: DataRequest?
    func getFormattedTermsAndConditions(_ brand : String, _ location: String, serviceSuccessHandler:@escaping (_ responseValue:Any) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        
        let parameters = ["brand":brand, "rental_location_id" : "","services_url":ServiceConstants.kServicesURL,"logging_url":ServiceConstants.kLogginURL]
        
        request = Alamofire.request(ServiceConstants.getTermsAndConditions, parameters: parameters).responseJSON { response in
            
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

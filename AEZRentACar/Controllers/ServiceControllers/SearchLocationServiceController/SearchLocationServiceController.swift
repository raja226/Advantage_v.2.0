//
//  SearchLocationServiceController.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/12/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import Alamofire

class SearchLocationServiceController: NSObject {
    var request: DataRequest?
    
    func searchLocationWith (_ keyword : String,serviceSuccessHandler:@escaping (_ responseValue:Any) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        let parameters = ["LocationBrands":"Advantage,Europcar","LocationSearchString":keyword,"services_url":ServiceConstants.kServicesURL,"logging_url":ServiceConstants.kLogginURL]
        
        request = Alamofire.request(ServiceConstants.searchLocationsByBrands, parameters: parameters).responseJSON { response in
            
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






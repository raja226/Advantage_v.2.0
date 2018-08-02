//
//  GetRatesServiceController.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 5/19/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import Alamofire

class GetRatesServiceController: NSObject {
    var request: DataRequest?
    
    func getRates(rentalLocationID: String, returnLocationID: String, pickupDate: String, pickupTime: String, dropOffDate: String, dropOffTime: String, promoCodes:[String], serviceSuccessHandler:@escaping (_ responseValue:Any) -> Void, serviceFailureHandler:@escaping (_ errorValue:Any) -> Void) {
        
        let parameters = ["rental_location_id": rentalLocationID, "return_location_id":returnLocationID, "pickup_date":pickupDate, "pickup_time" : pickupTime, "dropoff_date":dropOffDate, "dropoff_time":dropOffTime, "promo_codes":promoCodes, "services_url": ServiceConstants.kServicesURL,"logging_url": ServiceConstants.kLogginURL] as [String : Any]
        
        request = Alamofire.request(ServiceConstants.getRates, parameters: parameters).responseJSON { response in
            
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


/*
https://devapi.advantage.com/api/v1/getRates?rental_location_id=MCO&return_location_id=MCO&pickup_date=09012017&pickup_time=11:00AM&dropoff_date=09042017&dropoff_time=09:00AM&promo_codes[]=GOV&promo_codes[]=abc&promo_codes[]=gov&services_url=http://services2.aezrac.com/webapi/aezrac.asmx&logging_url=http://services2.aezrac.com/logging
*/

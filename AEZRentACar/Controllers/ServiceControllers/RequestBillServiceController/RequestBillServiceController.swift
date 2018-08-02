//
//  RequestBillServiceController.swift
//  AEZRentACar
//
//  Created by Anjali Panjwani on 16/06/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import Alamofire

class RequestBillServiceController: NSObject {
    
    var request: DataRequest?
    
    func getRequestBillData (reservationData:Reservation, promoCodes:[String], prepaid: String, serviceSuccessHandler:@escaping (_ responseValue:Any) -> Void, extraOptions: [String]?, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        
        var dailyRate = reservationData.selectedCar?.payLaterRate.dailyRate! as Any
        if prepaid == "Y" {
            dailyRate = reservationData.selectedCar?.payNowRate.dailyRate! as Any
        }
        
        var parameters = ["rental_location_id": reservationData.rentalLocationId!, "return_location_id": reservationData.returnLocationId!, "pickup_date_time": reservationData.rentalDateTime! , "dropoff_date_time": reservationData.returnDateTime!, "rate_id": (reservationData.selectedCar?.rateID!)!, "class_code": (reservationData.selectedCar?.classCode!)!, "daily_rate": dailyRate, "prepaid": prepaid, "promo_codes": promoCodes, "services_url": ServiceConstants.kServicesURL,"logging_url": ServiceConstants.kLogginURL] as [String : Any]
        if let dailyExtraList = extraOptions {
            parameters["vehicleOptions"] = dailyExtraList
        }
        
        request = Alamofire.request(ServiceConstants.requestBill, parameters: parameters).responseJSON { response in
            
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



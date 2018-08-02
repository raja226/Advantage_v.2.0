//
//  ViewReservationServiceController.swift
//  Advantage
//
//  Created by macbook on 6/28/18.
//  Copyright © 2018 Anjali Panjawani. All rights reserved.
//

import UIKit
import Alamofire


class ViewReservationServiceController: NSObject {
    
    var request: DataRequest?
    
    func viewReservation(reservationData: Reservation, serviceSuccessHandler:@escaping (_ responseValue:Any) -> Void,  serviceFailureHandler:@escaping (_ errorValue:Any) -> Void) {
        
      
        
        let parameters = [
            "rental_location_id": reservationData.rentalLocationId as! String,
            "renter_last": reservationData.renterProfile?.lastName as! String,
            "confirm_num": reservationData.confirmationNumber as! String   ,
            "services_url": ServiceConstants.kServicesURL,
            
            "logging_url": ServiceConstants.kLogginURL] as [String : Any]
        
        
        
        request = Alamofire.request(ServiceConstants.viewReservation, method: .get, parameters: parameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                print("view reservation  Successful")
                print("server response controoler \(value)")
                serviceSuccessHandler(value)
            case .failure(let error):
                print("Validation Failed")
                print("view reservation error Up Error : \(error)")
                serviceFailureHandler(error)
            }
        }

        
        /*IMPORTANT
         Call /addReservation for PAY LATER
         and https://devrezbookmobile.aezrac.com/api/v1/preAddRez for PAY NOW
         */
        
       /* if reservationData.prepaid == "Y" {
            request = Alamofire.request(ServiceConstants.preAddReservation, method: .post, parameters: parameters).responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("Validation Successful")
                    print("server response controoler \(value)")
                    serviceSuccessHandler(value)
                case .failure(let error):
                    print("Validation Failed")
                    print("Add reservation error Up Error : \(error)")
                    serviceFailureHandler(error)
                }
            }
        } else {
            request = Alamofire.request(ServiceConstants.addReservation, method: .post, parameters: parameters).responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("Validation Successful")
                    print("server response controoler \(value)")
                    serviceSuccessHandler(value)
                case .failure(let error):
                    print("Validation Failed")
                    print("Add reservation error Up Error : \(error)")
                    serviceFailureHandler(error)
                }
            }
        }
        */
        
    }
}

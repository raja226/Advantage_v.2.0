//
//  AddReservationServiceController.swift
//  AEZRentACar
//
//  Created by Anjali Panjwani on 14/06/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import Alamofire

class AddReservationServiceController: NSObject {
    
    var request: DataRequest?
    
    func addReservation(reservationData: Reservation, serviceSuccessHandler:@escaping (_ responseValue:Any) -> Void,  serviceFailureHandler:@escaping (_ errorValue:Any) -> Void) {
        
        var promoCodes = [String]()
        if let arrayPromocodes = reservationData.promoCodes {
            for promocode in arrayPromocodes {
                if let code = promocode.code, promocode.code != "" {
                    promoCodes.append(code)
                }
            }
        }
        
        var payRate = reservationData.selectedCar!.payLaterRate
        if reservationData.prepaid == "Y" {
            payRate = reservationData.selectedCar!.payNowRate
        }
        
        var parameters = [
                          "pickup_date_time": reservationData.rentalDateTime!,
                          "pickup_date": reservationData.pickUpdate!,
                          "pickup_time":  reservationData.pickUptime!,
                          "pickup_date_formatted": reservationData.pickupDateFormatted!,
                          
                          "dropoff_date_time":  reservationData.returnDateTime!,
                          "dropoff_date":  reservationData.dropOffDate!,
                          "dropoff_time":  reservationData.dropOffTime!,
                          "dropoff_date_formatted": reservationData.dropoffDateFormatted!,
                          
                          "rental_location_id": reservationData.rentalLocationId!,
                          "rental_location_name": reservationData.rentalLocation!.addLine1!,
                          "rental_location_street": reservationData.rentalLocation!.addLine2!,
                          "rental_location_city": reservationData.rentalLocation!.city!,
                          "rental_location_state": reservationData.rentalLocation!.state!,
                          "rental_location_zip": reservationData.rentalLocation!.postalCode!,
                          "rental_location_country": reservationData.rentalLocation!.country!,
                          
                          "return_location_id": reservationData.returnLocationId!,
                          "return_location_name": reservationData.returnLocation!.addLine1!,
                          "return_location_street": reservationData.returnLocation!.addLine2!,
                          "return_location_city": reservationData.returnLocation!.city!,
                          "return_location_state": reservationData.returnLocation!.state!,
                          "return_location_zip": reservationData.returnLocation!.postalCode!,
                          "return_location_country": reservationData.returnLocation!.country!,
                          
                          "promo_codes":promoCodes,
                          
                          "prepaid": reservationData.prepaid!,
                          
                          "renter_first": reservationData.renterProfile!.firstName!,
                          "renter_last": reservationData.renterProfile!.lastName!,
                          "email_address": reservationData.renterProfile!.email!,
                          "renter_home_phone": reservationData.renterProfile!.phoneNumber!,
                          "renter_address1": reservationData.renterProfile!.streetAddress!,
                          "renter_city":  reservationData.renterProfile!.city!,
                          "renter_state":  reservationData.renterProfile!.state!,
                          "renter_zip":  reservationData.renterProfile!.postalCode!,
                          
                          "rate_id": reservationData.selectedCar!.rateID!,
                          "class_code": reservationData.selectedCar!.classCode!,
                          "class_name":reservationData.selectedCar!.category!,
                          "ClassImageURL": reservationData.selectedCar!.classImageURL!,
                          "FullClassImageURL": reservationData.selectedCar!.classImageURL2!,
                          "ClassDesc": reservationData.selectedCar!.classDesc!,
                          "ModelDesc": reservationData.selectedCar!.modelDesc!,
                          "RatePlan": reservationData.selectedCar!.ratePlan!,
                          "rate_period_label": reservationData.selectedCar!.ratePeriodLabel!,
                          
                          "RateAmount": payRate.rateAmount!,
                          "daily_rate": payRate.dailyRate!,
                          "RateCharge": payRate.rateCharge!,
                          "TotalCharges": payRate.totalRate!,
                          "TotalTaxes": payRate.totalTaxes!,
                          "TotalExtras": payRate.totalExtras!,
                          
                          "payment_type_total": reservationData.payment_type_total,
                          "base_url": reservationData.base_url,
                          "keep_promo_codes": reservationData.keep_promo_codes,
                          "CurrencyCodeDisplay": reservationData.selectedCar!.currencyCode!,
                          "services_url": ServiceConstants.kServicesURL,
                          "logging_url": ServiceConstants.kLogginURL] as [String : Any]
        
        if let dailyExtraList = reservationData.vehicleOptions {
            parameters["vehicleOptions"] = dailyExtraList
        }
        
        /*IMPORTANT
            Call /addReservation for PAY LATER
            and https://devrezbookmobile.aezrac.com/api/v1/preAddRez for PAY NOW
         */
        
        if reservationData.prepaid == "Y" {
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
        
        
    }
}

//rental_location_id:MCOEZ
//return_location_id:MCOEZ
//pickup_date_time:09012018 11:00 AM
//pickup_date:09012018
//pickup_time:11:00 AM
//dropoff_date_time:09042018 09:00 AM
//dropoff_date:09042018
//dropoff_time:09:00 AM
//prepaid:N
//rate_id:1384832
//class_code:SCAR
//class_name:Standard
//renter_first:Rez
//renter_last:Booking
//email_address:slatsa@aezrac.com
//renter_home_phone:407-775-4336
//renter_address1:7652 Narcoossee Road
//renter_city:Orlando
//renter_state:FL
//renter_zip:32822
//promo_code[]:GOV
//promo_code[]:CD0325870D
//promo_code[]:01642012
//promo_code[]:36C15169
//ClassImageURL:/wp-content/plugins/advantage-vehicles/assets/SCAR_800x400.png
//FullClassImageURL:https://static.europcar.com/carvisuals/partners/835x557/ECMR_TR.png
//ClassDesc:Standard 2/4 Door Automatic With AC
//ModelDesc:Hyundai Sonata
//RatePlan:DAILY
//daily_rate:15.00
//rate_period_label:day
//RateAmount:15.00
//RateCharge:45.00
//TotalTaxes:34.22
//TotalExtras:0.00
//TotalCharges:79.22
//payment_type_total:TOTAL PAID
//pickup_date_formatted:Saturday - April 1, 2017
//rental_location_name:ORLANDO INTERNATIONAL AIRPORT
//rental_location_street:1 AIRPORT BLVD
//rental_location_city:ORLANDO
//rental_location_state:FL
//rental_location_zip:32827
//rental_location_country:US
//dropoff_date_formatted:Tuesday - April 4, 2017
//return_location_name:ORLANDO INTERNATIONAL AIRPORT
//return_location_street:1 AIRPORT BLVD
//return_location_city:ORLANDO
//return_location_state:FL
//return_location_zip:32827
//return_location_country:US
//base_url:http://consumer.dev
//keep_promo_codes:Y
//CurrencyCodeDisplay:USD
//services_url:https://services2.aezrac.com/webapi/aezrac.asmx
//logging_url:https://services2.aezrac.com/logging

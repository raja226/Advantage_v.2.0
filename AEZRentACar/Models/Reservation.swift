//
//  Reservation.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 5/24/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit

class Reservation: NSObject {
    static var sharedInstance: Reservation? = Reservation()
    
    //FIXME: resetSharedInstance method does not work
    class func resetSharedInstance() {
        sharedInstance = nil
    }
    
    var rentalLocationId: String?
    var returnLocationId: String?
    
    var rentalLocation: RatesLocation?
    var returnLocation: RatesLocation?
    
    var pickUpDateTime: String?
    var dropOffDateTime: String?
    var pickUpdate: String?
    var pickUptime: String?
    var dropOffDate: String?
    var dropOffTime: String?
    
    var rentalDateTime : String?
    var returnDateTime : String?
    
    var promoCodes: [PromoCode]?
    var vehicleOptions: [String]?

    
    var selectedCar: Vehicle?
    
    var renterProfile: UserLoyaltyProfile?
    
    var pickupDateFormatted: String?
    var dropoffDateFormatted: String?
    
    var prepaid: String?
    
    // Hardcoded for /addReservation API
    let payment_type_total = "TOTAL PAID"
    let keep_promo_codes = "N"
    let base_url = "http://consumer.dev"
    
//    //FIXME: Hardcoded for development purpose
//    let renterFirst = "Rez"
//    let renterLast = "Booking"
    
    var confirmationNumber: String?
    var billingProfile: UserLoyaltyProfile?
    var cardType: String?
    var cardNumber: String?
    
    var status: String? 
    
    
    //FIXME: Find proper way for clearing object
    func clearObject() {
        Reservation.sharedInstance?.selectedCar?.payLaterRate.totalTaxes = nil
        Reservation.sharedInstance?.selectedCar?.payNowRate.totalTaxes = nil
    }
    
    var pickUpdateAsDate = Date()
    
    // Calculate minimum data of birth
    // For Advantage its rental date - 21 Years
    // For E-Z its rental date - 18 Years
    func maximumDateOfBirth() -> Date {
        let dateEighteenYearsAgo = Calendar.current.date(byAdding: .year, value: -21, to: pickUpdateAsDate)
        return dateEighteenYearsAgo!
    }
    
    func minimumDateOfBirth() -> Date {
        let calendar = Calendar.current
        let components = DateComponents(year: 1900, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        return calendar.date(from: components)!
    }
}

/*
 rental_location_id:JFK
 return_location_id:LAX
 pickup_date_time:04012017 11:00 AM
 dropoff_date_time:04042017 09:00 AM
 prepaid:Y
 rate_id:1384832
 class_code:SCAR
 class_name:Standard
 renter_first:Rez
 renter_last:Booking
 email_address:slatsa@aezrac.com
 renter_home_phone:407-775-4336
 renter_address1:7652 Narcoossee Road
 renter_city:Orlando
 renter_state:FL
 renter_zip:32822
 promo_code[]:GOV
 promo_code[]:CD0325870D
 ClassImageURL:/wp-content/plugins/advantage-vehicles/assets/SCAR_800x400.png
 FullClassImageURL:https://static.europcar.com/carvisuals/partners/835x557/ECMR_TR.png
 ClassDesc:Standard 2/4 Door Automatic With AC
 ModelDesc:Hyundai Sonata
 RatePlan:DAILY
 daily_rate:15.00
 rate_period_label:day
 RateAmount:15.00
 RateCharge:45.00
 TotalTaxes:34.22
 TotalExtras:0.00
 TotalCharges:79.22
 payment_type_total:TOTAL PAID
 pickup_date_formatted:Saturday - April 1, 2017
 dropoff_date_formatted:Tuesday - April 4, 2017
 
 ****Will be in renterProfile****
 rental_location_name:ORLANDO INTERNATIONAL AIRPORT
 rental_location_street:1 AIRPORT BLVD
 rental_location_city:ORLANDO
 rental_location_state:FL
 rental_location_zip:32827
 rental_location_country:US
 return_location_name:ORLANDO INTERNATIONAL AIRPORT
 return_location_street:1 AIRPORT BLVD
 return_location_city:ORLANDO
 return_location_state:FL
 return_location_zip:32827
 return_location_country:US
 
 base_url:http://consumer.dev
 keep_promo_codes:Y
 
 */

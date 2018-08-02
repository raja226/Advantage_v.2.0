//
//  AEZCar.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 5/19/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import SwiftyJSON

class AEZRates: NSObject {
    var vehicles = [Vehicle]()
    var sortOptions = [VehicleSortOption]()
    var rentalLocation:RatesLocation?
    var returnLocation:RatesLocation?
    var promoCodes: [PromoCode]?
    
    init(responseJSON : JSON) {
        
        var promocodeList = [PromoCode]()
        let promoCodeJSON = responseJSON["Payload"]["PromoCodeResponse"]["PromoCodeEntered"]
        if promoCodeJSON.type == .array {
            for promoCodeJSON in responseJSON["Payload"]["PromoCodeResponse"]["PromoCodeEntered"] {
                promocodeList.append(PromoCode(promoCodeJSON: promoCodeJSON.1))
            }
        } else {
            promocodeList.append(PromoCode(promoCodeJSON: promoCodeJSON))
        }
        if promocodeList.count > 0 {
            self.promoCodes = promocodeList
        }
        
        var carList = [Vehicle]()
        for carJSON in responseJSON["Payload"]["RateProduct"] {
            carList.append(Vehicle(carJSON: carJSON.1))
        }
        self.vehicles = carList
        
        var sortOptionList = [VehicleSortOption]()
        for sortOptionJSON in responseJSON["Payload"]["Options"]["SortOptions"] {
            sortOptionList.append(VehicleSortOption(sortOptionJSON: sortOptionJSON.1))
        }
        self.sortOptions = sortOptionList
        
        self.rentalLocation = RatesLocation(locationJSON: responseJSON["Payload"]["RentalLocation"])
        
        let returnLocationJSON = responseJSON["Payload"]["ReturnLocation"]
        if returnLocationJSON != JSON.null {
            self.returnLocation = RatesLocation(locationJSON: returnLocationJSON)
        } else {
            self.returnLocation = self.rentalLocation
        }
    }
}

class VehicleSortOption: NSObject {
    var value: String?
    var name: String?
    var selected: String?
    
    init(sortOptionJSON : JSON) {
        
        if let value = sortOptionJSON["value"].string {
            self.value = value
        }
        
        if let name = sortOptionJSON["name"].string {
            self.name = name
        }
        
        if let selected = sortOptionJSON["selected"].string {
            self.selected = selected
        }
    }
}

class PromoCode: NSObject {
    var code: String?
    var status: String?
    var message: String?
    
    var state: String = ""
    
    init(promoCodeJSON : JSON) {
        
        if let code = promoCodeJSON["PromoCode"].string {
            self.code = code
        }
        
        if let status = promoCodeJSON["PromoStatus"].string {
            self.status = status
        }
        
        if let message = promoCodeJSON["PromoMsg"].string {
            self.message = message
        }
    }
}

class RatesLocation: NSObject {
    var addLine1: String?
    var addLine2: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?
    var phoneNumber: String?
    var alternatePhoneNumber: String?
    
    init(locationJSON : JSON) {
        
        if let addressLine1 = locationJSON["AddressLine1"].string {
            self.addLine1 = addressLine1
        }
        
        if let addressLine2 = locationJSON["AddressLine2"].string {
            self.addLine2 = addressLine2
        } else {
            self.addLine2 = ""
        }
        
        if let addressCity = locationJSON["AddressCity"].string {
            self.city = addressCity
        } else {
            self.city = ""
        }
        
        if let addressState = locationJSON["AddressState"].string {
            self.state = addressState
        } else {
            self.state = ""
        }
        
        if let addressZipCode = locationJSON["AddressZipCode"].string {
            self.postalCode = addressZipCode
        } else {
            self.postalCode = ""
        }
        
        if let addressCountry = locationJSON["AddressCountry"].string {
            self.country = addressCountry
        } else {
            self.country = ""
        }
        
        if let phoneNumber = locationJSON["PhoneNumber"].string {
            self.phoneNumber = phoneNumber
        } else {
            self.phoneNumber = ""
        }
        
        if let altPhoneNumber = locationJSON["AltPhoneNumber"].string {
            self.alternatePhoneNumber = altPhoneNumber
        } else {
            self.alternatePhoneNumber = ""
        }
    }
    
    /*
     
     "AddressLine1": "ORLANDO INTERNATIONAL AIRPORT",
     "AddressLine2": "1 AIRPORT BLVD",
     "AddressCity": "ORLANDO",
     "AddressState": "FL",
     "AddressZipCode": "32827",
     "AddressCountry": "US",
     "PhoneNumber": "(800) 777-5500",
     "AltPhoneNumber": "407-203-1204"
 
     */
}

class VehicleRate: NSObject {
    // dailyRate and totalRate assign first value from /getRates then update from /requestBill
    var dailyRate: String?
    var rateAmount: String?
    var rateCharge: String?
    var totalRate: String?
    
    // Following values will be assigned from /requestBill API
    var taxes: [AEZTax]?
    var extras: [AEZExtra]?
    var totalTaxes: String?
    var totalExtras: String?
    var discountPercent: String?
    var discountAmount: String?
}

class Vehicle: NSObject {
    var classCode: String?
    var category: String?
    var modelDesc: String?
    var classDesc: String?
    
    var classImageURL: String?
    var classImageURL2: String?
    
    var passengers: String?
    var luggage: String?
    var type: String?
    var airConditioning: String?
    var transmission: String?
    var mpgCity: String?
    var mpgHighway: String?
    
    var upgrade: Int?
    var liveALittle: Int?
    
    var rateID: String?
    var ratePlan: String?
    
    var ratePeriodLabel: String?
    
    var currencyCode: String?
    
    var payNowRate = VehicleRate()
    var payLaterRate = VehicleRate()
    
    var hasPostpaidOnly = false
    
    init(carJSON : JSON) {
        
        if let classCode = carJSON["ClassCode"].string {
            self.classCode = classCode
        }
        
        if let classImageURL = carJSON["ClassImageURL"].string {
            self.classImageURL = classImageURL
        }
        
        if let classImageURL2 = carJSON["ClassImageURL2"].string {
            self.classImageURL2 = classImageURL2
        }
        
        if let modelDesc = carJSON["ModelDesc"].string {
            self.modelDesc = modelDesc
        }
        
        if let classDesc = carJSON["ClassDesc"].string {
            self.classDesc = classDesc
        }
        
        if let category = carJSON["Category"].string {
            self.category = category
        }
        
        if let passengers = carJSON["Passengers"].string {
            self.passengers = passengers
        }
        
        if let luggage = carJSON["Luggage"].string {
            self.luggage = luggage
        }
        
        if let mpgCity = carJSON["MPGCity"].string {
            self.mpgCity = mpgCity
        }
        
        if let mpgHighway = carJSON["MPGHighway"].string {
            self.mpgHighway = mpgHighway
        }
        
        if let type = carJSON["Type"].string {
            self.type = type
        }
        
        if let airConditioning = carJSON["AC"].string {
            self.airConditioning = airConditioning
        }
        
        if let transmission = carJSON["Transmission"].string {
            self.transmission = transmission
        }
        
        if let upgrade = carJSON["upgrade"].int {
            self.upgrade = upgrade
        }
        
        if let liveALittle = carJSON["live_a_little"].int {
            self.liveALittle = liveALittle
        }
        
        if let rateID = carJSON["RateID"].string {
            self.rateID = rateID
        }
        
        self.ratePeriodLabel = "day"
        if let ratePlan = carJSON["RatePlan"].string {
            self.ratePlan = ratePlan
            if ratePlan == "WEEKLY" {
                self.ratePeriodLabel = "week"
            }
        }
        
        if let currencyCode = carJSON["CurrencyCode"].string {
            self.currencyCode = currencyCode
        }
        
        if let payLaterRateAmount = carJSON["RateAmount"].string {
            self.payLaterRate.rateAmount = payLaterRateAmount
        }
        
        if let payNowRateAmount = carJSON["Prepaid"]["RateAmount"].string {
            self.payNowRate.rateAmount = payNowRateAmount
        }
        
        if let payLaterDailyRate = carJSON["TotalPricing"]["RatePeriod"]["Rate1PerDay"].string {
            self.payLaterRate.dailyRate = payLaterDailyRate
        }
        
        if let payLaterTotalRate = carJSON["TotalPricing"]["TotalCharges"].string {
            self.payLaterRate.totalRate = payLaterTotalRate
        }
        
        if let payLaterRateCharge = carJSON["TotalPricing"]["RateCharge"].string {
            self.payLaterRate.rateCharge = payLaterRateCharge
        }
        
        if let payNowDailyRate = carJSON["Prepaid"]["TotalPricing"]["RatePeriod"]["Rate1PerDay"].string {
            self.payNowRate.dailyRate = payNowDailyRate
        }
        
        if let payNowTotalRate = carJSON["Prepaid"]["TotalPricing"]["TotalCharges"].string {
            self.payNowRate.totalRate = payNowTotalRate
        }
        
        if let payNowRateCharge = carJSON["Prepaid"]["TotalPricing"]["RateCharge"].string {
            self.payNowRate.rateCharge = payNowRateCharge
        }
        
        if let _ = carJSON["Prepaid"].dictionary {
            self.hasPostpaidOnly = false
        } else {
            self.hasPostpaidOnly = true
        }
    }
}

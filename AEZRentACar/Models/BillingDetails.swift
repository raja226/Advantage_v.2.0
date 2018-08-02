//
//  BillingDetails.swift
//  AEZRentACar
//
//  Created by Anjali Panjwani on 16/06/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import SwiftyJSON


class AEZTax {
    var taxDescription = ""
    var taxCharge = ""
}

class AEZExtra {
    var extraCode = ""
    var extraDescription = ""
    var extraAmount = ""
    var extraAutoApply = ""
    
    init(responseJSON : JSON) {
        if let value = responseJSON["ExtraCode"].string {
            self.extraCode = value
        }
        
        if let value = responseJSON["ExtraDesc"].string {
            self.extraDescription = value
        }
        
        if let value = responseJSON["ExtraAmount"].string {
            self.extraAmount = value
        }
        
        if let value = responseJSON["ExtraAutoApply"].string {
            self.extraAutoApply = value
        }
    }
}

class Tax {
    var taxKey = ""
    var taxValue = ""
    
    init(key: String, value: String) {
        self.taxKey = key
        self.taxValue = value
    }
}

class BillingDetails: NSObject {
    
    var dailyRate: String?
    var rateCharge: String?
    var totalCharges: String?
    var promoCodes = [PromoCode]()
    
    var taxesTotal: String = ""
    var extrasTotal: String = ""
    
    var discountPercent: String?
    var discountAmount: String?
    
    var taxes = [AEZTax]()
    var extras = [AEZExtra]()
    
    init(responseJSON : JSON) {
        
        if let dailyRate = responseJSON["Payload"]["RatePeriod"]["Rate1PerDay"].string {
            self.dailyRate = dailyRate
        }
        
        if let totalCharges = responseJSON["Payload"]["TotalCharges"].string {
            self.totalCharges = totalCharges
        }
        
        if let rateCharge = responseJSON["Payload"]["RateCharge"].string {
            self.rateCharge = rateCharge
        }
        
        if let rateDiscount = responseJSON["Payload"]["RateDiscount"].string {
            self.discountAmount = rateDiscount
        }
        
        var promocodeList = [PromoCode]()
        let promoCodeJSON = responseJSON["Payload"]["PromoCodeResponse"]["PromoCodeEntered"]
        if promoCodeJSON.type == .array {
            for promoCodeJSON in responseJSON["Payload"]["PromoCodeResponse"]["PromoCodeEntered"] {
                promocodeList.append(PromoCode(promoCodeJSON: promoCodeJSON.1))
            }
        } else {
            promocodeList.append(PromoCode(promoCodeJSON: promoCodeJSON))
        }
        self.promoCodes = promocodeList
        
        let allTaxesKeys = responseJSON["Payload"]["Taxes"].dictionary?.keys
        var allFilteredKeys = [String]()
        for taxKey in allTaxesKeys! {
            var index = taxKey.index(taxKey.startIndex, offsetBy: 5)
            let firstFiveCharString = taxKey.substring(to: index)
            
            index = firstFiveCharString.index(firstFiveCharString.startIndex, offsetBy: 4)
            if let _ = Int(firstFiveCharString.substring(from: index)) {
                allFilteredKeys.append(firstFiveCharString)
            } else {
                index = firstFiveCharString.index(firstFiveCharString.startIndex, offsetBy: 4)
                allFilteredKeys.append(firstFiveCharString.substring(to: index))
            }
        }
        let unique = Array(Set(allFilteredKeys)).sorted{ $0 < $1 }
        var aTaxes = [AEZTax]()
        for taxkey in unique {
            let taxDescriptionKey = taxkey + "Desc"
            let taxChargeKey = taxkey + "Charge"
            
            let aezTax = AEZTax()
            if let taxCharge = responseJSON["Payload"]["Taxes"][taxChargeKey].string {
                aezTax.taxCharge = taxCharge
            }
            if let taxDesc = responseJSON["Payload"]["Taxes"][taxDescriptionKey].string {
                aezTax.taxDescription = taxDesc
            }
            
            aTaxes.append(aezTax)
        }

        self.taxes = aTaxes

        var aezExtras = [AEZExtra]()
        let extraInfoJSON = responseJSON["Payload"]["DailyExtra"]
        if extraInfoJSON.type == .array {
            for tempJSON in extraInfoJSON {
                aezExtras.append(AEZExtra(responseJSON: tempJSON.1))
            }
        } else {
            aezExtras.append(AEZExtra(responseJSON: extraInfoJSON))
        }
        self.extras = aezExtras
        
        if let taxTotal = responseJSON["Payload"]["TotalTaxes"].string {
            self.taxesTotal = taxTotal
        }
        
        if let extraTotal = responseJSON["Payload"]["TotalExtras"].string {
            self.extrasTotal = extraTotal
        }
    }
}

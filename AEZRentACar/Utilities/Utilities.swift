//
//  Utilities.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/18/17.
//  Copyright © 2017 Cybage. All rights reserved.
//


import UIKit
import CryptoSwift

class Utilities: NSObject {
    // Can't init is singleton
    private override init() { }
    
    //MARK: Shared Instance
    
    static let sharedInstance: Utilities = Utilities()
    
    func generatePasswordHash(_ password: String)->String {
        let bytes = Array(password.utf8)
        do {
            let hmac = try HMAC(key: "secret", variant: .sha256).authenticate(bytes)
            print(hmac.toBase64())
        }
        catch  {
            
        }
        
        let base64 = bytes.toBase64()
        return base64!
    }
    
    func validateEmail(enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
    
    func validatePostalCode(enteredPostalCode: String) -> Bool {
        let psFormat = "^[0-9]{5}(-[0-9]{4})?$"
        let psPredicate = NSPredicate(format:"SELF MATCHES %@", psFormat)
        return psPredicate.evaluate(with: enteredPostalCode)
    }
    
    func locationAddress(location: RatesLocation) -> String {
        var locationInformationText = ""
        var shouldAddComma = false
        
        if let addLine2 = location.addLine2, !addLine2.isEmpty {
            locationInformationText = locationInformationText.appending("\(addLine2)")
            shouldAddComma = true
        }
        
        if let city = location.city, !city.isEmpty {
            if shouldAddComma {
                locationInformationText = locationInformationText.appending(", ")
            }
            locationInformationText = locationInformationText.appending("\(city)")
            shouldAddComma = true
        } else {
            shouldAddComma = false
        }
        
        if let state = location.state, !state.isEmpty {
            if shouldAddComma {
                locationInformationText = locationInformationText.appending(", ")
            }
            locationInformationText = locationInformationText.appending("\(state)")
            shouldAddComma = true
        } else {
            shouldAddComma = false
        }
        
        if let postalCode = location.postalCode, !postalCode.isEmpty {
            if shouldAddComma {
                locationInformationText = locationInformationText.appending(" ")
            }
            locationInformationText = locationInformationText.appending("\(postalCode)")
        }
        return locationInformationText
    }
    
    class func displayRateWithCurrency(rate: String, currency: String?) -> String {
        var displayRate = rate
        if let currencyCode = currency {
            if currencyCode == "USD" {
                displayRate = "$ \(rate)"
            } else if currencyCode == "EUR" {
                displayRate = "\u{20AC} \(rate)"
            } else {
                displayRate = "\(currencyCode) \(rate)"
            }
        }
        return displayRate
    }
}

//
//  UserLoyaltyProfile.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 5/10/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import SwiftyJSON

class UserLoyaltyProfile: NSObject {

    var loyaltyID: Double?
    var memberNumber: Double?
    var iata: Double?
    var dateOfBirth: String?
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var email: String?
    var streetAddress: String?
    var streetAddressTwo: String?
    var postalCode: String?
    var city: String?
    var state: String?
    var country: String? = "US"
    var preferredRentalLocationCode: String?
    var preferredReturnLocationCode: String? 

    
    
    
    override init() {
        
    }
    
    init(loyaltyJSON : JSON) {
        print(loyaltyJSON)
        if let loyaltyID = loyaltyJSON["LoyaltyID"].double {
            self.loyaltyID = loyaltyID
        }
        
        if let memberNumber = loyaltyJSON["memberNumber"].double {
            self.memberNumber = memberNumber
        }
        
        if let iata = loyaltyJSON["IATA"].double {
            self.iata = iata
        }
        
        if let dateOfBirth = loyaltyJSON["DOB"].string {
            self.dateOfBirth = dateOfBirth
        }
        
        if let lastName = loyaltyJSON["LastName"].string {
            self.lastName = lastName
        }
        
        if let firstName = loyaltyJSON["FirstName"].string {
            self.firstName = firstName
        }
        
        if let phoneNumber = loyaltyJSON["MobileNumber"].string {
            self.phoneNumber = phoneNumber
        }
        
        if let streetAddress = loyaltyJSON["AddressLine1"].string {
            self.streetAddress = streetAddress
        }
        
        if let streetAddressTwo = loyaltyJSON["AddressLine2"].string {
            self.streetAddressTwo = streetAddressTwo
        }
        
        if let city = loyaltyJSON["City"].string {
            self.city = city
        }
        
        if let state = loyaltyJSON["State"].string {
            self.state = state
        }
        
        if let postalCode = loyaltyJSON["PostalCode"].string {
            self.postalCode = postalCode
        }
        
        if let country = loyaltyJSON["Country"].string {
            self.country = country
        }
        if let email = loyaltyJSON["Email"].string {
            self.email = email
        }
        if let preferredRentalLocationCode = loyaltyJSON["PreferredRentalLocationCode"].string {
            self.preferredRentalLocationCode = preferredRentalLocationCode
            
            //UserDefaults.standard.set( self.preferredRentalLocationCode, forKey: "PreferredRentalLocationCode")
        }
        if let preferredReturnLocationCode = loyaltyJSON["PreferredDropoffLocationCode"].string {
            self.preferredReturnLocationCode = preferredReturnLocationCode
           // UserDefaults.standard.set( self.preferredReturnLocationCode, forKey: "PreferredReturnLocationCode")
        }
        
       
    }
}



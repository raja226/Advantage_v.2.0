//
//  ServiceConstants.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 8/10/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit

struct ServiceConstants {
    
    private struct Domains {
        static let Dev = "https://devapi.advantage.com"
        static let Dev2 = "https://devrezbookmobile.aezrac.com"
        //QA
        //static let QA = "https://qapi.advantage.com"
        //New QA:
         //static let QA = "https://newqa.advantage.com"
        static let UAT = ""
        static let Production = "https://rezbookapi.aezrac.com"
    }
    
    private struct Routes {
        static let Api = "/api/v1"
    }
    //QA
    //private static let Domain = Domains.QA
    
    //private static let Domain = Domains.Dev
    
    private static let Domain = Domains.Production
    private static let Route = Routes.Api
    private static let BaseURL = Domain + Route
    
    private struct ServiceAndLogDomains {
        static let Dev = "https://devapi.aezrac.com"
        static let Production = "https://api.aezrac.com"
    }
    
    private static let ServiceAndLogBaseURL =
        //ServiceAndLogDomains.Production
        
        ServiceAndLogDomains.Dev
    
    static var user: String {
        return BaseURL + "/user"
    }
    
    static var searchLocationsByBrands: String {
        return BaseURL + "/searchLocationsByBrands"
    }
    
    static var getLoyaltyProfile: String {
        return BaseURL + "/getLoyaltyProfileMobile"
    }
    
    static var logoutUser: String {
        return BaseURL + "/logout-user"
    }
    
    static var userLogin: String {
        return BaseURL + "/login"
    }
    
    static var getUSStates: String {
        return BaseURL + "/getUSStates"
    }
    
    static var getCountries: String {
        return BaseURL + "/getCountries"
    }
    
    static var getRates: String {
        return BaseURL + "/getRatesMobile"
    }
    
    static var getPolicy: String {
        return BaseURL + "/getPolicy"
    }
    
    static var getTermsAndConditions: String {
        return BaseURL + "/getMobileTermsAndConditions"
    }
    
    static var requestBill: String {
        return BaseURL + "/requestBillMobile"
    }
    // Forgot Password
    
    static var forgotpassword: String {
        return BaseURL + "/forgetPassword"
    }
    // View Reservation
    static var viewReservation: String {
        return BaseURL + "/viewReservation"
    }
    // Cancel Reservation
    static var cancelReservation: String {
        return BaseURL + "/cancelReservation"
    }
    
    // get Locations
    static var getLocations: String {
        return BaseURL + "/getLocations?"
    }

    // FOR PAY LATER
    static var addReservation: String {
        return BaseURL + "/addReservationMobile"
    }
    
    // FOR PAY NOW
    static var preAddReservation: String {
        return BaseURL + "/preAddRez"
    }
    
    
    //MARK: - Services and Loggin URL Constants
    static var kServicesURL: String {
        return ServiceAndLogBaseURL + "/webapi/aezrac.asmx"
    }
    
    static var kLogginURL: String {
        return ServiceAndLogBaseURL + "/logging"
    }
    //Base URL 
    static var kBaseURL: String {
        return BaseURL
    }
}

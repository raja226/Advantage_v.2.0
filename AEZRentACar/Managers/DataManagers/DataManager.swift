//
//  DataManager.swift
//  SearchBarPOC
//
//  Created by ishan on 21/03/17.
//  Copyright © 2017 ishan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum Services {
    case searchLocationService
}

class DataManager: NSObject {
    
    // Can't init is singleton
    private override init() { }
    
    //MARK: Shared Instance
    static let sharedInstance: DataManager = DataManager()
    var controllersArray = Dictionary<String,NSObject>()
    
    //MARK: GET Locations service
    func searchLocationServiceCall(_ keyword : String,serviceSuccessHandler:@escaping (_ responseValue:[Location]) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        cancelSearchLocationServiceCall()
        let searchServiceController = SearchLocationServiceController()
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            let locationArray = SearchLocationServiceResponseParser().parseSearchServiceResponse(locationData: responseValue)
            self?.controllersArray["searchServiceController"] = nil
            serviceSuccessHandler(locationArray)
        }
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            serviceFailureHnadler(errorValue)
        }
        
        searchServiceController.searchLocationWith(keyword,serviceSuccessHandler: serviceSuccessHandler, serviceFailureHnadler: serviceFailureHandler)
        controllersArray["searchServiceController"] = searchServiceController
    }
    
    func cancelSearchLocationServiceCall() {
        let searchServiceController = controllersArray["searchServiceController"] as? SearchLocationServiceController
        searchServiceController?.request?.cancel()
    }
    
    //MARK: Login service
    func loginServiceCall(_ username: String, _ password: String, serviceSuccessHandler:@escaping (_ responseValue:Login) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        let loginServiceController = LoginServiceController()
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            self.controllersArray["loginServiceController"] = nil
            serviceFailureHnadler(errorValue)
        }
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            let loginResult = LoginServiceResponseParser().parseLoginServiceResponse(loginData: responseValue)
            if loginResult.success {
                serviceSuccessHandler(loginResult.login!)
            } else {
                serviceFailureHandler(loginResult.message as Any)
            }
            
            self?.controllersArray["loginServiceController"] = nil
        }
        
        loginServiceController.login(username, password, serviceSuccessHandler: serviceSuccessHandler, serviceFailureHnadler: serviceFailureHandler)
        controllersArray["loginServiceController"] = loginServiceController
    }
    
    //MARK: GetUSStates service
    func getUSStatesServiceCall(_ brand: String,serviceSuccessHandler:@escaping (_ responseValue:[USState]) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        let getUSStatesServiceController = GetUSStatesServiceController()
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            let parsorResult = GetUSStatesServiceResponseParser().parseUSStatesServiceResponse(usstates: responseValue)
            self?.controllersArray["getUSStatesServiceController"] = nil
            if parsorResult.success {
                serviceSuccessHandler(parsorResult.stateList)
            } else {
                serviceFailureHnadler(parsorResult.stateList)
            }
        }
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            self.controllersArray["getUSStatesServiceController"] = nil
            serviceFailureHnadler(errorValue)
        }
        getUSStatesServiceController.getUSStates(brand, serviceSuccessHandler: serviceSuccessHandler, serviceFailureHnadler: serviceFailureHandler)
        controllersArray["getUSStatesServiceController"] = getUSStatesServiceController
    }

    //MARK: GetCountries service
    func getCountriesServiceCall(_ brand: String,serviceSuccessHandler:@escaping (_ responseValue:[Country]) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        let getCountriesServiceController = GetCountriesServiceController()
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            let parsorResult = GetCountriesServiceResponseParser().parseCountriesServiceResponse(countries: responseValue)
            self?.controllersArray["getCountriesServiceController"] = nil
            if parsorResult.success {
                serviceSuccessHandler(parsorResult.countryList)
            } else {
                serviceFailureHnadler(parsorResult.countryList)
            }
        }
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            self.controllersArray["getCountriesServiceController"] = nil
            serviceFailureHnadler(errorValue)
        }
        getCountriesServiceController.getCountries(brand, serviceSuccessHandler: serviceSuccessHandler, serviceFailureHnadler: serviceFailureHandler)
        controllersArray["getCountriesServiceController"] = getCountriesServiceController
    }
    
    //MARK: GetFormattedTermsAndConditionsService service
    func getFormattedTermsAndConditionsServiceCall(_ brand: String, locationId: String, serviceSuccessHandler:@escaping (_ responseValue:String) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        let getFormattedTermsAndConditionsServiceController = GetFormattedTermsAndConditionsServiceController()
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            let serviceResult = GetFormattedTermsAndConditionsServiceResponseParser().parseFormattedTermsAndConditionsServiceResponse(policyData: responseValue)
            if serviceResult.success {
                serviceSuccessHandler(serviceResult.termsText)
            } else {
                serviceFailureHnadler(serviceResult.termsText)
            }
            self?.controllersArray["getFormattedTermsAndConditionsServiceController"] = nil
        }
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            self.controllersArray["getFormattedTermsAndConditionsServiceController"] = nil
            serviceFailureHnadler(errorValue)
        }
        getFormattedTermsAndConditionsServiceController.getFormattedTermsAndConditions(brand, locationId, serviceSuccessHandler: serviceSuccessHandler, serviceFailureHnadler: serviceFailureHandler)
        controllersArray["getFormattedTermsAndConditionsServiceController"] = getFormattedTermsAndConditionsServiceController
    }
    
    //MARK: User service : To check if the token is valid or not. This will be executed on get started page to determine is user token is valid.
    func getUser(_ token: String, serviceSuccessHandler:@escaping (_ responseValue:User) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        let userServiceController = UserServiceController()
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            self.controllersArray["userServiceController"] = nil
            serviceFailureHnadler(errorValue)
        }
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            self?.controllersArray["userServiceController"] = nil
            let userResult = UserServiceResponseParser().parseUserServiceResponse(userData: responseValue)
            if userResult.success {
                serviceSuccessHandler(userResult.user!)
            } else {
                serviceFailureHandler(responseValue)
            }
        }
        
        userServiceController.getUser(token, serviceSuccessHandler: serviceSuccessHandler, serviceFailureHnadler: serviceFailureHandler)
        controllersArray["userServiceController"] = userServiceController
    }
    
    //MARK: GET Loyalty Profile
    func getLoyaltyProfileCall(memberNumber: Double, serviceSuccessHandler:@escaping (_ responseValue:UserLoyaltyProfile) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        
        let loyaltyProfileServiceController = LoyaltyProfileServiceController()
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            self.controllersArray["loyaltyProfileServiceController"] = nil
            serviceFailureHnadler(errorValue)
        }
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            let loyaltyProfileResult = LoyaltyProfileServiceResponseParser().parseGetLoyaltyProfileServiceResponse(loyaltyProfileData: responseValue)
            
            if loyaltyProfileResult.success {
                serviceSuccessHandler(loyaltyProfileResult.loyaltyProfile!)
            } else {
                serviceFailureHandler(loyaltyProfileResult.message!)
            }
            self?.controllersArray["loyaltyProfileServiceController"] = nil
        }
        
        loyaltyProfileServiceController.getLoyaltyProfile(memberNumber: memberNumber, serviceSuccessHandler: serviceSuccessHandler , serviceFailureHnadler: serviceFailureHandler)
        controllersArray["loyaltyProfileServiceController"] = loyaltyProfileServiceController
    }
    
    //MARK: POST Logout
    func postLogoutCall(accessToken: String, email: String, serviceSuccessHandler:@escaping (_ responseValue:Any) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        
        let logoutServiceController = LogoutServiceController()
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            self.controllersArray["logoutServiceController"] = nil
            serviceFailureHnadler(errorValue)
        }
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            
            let result = LogoutServiceResponseParser().parsePostLogoutServiceResponse(response: responseValue)
            if result.success {
                serviceSuccessHandler(responseValue)
            } else {
                serviceFailureHandler(result.message)
            }
            
            self?.controllersArray["logoutServiceController"] = nil
        }
        
        logoutServiceController.postLogoutData(accessToken: accessToken, emailAddress: email, serviceSuccessHandler: serviceSuccessHandler, serviceFailureHnadler: serviceFailureHandler)
        controllersArray["logoutServiceController"] = logoutServiceController
    }

    //MARK: GET Rates
    func getRatesCall(rentalLocationID: String, returnLocationID: String, pickupDate: String, pickupTime: String, dropOffDate: String, dropOffTime: String, promoCodes:[String], serviceSuccessHandler:@escaping (_ aezcar:AEZRates) -> Void, serviceFailureHandler:@escaping (_ errorValue:Any) -> Void) {
        
        let getRatesServiceController = GetRatesServiceController()
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            self.controllersArray["getRatesServiceController"] = nil
            serviceFailureHandler(errorValue)
        }
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            
            let parserResult = GetRatesServiceResponseParser().parseGetRatesServiceResponse(response: responseValue)
            if parserResult.success {
                serviceSuccessHandler(parserResult.aezCar!)
            } else {
                serviceFailureHandler(parserResult.message!)
            }
            self?.controllersArray["getRatesServiceController"] = nil
        }
        
        getRatesServiceController.getRates(rentalLocationID: rentalLocationID, returnLocationID: returnLocationID, pickupDate: pickupDate, pickupTime: pickupTime, dropOffDate: dropOffDate, dropOffTime: dropOffTime, promoCodes: promoCodes, serviceSuccessHandler: serviceSuccessHandler, serviceFailureHandler: serviceFailureHandler)
        controllersArray["getRatesServiceController"] = getRatesServiceController
    }
    
    //MARK: GET Policy Data
    func getPolicyCall(rentalLocationId: String, serviceSuccessHandler:@escaping (_ responseValue:String) -> Void, serviceFailureHandler:@escaping (_ errorValue:Any) -> Void) {
        
        let getPolicyServiceController = GetPolicyServiceController()
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            self.controllersArray["getPolicyServiceController"] = nil
            serviceFailureHandler(errorValue)
        }
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            
            let parserResult = GetPolicyServiceResponseParser().parseGetPolicyServiceResponse(responseData: responseValue)
            
            if parserResult.success {
                serviceSuccessHandler(parserResult.policyHTMLString!)
            } else {
                serviceFailureHandler(parserResult.message!)
            }
            self?.controllersArray["getPolicyServiceController"] = nil
        }
        
        getPolicyServiceController.getPolicy(rentalLocationID: rentalLocationId, serviceSuccessHandler: serviceSuccessHandler, serviceFailureHandler: serviceFailureHandler)
        controllersArray["getPolicyServiceController"] = getPolicyServiceController
    }
    
    //MARK: Request Bill Service
    func requestBillCall(reservationData:Reservation, promoCodes:[String], prepaid: String, serviceSuccessHandler:@escaping (_ billingData:BillingDetails) -> Void, extraOptions: [String]?, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        
        let requestBillServiceController = RequestBillServiceController()
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            self.controllersArray["requestBillServiceController"] = nil
            serviceFailureHnadler(errorValue)
        }
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            self?.controllersArray["requestBillServiceController"] = nil
            let parserResult = RequestBillServiceResponseParser().parseRequestBillServiceResponse(response: responseValue)
            if parserResult.success {
                serviceSuccessHandler(parserResult.billingDataResponse!)
            } else {
                serviceFailureHandler(parserResult.message!)
            }
        }
        
        requestBillServiceController.getRequestBillData(reservationData: reservationData, promoCodes: promoCodes, prepaid: prepaid, serviceSuccessHandler: serviceSuccessHandler, extraOptions: extraOptions, serviceFailureHnadler: serviceFailureHandler)
        
        controllersArray["requestBillServiceController"] = requestBillServiceController
    }
    
    //MARK: Add Reservation service
    func addReservationCall(_ reservationData: Reservation, serviceSuccessHandler:@escaping (_ confirmationNumber:String) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        
        
        let addReservationServiceController = AddReservationServiceController()
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            self.controllersArray["addReservationServiceController"] = nil
            serviceFailureHnadler(errorValue)
        }
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            self?.controllersArray["addReservationServiceController"] = nil
            let saerviceResponse = AddReservationResponseParser().parseAddReservationServiceResponse(response: responseValue)
            
            if saerviceResponse.success {
                serviceSuccessHandler(saerviceResponse.confirmationNumb as String!)
            } else {
                serviceFailureHandler(saerviceResponse.message as Any)
            }
        }
        
        addReservationServiceController.addReservation(reservationData: reservationData,serviceSuccessHandler: serviceSuccessHandler, serviceFailureHandler: serviceFailureHandler)
        
        controllersArray["addReservationServiceController"] = addReservationServiceController
    }
    
    //MARK: Pre Reservation service
    func preReservationCall(_ reservationData: Reservation, serviceSuccessHandler:@escaping (_ preReservation:PreReservation) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        
        let addReservationServiceController = AddReservationServiceController()
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            self.controllersArray["addReservationServiceController"] = nil
            serviceFailureHnadler(errorValue)
        }
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            self?.controllersArray["addReservationServiceController"] = nil
            let saerviceResponse = PreReservationResponseParser().parsePreReservationServiceResponse(response: responseValue)
            if saerviceResponse.success {
                serviceSuccessHandler(saerviceResponse.preReservation!)
            } else {
                serviceFailureHandler(saerviceResponse.message as Any)
            }
        }
        
        addReservationServiceController.addReservation(reservationData: reservationData,serviceSuccessHandler: serviceSuccessHandler, serviceFailureHandler: serviceFailureHandler)
        
        controllersArray["addReservationServiceController"] = addReservationServiceController
    }
    
    
    //MARK: View Reservation
    
    func viewReservationCall(_ reservationData: Reservation, serviceSuccessHandler:@escaping (_ confirmationNumber:String) -> Void, serviceFailureHnadler:@escaping (_ errorValue:Any) -> Void) {
        
        
        let viewReservationServiceController = ViewReservationServiceController()
        
        let serviceFailureHandler = {
            (errorValue:Any)  in
            print(errorValue)
            self.controllersArray["ViewReservationServiceController"] = nil
            serviceFailureHnadler(errorValue)
        }
        
        let serviceSuccessHandler = {
            [weak self] (responseValue:Any)  in
            self?.controllersArray["ViewReservationServiceController"] = nil
            let saerviceResponse = ViewReservationResponseParser().parseViewReservationResponse(response: responseValue)
            
            if saerviceResponse.success {
                serviceFailureHandler(saerviceResponse.message as Any)
                
            } else {
                serviceFailureHandler(saerviceResponse.message as Any)
            }
        }
        
    viewReservationServiceController.viewReservation(reservationData: reservationData, serviceSuccessHandler: serviceSuccessHandler, serviceFailureHandler: serviceFailureHandler)
        
        controllersArray["ViewReservationServiceController"] = viewReservationServiceController
    }


}


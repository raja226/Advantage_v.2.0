//
//  NetworkManager.swift
//  Advantage
//
//  Created by macbook on 6/22/18.
//  Copyright © 2018 Anjali Panjawani. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct findLocation {
    var locationID: String
    var locationText: String
}
class NetworkManager {
    let API_REQUEST_TIMEOUT: TimeInterval = 60    // seconds
    
    // Declare a shared instance
    static let sharedInstance = NetworkManager()
    
    var request: DataRequest?
    
    
   
    
    
    //MARK:- getForgotPassword
    func getForgotPassword(_ username: String, onCompletion: @escaping (JSON?, Error?) -> Void) {
        
       // let passwordHash = Utilities.sharedInstance.generatePasswordHash(password)
        //https://newqa.advantage.com//ServiceConstants.kBaseURL
        let parameters = ["email": username,"base_url":"https://newqa.advantage.com", "services_url":ServiceConstants.kServicesURL,"logging_url":ServiceConstants.kLogginURL]
        
        request = Alamofire.request(ServiceConstants.forgotpassword, method: .post, parameters: parameters).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                
                
                let forgotPasswordJSON = JSON(value)
                
                print(forgotPasswordJSON)

                let status = forgotPasswordJSON["status"]
                if status == "success" {
                   
                } else {
                }
                onCompletion(forgotPasswordJSON, nil)
                print("getForgotPassword Successful")
            case .failure(let error):
                onCompletion(nil, error)
                print("getForgotPassword Failed")
            }
        }
        
    }
    
    //MARK:- get view Reservation
    
    func getviewReservation(locaionId: String,lastname: String,confirmationNumber: String, onCompletion: @escaping (JSON?, Error?) -> Void) {
        
        
        let parameters = ["rental_location_id": locaionId,"renter_last":lastname,"confirm_num":confirmationNumber, "services_url":ServiceConstants.kServicesURL,"logging_url":ServiceConstants.kLogginURL]
        
        request = Alamofire.request(ServiceConstants.viewReservation, method: .get, parameters: parameters).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                
                let viewReservationJSON = JSON(value)
                print(viewReservationJSON)
                
                let status = viewReservationJSON["status"]
                if status == "success" {
                } else {
                }
                onCompletion(viewReservationJSON, nil)
                print("viewReservationJSON Successful")
            case .failure(let error):
                onCompletion(nil, error)
                print("viewReservationJSON Failed")
            }
        }
        
    }
    
    //MARK:- Cancel Reservation
    
    func cancelReservation(locaionId: String,lastname: String,confirmationNumber: String, onCompletion: @escaping (JSON?, Error?) -> Void) {
        
        
        let parameters = ["rental_location_id": locaionId,"renter_last":lastname,"confirm_num":confirmationNumber, "services_url":ServiceConstants.kServicesURL,"logging_url":ServiceConstants.kLogginURL,"base_url":ServiceConstants.kBaseURL]
        
        request = Alamofire.request(ServiceConstants.cancelReservation, method: .post, parameters: parameters).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                
                let viewReservationJSON = JSON(value)
                print(viewReservationJSON)
                
                let status = viewReservationJSON["status"]
                if status == "success" {
                } else {
                }
                onCompletion(viewReservationJSON, nil)
                print("cancelReservation Successful")
            case .failure(let error):
                onCompletion(nil, error)
                print("cancelReservation Failed")
            }
        }
        
    }
    
    //MARK:-  Get Locations( Find a Car Module)
    
    func getLocations(locaionId: String, onCompletion: @escaping (JSON?, Error?) -> Void) {
                
        //Payloads
        let parameters = ["rental_location_ids": locaionId, "services_url":ServiceConstants.kServicesURL,"logging_url":ServiceConstants.kLogginURL]
        
        request = Alamofire.request(ServiceConstants.getLocations, method: .get, parameters: parameters).responseJSON { response in
            
            switch response.result {
            case .success(let value):
                
                let getlocationJSON = JSON(value)
                print(getlocationJSON)
                
                let status = getlocationJSON["status"]
                if status == "success" {
                } else {
                }
                onCompletion(getlocationJSON, nil)
                print("cancelReservation Successful")
            case .failure(let error):
                onCompletion(nil, error)
                print("cancelReservation Failed")
            }
        }
        
    }


}

//
//  ViewReservationsViewController.swift
//  Advantage
//
//  Created by macbook on 6/26/18.
//  Copyright © 2018 Anjali Panjawani. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class ViewReservationsViewController: UIViewController {
    let renterProfile = UserLoyaltyProfile()
    var reservation: Reservation!
    //AEZExtra
    var aezExtra: AEZExtra!
    var aezTax: AEZTax!


    var viewReservation = ViewReservation()
    var shouldShowAddReservationErrorMessage = false
    var addReservationErrorMessage = "Something went wrong. Please try again"
    
    var rentalLocations:RatesLocation?

    var viewLocation:Location?
    var aezRates: AEZRates?
    var rentalLocation: Location?
    var returnLocation: Location?
    var rentalDate: Date?
    var rentalTime: Date?
    var returnDate: Date?
    var returnTime: Date?

    @IBOutlet weak var confirmationNumberTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    // MARK: - IB Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        //validation:
        
        if (locationTextField.text?.isEmpty)! {
            
              AlertManager.sharedInstance.show(title: "Error", message: "Please select  location.", fromVC: self)
            
        }else if (lastNameTextField.text?.isEmpty)! {
            
            AlertManager.sharedInstance.show(title: "Error", message: "Please select  LastName.", fromVC: self)
            
        }else if (confirmationNumberTextField.text?.isEmpty)! {
             AlertManager.sharedInstance.show(title: "Error", message: "Please select  Confirmation Number.", fromVC: self)
            
        }else{
            self.view.endEditing(true)
            
            if NetworkReachabilityManager()!.isReachable {
                
                lastNameTextField.text! = lastNameTextField.text!.trimmingCharacters(in: .whitespaces)
                confirmationNumberTextField.text! = confirmationNumberTextField.text!.trimmingCharacters(in: .whitespaces)
                
                
                //Service Call
                let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true); NetworkManager.sharedInstance.getviewReservation(locaionId: (viewLocation?.locationID)!, lastname: lastNameTextField.text!, confirmationNumber: confirmationNumberTextField.text!, onCompletion:{ (jsonResponse, error) -> Void in
                    
                    progressHUD.removeFromSuperview()
                    if error != nil {
                        let error: Error = (error?.localizedDescription)! as! Error
                        print(error.localizedDescription)
                        AlertManager.sharedInstance.show(title: "Error", message: error.localizedDescription, fromVC: self)
                    }else{
                        if jsonResponse?["status"].string == "error"  {
                            //Failure:
                            if let  messageValue = jsonResponse?["error"]["errorMessage"].string {
                                
                                
                                AlertManager.sharedInstance.show(title: "Error", message: messageValue, fromVC: self)
                            }
                        }else{
                            //sucess:
                            if jsonResponse?["status"].string == "success"  {
                                
                                // Reservation Confirmation number details
                                Reservation.sharedInstance?.rentalLocationId = self.viewLocation?.locationID
                                Reservation.sharedInstance?.confirmationNumber = self.confirmationNumberTextField.text
                                self.renterProfile.lastName = self.lastNameTextField.text
                                
                                //Reservationa Status:
                                Reservation.sharedInstance?.status = jsonResponse!["Payload"]["ReservationStatus"].string
                               
                                 Reservation.sharedInstance?.returnDateTime = jsonResponse!["Payload"]["PickupDateTime"].string
                                Reservation.sharedInstance?.rentalDateTime = jsonResponse!["Payload"]["ReturnDateTime"].string
                                // Reservation Summary
                                
                                
                                var  pickupDetails = RatesLocation(locationJSON: jsonResponse!["Payload"]["RentalVendorDetails"] )
                                
                                
                                //pickup
                                if (jsonResponse!["Payload"]["RentalVendorDetails"].dictionary != nil) {
                                    //Same location:
                                    pickupDetails.addLine1 = jsonResponse!["Payload"]["RentalVendorDetails"]["AddressLine1"].string
                                      pickupDetails.postalCode = jsonResponse!["Payload"]["RentalVendorDetails"]["AddressZipCode"].string
                                     //pickupDetails. = jsonResponse!["Payload"]["RentalVendorDetails"]["VendorEmailAddress"].string
                                      pickupDetails.country = jsonResponse!["Payload"]["RentalVendorDetails"]["AddressCountry"].string
                                       pickupDetails.phoneNumber = jsonResponse!["Payload"]["RentalVendorDetails"]["PhoneNumber"].string
                                       pickupDetails.state = jsonResponse!["Payload"]["RentalVendorDetails"]["AddressState"].string
                                      pickupDetails.city = jsonResponse!["Payload"]["RentalVendorDetails"]["AddressCity"].string
                                    
                                      //Reservation.sharedInstance!.renterProfile?.firstName = jsonResponse!["Payload"]["RentalVendorDetails"]["VendorName"].string
                                      pickupDetails.addLine2 = jsonResponse!["Payload"]["RentalVendorDetails"]["AddressLine2"].string
                                 
                                }
                                
                                //renter details
                                Reservation.sharedInstance?.rentalLocation = pickupDetails
                                
                               // drop Location
                                
                                 var  dropoffDetails = RatesLocation(locationJSON: jsonResponse!["Payload"]["ReturnLocation"] )
                                
                                if (jsonResponse!["Payload"]["ReturnLocation"].dictionary != nil) {
                                    //Same location:
                                    dropoffDetails.addLine1 = jsonResponse!["Payload"]["ReturnLocation"]["AddressLine1"].string
                                    dropoffDetails.postalCode = jsonResponse!["Payload"]["ReturnLocation"]["AddressZipCode"].string
                                    //pickupDetails. = jsonResponse!["Payload"]["RentalVendorDetails"]["VendorEmailAddress"].string
                                    dropoffDetails.country = jsonResponse!["Payload"]["ReturnLocation"]["AddressCountry"].string
                                    dropoffDetails.phoneNumber = jsonResponse!["Payload"]["ReturnLocation"]["PhoneNumber"].string
                                    dropoffDetails.state = jsonResponse!["Payload"]["ReturnLocation"]["AddressState"].string
                                    dropoffDetails.city = jsonResponse!["Payload"]["ReturnLocation"]["AddressCity"].string
                                    
                                    //Reservation.sharedInstance!.renterProfile?.firstName = jsonResponse!["Payload"]["RentalVendorDetails"]["VendorName"].string
                                    dropoffDetails.addLine2 = jsonResponse!["Payload"]["ReturnLocation"]["AddressLine2"].string
                                    
                                    
                                    
                                    
                                }
                             
                                //drop details
                                Reservation.sharedInstance?.returnLocation = dropoffDetails
                                
                              
                               
                                //Car Details:
                                
                                var selectedCardetails = Vehicle(carJSON: jsonResponse!["Payload"])

                                if let classCode = jsonResponse!["Payload"]["ClassCode"].string {
                                    
                                   selectedCardetails.classCode = classCode
                                }
                                
                                if let classImageURL = jsonResponse!["Payload"]["ClassImageURL"].string {
                                   selectedCardetails.classImageURL = classImageURL
                                }
                                
                                if let classImageURL2 = jsonResponse!["Payload"]["ClassImageURL2"].string {
                                    selectedCardetails.classImageURL2 = classImageURL2
                                }
                                
                                if let modelDesc = jsonResponse!["Payload"]["ModelDesc"].string {
                                     selectedCardetails.modelDesc = modelDesc
                                }
                                
                                if let classDesc = jsonResponse!["Payload"]["ClassDesc"].string {
                                     selectedCardetails.classDesc = classDesc
                                }
                                
                                if let category = jsonResponse!["Payload"]["Category"].string {
                                     selectedCardetails.category = category
                                }
                                
                                if let passengers = jsonResponse!["Payload"]["Passengers"].string {
                                    selectedCardetails.passengers = passengers
                                }
                                
                                if let luggage = jsonResponse!["Payload"]["Luggage"].string {
                                     selectedCardetails.luggage = luggage
                                }
                                
                                if let mpgCity = jsonResponse!["Payload"]["MPGCity"].string {
                                    selectedCardetails.mpgCity = mpgCity
                                }
                                
                                if let mpgHighway = jsonResponse!["Payload"]["MPGHighway"].string {
                                     selectedCardetails.mpgHighway = mpgHighway
                                }
                                
                                if let type = jsonResponse!["Payload"]["Type"].string {
                                     selectedCardetails.type = type
                                }
                                
                                if let airConditioning = jsonResponse!["Payload"]["AC"].string {
                                     selectedCardetails.airConditioning = airConditioning
                                }
                                
                                if let transmission = jsonResponse!["Payload"]["Transmission"].string {
                                     selectedCardetails.transmission = transmission
                                }
                                
                                if let upgrade = jsonResponse!["Payload"]["upgrade"].int {
                                    selectedCardetails.upgrade = upgrade
                                }
                                
                                if let liveALittle = jsonResponse!["Payload"]["live_a_little"].int {
                                     selectedCardetails.liveALittle = liveALittle
                                }
                                
                                if let rateID = jsonResponse!["Payload"]["RateID"].string {
                                     selectedCardetails.rateID = rateID
                                }
                                
                                
                                
                               
                                
                                //Card Details
                                
                                if ((jsonResponse!["Payload"]["CardType"].string) != nil) {
                                    
                                //Pay now:
                                    Reservation.sharedInstance?.prepaid = "Y"
                                    
                                    selectedCardetails.payNowRate.dailyRate = jsonResponse!["Payload"]["DailyRate"].string
                                    
                                    //PayNow
                                    if let payNowRateAmount = jsonResponse!["Payload"]["RateAmount"].string {
                                        selectedCardetails.payNowRate.rateAmount = payNowRateAmount
                                    }
                                    
                                    if let payNowDailyRate = jsonResponse!["Payload"]["TotalPricing"]["RatePeriod"]["Rate1PerDay"].string {
                                        selectedCardetails.payNowRate.dailyRate = payNowDailyRate
                                    }
                                    
                                    if let payNowTotalRate = jsonResponse!["Payload"]["TotalPricing"]["TotalCharges"].string {
                                        selectedCardetails.payNowRate.totalRate = payNowTotalRate
                                    }
                                    
                                    if let payNowRateCharge = jsonResponse!["Payload"]["TotalPricing"]["RateCharge"].string {
                                        selectedCardetails.payNowRate.rateCharge = payNowRateCharge
                                    }
                                    
                                    
                                    Reservation.sharedInstance?.cardType = jsonResponse!["Payload"]["CardType"].string
                                    

                                    
                                    
                                    
                                    //Taxes:
                                    
                                    
                                    
                                    let allTaxesKeys = jsonResponse!["Payload"]["TotalPricing"]["Taxes"].dictionary?.keys
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
                                        if let taxCharge = jsonResponse!["Payload"]["TotalPricing"]["Taxes"][taxChargeKey].string {
                                            aezTax.taxCharge = taxCharge
                                        }
                                        if let taxDesc = jsonResponse!["Payload"]["TotalPricing"]["Taxes"][taxDescriptionKey].string {
                                            aezTax.taxDescription = taxDesc
                                        }
                                        
                                        aTaxes.append(aezTax)
                                    }
                                    
                                    
                                    selectedCardetails.payNowRate.taxes = aTaxes
                                    
                                    // self.taxes = aTaxes
                                    
                                    var aezExtras = [AEZExtra]()
                                    let extraInfoJSON = jsonResponse!["Payload"]["TotalPricing"]["DailyExtra"]
                                    if extraInfoJSON.type == .array {
                                        for tempJSON in extraInfoJSON {
                                            aezExtras.append(AEZExtra(responseJSON: tempJSON.1))
                                        }
                                    } else {
                                        aezExtras.append(AEZExtra(responseJSON: extraInfoJSON))
                                    }
                                    
                                    selectedCardetails.payNowRate.extras = aezExtras
                                    
                                    
                                    
                                    if let taxTotal = jsonResponse!["Payload"]["TotalPricing"]["TotalTaxes"].string {
                                        selectedCardetails.payNowRate.totalTaxes = taxTotal
                                    }
                                    
                                    if let extraTotal = jsonResponse!["Payload"]["TotalPricing"]["TotalExtras"].string {
                                        selectedCardetails.payNowRate.totalExtras = extraTotal
                                    }
                                    
                                    //Discount:
                                    if let discountAmount = jsonResponse!["Payload"]["TotalPricing"]["RateDiscount"].string {
                                        //RateDiscount
                                        selectedCardetails.payNowRate.discountAmount = discountAmount
                                    }
                                    
                                    

                                    
                                }else{
                                    
                                    
                                    //pay later
                                    Reservation.sharedInstance?.prepaid = "N"
                                    selectedCardetails.payLaterRate.dailyRate = jsonResponse!["Payload"]["Prepaid"]["DailyRate"].string
                                    
                                    //PayLater:
                                    if let payLaterRateAmount = jsonResponse!["Payload"]["RateAmount"].string {
                                        selectedCardetails.payLaterRate.rateAmount = payLaterRateAmount
                                    }
                                    if let payLaterDailyRate = jsonResponse!["Payload"]["TotalPricing"]["RatePeriod"]["Rate1PerDay"].string {
                                        selectedCardetails.payLaterRate.dailyRate = payLaterDailyRate
                                    }
                                    
                                    if let payLaterTotalRate = jsonResponse!["Payload"]["TotalPricing"]["TotalCharges"].string {
                                        selectedCardetails.payLaterRate.totalRate = payLaterTotalRate
                                    }
                                    
                                    if let payLaterRateCharge = jsonResponse!["Payload"]["TotalPricing"]["RateCharge"].string {
                                        selectedCardetails.payLaterRate.rateCharge = payLaterRateCharge
                                    }
                                    
                                    
                                    
                                    
                                    
                                    //Taxes:
                                    
                                    
                                    
                                    let allTaxesKeys = jsonResponse!["Payload"]["TotalPricing"]["Taxes"].dictionary?.keys
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
                                        if let taxCharge = jsonResponse!["Payload"]["TotalPricing"]["Taxes"][taxChargeKey].string {
                                            aezTax.taxCharge = taxCharge
                                        }
                                        if let taxDesc = jsonResponse!["Payload"]["TotalPricing"]["Taxes"][taxDescriptionKey].string {
                                            aezTax.taxDescription = taxDesc
                                        }
                                        
                                        aTaxes.append(aezTax)
                                    }
                                    
                                    
                                    selectedCardetails.payLaterRate.taxes = aTaxes
                                    
                                    // self.taxes = aTaxes
                                    
                                    var aezExtras = [AEZExtra]()
                                    let extraInfoJSON = jsonResponse!["Payload"]["TotalPricing"]["DailyExtra"]
                                    if extraInfoJSON.type == .array {
                                        for tempJSON in extraInfoJSON {
                                            aezExtras.append(AEZExtra(responseJSON: tempJSON.1))
                                        }
                                    } else {
                                        aezExtras.append(AEZExtra(responseJSON: extraInfoJSON))
                                    }
                                    
                                    selectedCardetails.payLaterRate.extras = aezExtras
                                    
                                    
                                    
                                    if let taxTotal = jsonResponse!["Payload"]["TotalPricing"]["TotalTaxes"].string {
                                        selectedCardetails.payLaterRate.totalTaxes = taxTotal
                                    }
                                    
                                    if let extraTotal = jsonResponse!["Payload"]["TotalPricing"]["TotalExtras"].string {
                                        selectedCardetails.payLaterRate.totalExtras = extraTotal
                                    }
                                    
                                    //Discount:
                                    if let discountAmount = jsonResponse!["Payload"]["TotalPricing"]["RateDiscount"].string {
                                        //RateDiscount
                                        selectedCardetails.payLaterRate.discountAmount = discountAmount
                                    }
                                    
                                    

                                }

                            
                                //cardetails added:
                                Reservation.sharedInstance?.selectedCar = selectedCardetails
                                
                                
                                //Renter Information:
                                
                              var  renterInformationDeyails = UserLoyaltyProfile(loyaltyJSON:jsonResponse!["Payload"] )
                                
                                renterInformationDeyails.firstName = jsonResponse!["Payload"]["RenterFirst"].string
                                renterInformationDeyails.lastName = jsonResponse!["Payload"]["RenterLast"].string
                                renterInformationDeyails.state = jsonResponse!["Payload"]["RenterState"].string
                                renterInformationDeyails.loyaltyID = jsonResponse!["Payload"]["RentalLocationID"].double
                                renterInformationDeyails.city = jsonResponse!["Payload"]["RenterCity"].string
                                renterInformationDeyails.streetAddress = jsonResponse!["Payload"]["RenterAddress1"].string
                                renterInformationDeyails.postalCode = jsonResponse!["Payload"]["RenterZIP"].string
                                
                                //Adding renterinfomation:
                                  Reservation.sharedInstance?.renterProfile = renterInformationDeyails
                                
                                
                                //Billing Information:
                                
                                //let billingProfile = UserLoyaltyProfile()
                                
                                  var  billingProfile = UserLoyaltyProfile(loyaltyJSON:jsonResponse!["Payload"] )
                                
                                
                                billingProfile.streetAddress = jsonResponse!["Payload"]["RenterAddress1"].string
                                billingProfile.postalCode = jsonResponse!["Payload"]["RenterZIP"].string
                                billingProfile.city = jsonResponse!["Payload"]["RenterCity"].string
                                billingProfile.state = jsonResponse!["Payload"]["RenterState"].string
                                //billingProfile.country = responseInfo["Country"]
                                
                                Reservation.sharedInstance?.billingProfile = billingProfile


                                /*
                                let billingProfile = UserLoyaltyProfile()
                                billingProfile.streetAddress = responseInfo["Street"]
                                billingProfile.postalCode = responseInfo["Zip"]
                                billingProfile.city = responseInfo["City"]
                                billingProfile.state = responseInfo["State"]
                                billingProfile.country = responseInfo["Country"]
                                
                                Reservation.sharedInstance?.billingProfile = billingProfile
                                
                                Reservation.sharedInstance?.cardNumber = responseInfo["CardLastFour"]
                                Reservation.sharedInstance?.cardType = responseInfo["CardType"]
 
                                 */
                                
                                //
                               
                                
                                

                                
                                
                                /*
                                 "status" : "success",
                                 "@attributes" : {
                                 "Version" : "1.0.0"
                                 },
                                 "Dategmtime" : "06\/27\/2018 03:01:06",
                                 "Message" : {
                                 "MessageID" : "RSPREZ",
                                 "MessageDescription" : "Respond With Reservation Details"
                                 },
                                 "Payload" : {
                                 "RateID" : "52636580",
                                 "EmailAddress" : "RAMKUMAR.V@QUAGILESOLUTION.COM",
                                 "RenterTitle" : [
                                 
                                 ],
                                 "DailyRate" : "25.00",
                                 "ReturnDateTime" : "06292018 12:30 PM",
                                 "RentalComments" : "1+2 DAY LOR",
                                 "RenterWorkPhone" : [
                                 
                                 ],
                                 "CardNumber" : [
                                 
                                 ],
                                 "ClassDesc" : "Compact 2\/4 Door Automatic With AC",
                                 "OriginalSenderID" : "ADV02",
                                 "Airline" : [
                                 
                                 ],
                                 "RentalVendorDetails" : {
                                 "AddressLine1" : "ORLANDO INTERNATIONAL AIRPORT",
                                 "AddressZipCode" : "32827",
                                 "VendorEmailAddress" : "ORLANDO@ADVANTAGE.COM",
                                 "AddressCountry" : "US",
                                 "PhoneNumber" : "(800) 777-5500",
                                 "AddressState" : "FL",
                                 "AddressCity" : "ORLANDO",
                                 "VendorName" : "ADVANTAGE - MCO",
                                 "AddressLine2" : "1 AIRPORT BLVD"
                                 },
                                 "ModelDesc" : "Nissan Versa",
                                 "RenterZIP" : "23235",
                                 "ClassCode" : "CCAR",
                                 "RenterAddress1" : "NEWYORK2",
                                 "OptInMail" : "0",
                                 "PerMileKM" : "0.00",
                                 "CardExp" : [
                                 
                                 ],
                                 "TourOperator" : "NO",
                                 "DailyFree" : "0",
                                 "ApiProvider" : "TSD",
                                 "TextOK" : "N",
                                 "RenterLicenseExpDate" : [
                                 
                                 ],
                                 "Flight" : [
                                 
                                 ],
                                 "RenterDOB" : [
                                 
                                 ],
                                 "LoyaltyID" : [
                                 
                                 ],
                                 "RenterCountry" : [
                                 
                                 ],
                                 "DisplayRate" : "Y",
                                 "RenterLicenseNumber" : [
                                 
                                 ],
                                 "ReturnLocationID" : "MCO",
                                 "HourlyMinHours" : "0",
                                 "IATA" : "WebLink",
                                 "RenterHomePhone" : "8667706699",
                                 "NoShow" : "NO",
                                 "PickupDateTime" : "06272018 12:30 PM",
                                 "CompanyNumber" : [
                                 
                                 ],
                                 "HourlyMaxHours" : "0",
                                 "TotalPricing" : {
                                 "RatePeriod" : {
                                 "Rate2Days" : "0",
                                 "Weekends" : "0",
                                 "Rate1Days" : "2",
                                 "Rate1Free" : "0",
                                 "Rate2Free" : "0",
                                 "AmtPerWeekend" : "0.00",
                                 "Rate2PerDay" : "27.50",
                                 "Weeks" : "0",
                                 "AmtPerHour" : "0.00",
                                 "Months" : "0",
                                 "AmtPerMonth" : "0.00",
                                 "Rate1PerDay" : "25.00",
                                 "Hours" : "0",
                                 "AmtPerWeek" : "0.00"
                                 },
                                 "TotalCharges" : "76.63",
                                 "PerMileAmount" : "0.00",
                                 "TotalTaxes" : "26.63",
                                 "LateCharge" : "0.00",
                                 "TotalExtras" : "0.00",
                                 "RateCharge" : "50.00",
                                 "Taxes" : {
                                 "Tax7Charge" : "7.00",
                                 "Tax8Type" : "DAILY",
                                 "Tax10Amount" : "0.00",
                                 "Tax8Charge" : "4.00",
                                 "Tax7Type" : "DAILY",
                                 "Tax1Rate" : "0.1000",
                                 "Tax8Desc" : "FLORIDA SURCHARGE",
                                 "Tax7Desc" : "CFC",
                                 "Tax3Charge" : "5.38",
                                 "Tax2Amount" : "71.92",
                                 "Tax10Type" : "DAILY",
                                 "Tax1Charge" : "5.54",
                                 "Tax2Desc" : "STATE TAX",
                                 "Tax7Amount" : "0.00",
                                 "Tax7Rate" : "3.5000",
                                 "Tax10Charge" : "0.04",
                                 "Tax2Charge" : "4.67",
                                 "Tax2Type" : "PERCENT",
                                 "Tax10Desc" : "TIRE BATTERY FEE",
                                 "Tax1Type" : "PERCENT",
                                 "Tax8Rate" : "2.0000",
                                 "Tax2Rate" : "0.0650",
                                 "Tax8Amount" : "0.00",
                                 "Tax10Rate" : "0.0200",
                                 "Tax1Amount" : "55.38",
                                 "Tax3Desc" : "VEHICLE LICENSE FEE",
                                 "Tax3Rate" : "2.6900",
                                 "Tax3Amount" : "0.00",
                                 "Tax3Type" : "DAILY",
                                 "Tax1Desc" : "CONCESSION FEE"
                                 },
                                 "RatePlusLate" : "50.00",
                                 "Surcharge" : "0.0000",
                                 "TotalFreeMiles" : "0",
                                 "RentalDays" : "2"
                                 },
                                 "RenterState" : "CA",
                                 "RenterFirst" : "RAM",
                                 "CardType" : [
                                 
                                 ],
                                 "CurrencyCode" : "USD",
                                 "RenterLicenseState" : [
                                 
                                 ],
                                 "DailyExtra" : [
                                 
                                 ],
                                 "MileageUnit" : "MI",
                                 "RenterCity" : "C5",
                                 "ClassImageURL" : "https:\/\/www.advantage.com\/wp-content\/plugins\/advantage-vehicles\/assets\/CCAR_800x400.png",
                                 "RenterAddress2" : [
                                 
                                 ],
                                 "OptInPhone" : "0",
                                 "ClassImageURL2" : "https:\/\/www.advantage.com\/wp-content\/plugins\/advantage-vehicles\/assets\/CCAR_800x400.png",
                                 "SourceID" : "14",
                                 "RenterLast" : "KUMAR",
                                 "RentalLocationID" : "MCO",
                                 "ReservationStatus" : "ACTIVE",
                                 "TSDNumber" : "42052",
                                 "RateCode" : "D12",
                                 "OptInEmail" : "0"
                                 }
                                 }
                                 
                                 */


                                
                                //navigation:
                                
                                self.performSegue(withIdentifier: "MyReservationViewController", sender: self)

                                
                               
                            }
                        }
                        
                    }
                })
                
               
            } else {
                AlertManager.sharedInstance.show(title: "Error", message: "The Internet connection appears to be offline.", fromVC: self)
            }
            
        }

    }
    

   
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LocationResultsSegue" {
            let locationResultsViewController = segue.destination as! LocationSearchResultsViewController
            locationResultsViewController.delegate  = self
        } else if segue.identifier == "ChooseCarSegue" {
           
        }
    }
  

}
//MARK:- LocationSearchResultsViewControllerDelegate

extension ViewReservationsViewController:LocationSearchResultsViewControllerDelegate {

    func locationSearchResultsViewControllerDidSelectLocation(vc: LocationSearchResultsViewController, location: Location) {
        print(location.locationText)
        locationTextField.text = location.locationText
        viewLocation = location
         vc.backButtonTapped(self)
    }
}
//MARK:- UITextFieldDelegate
extension ViewReservationsViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == locationTextField {
            self.performSegue(withIdentifier: "LocationResultsSegue", sender: self)
            return false
        }
    return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



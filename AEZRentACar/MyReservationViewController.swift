//
//  MyReservationViewController.swift


import UIKit
import MBProgressHUD
import AlamofireImage
import Alamofire


class MyReservationViewController: LogoutFunctionalityViewController {
    
    @IBOutlet weak var extrafeesLabel: UILabel!
    @IBOutlet weak var extraBreakupLabel: UILabel!
    
    var rentalDate: Date?
    var rentalTime: Date?
    var returnDate: Date?
    var returnTime: Date?
    
    //Scrollview
    
    @IBOutlet weak var scrollView:UIScrollView!
    
   @IBOutlet weak var constraintscrollViewBottomSpace: NSLayoutConstraint!
    //
    
    @IBOutlet weak var diallyLable: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var reservationStatusLabel: UILabel!
    
    
    @IBOutlet weak var constraintPaymentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintPaymentViewBottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var constraintDiscountViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintDiscountViewTopSpace: NSLayoutConstraint!
    
    
    // Reservation number details
    @IBOutlet weak var reservationNumberLabel: UILabel!
    @IBOutlet weak var reservationNumberView: UIView!
    @IBOutlet weak var reservationNumberShadowView: UIView!
    
    // Resrvation Summary
    @IBOutlet weak var pickUpDateTimeLabel: UILabel!
    @IBOutlet weak var pickUpLocationLabel: UILabel!
    @IBOutlet weak var pickUpLocationAddressLabel: UILabel!
    @IBOutlet weak var dropOffDateTimeLabel: UILabel!
    @IBOutlet weak var dropOffLocationLabel: UILabel!
    @IBOutlet weak var dropOffLocationAddressLabel: UILabel!
    
    // Car details
    @IBOutlet weak var carDetailsDailyRateLabel: UILabel!
    @IBOutlet weak var carDetailsTotalRateLabel: UILabel!
    @IBOutlet weak var selectedCarNameLabel: UILabel!
    @IBOutlet weak var selectedCarDescriptionLabel: UILabel!
    @IBOutlet weak var selectedCarImageView: UIImageView!
    @IBOutlet weak var airConditionLabel: UILabel!
    @IBOutlet weak var transmissionLabel: UILabel!
    @IBOutlet weak var passengersLabel: UILabel!
    @IBOutlet weak var doorsLabel: UILabel!
    @IBOutlet weak var luggageLabel: UILabel!
    
    // Fees and options
    @IBOutlet weak var dailyRateLabel: UILabel!
    @IBOutlet weak var taxesBreakupLabel: UILabel!
    @IBOutlet weak var taxesBreakupCharges: UILabel!
    @IBOutlet weak var totalCharges: UILabel!
    @IBOutlet weak var totalTaxesLabel: UILabel!
    @IBOutlet weak var discountPercentLabel: UILabel!
    @IBOutlet weak var discountAmountLabel: UILabel!
    
    // Renter information
    @IBOutlet weak var renterNameLabel: UILabel!
    @IBOutlet weak var renterAddressLabel: UILabel!
    @IBOutlet weak var advantageAwardsStatusLabel: UILabel!
    @IBOutlet weak var paymentCardNumberLabel: UILabel!
    @IBOutlet weak var paymentCardImageView: UIImageView!
    @IBOutlet weak var billingPersonNameLabel: UILabel!
    @IBOutlet weak var billingAddressLabel: UILabel!
    
    var reservation: Reservation!
    let downloader = ImageDownloader()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        applyDesignChanges()
        
        self.reservation = Reservation.sharedInstance
       populateData()
    }
    
    func applyDesignChanges() {
        
        var status = ""
        if let _ = UserDefaults.standard.string(forKey: "access_token") {
            if let loyaltyMessage = UserDefaults.standard.string(forKey: "loggedInUserLoyaltyStatus") {
                status = loyaltyMessage
            }
        } else {
            status = "Non member"
        }
        
        let formattedString = "Advantage Awards Status - \(status)"
        let formattedAttributedString = NSMutableAttributedString(string: formattedString)
        let font = UIFont(name: "Montserrat-Regular", size: 12)
        let color = UIColor(red: 0, green: 0, blue: 51/255, alpha: 1)
        formattedAttributedString.addAttribute(NSFontAttributeName, value: font!,range: NSRange(location: 0, length: 25))
        formattedAttributedString.addAttribute(NSForegroundColorAttributeName, value: color,range: NSRange(location: 0, length: 25))
        self.advantageAwardsStatusLabel.attributedText = formattedAttributedString
        
        self.reservationNumberView.layer.cornerRadius = 10
        self.reservationNumberView.layer.masksToBounds = true
        
        let shadowColor = UIColor(red: 28.0/255.0, green: 47.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
        self.reservationNumberShadowView.layer.shadowColor = shadowColor
        self.reservationNumberShadowView.layer.shadowOffset =  CGSize(width: 0, height: 2.5)
        self.reservationNumberShadowView.layer.shadowOpacity = 0.065
        self.reservationNumberShadowView.layer.shadowRadius = 3.5
        let path = UIBezierPath(roundedRect: self.reservationNumberShadowView.bounds, cornerRadius: 10).cgPath
        self.reservationNumberShadowView.layer.shadowPath = path
    }
    
    func populateData() {
        
        // Reservation number details
        if let confNumber = reservation.confirmationNumber {
            self.reservationNumberLabel.text = confNumber
        } else {
            self.reservationNumberLabel.text = ""
        }
        
      self.constraintscrollViewBottomSpace.priority = UILayoutPriorityDefaultLow
        if reservation.status == "ACTIVE" {
            cancelButton.isHidden = false
            reservationStatusLabel.text = "Your reservation has been confirmed!"
        }else{
            reservationStatusLabel.text = "Your reservation has been canceled!"
            cancelButton.isHidden = true
            
            self.constraintscrollViewBottomSpace.constant = 0
        }
        
        // Reservation Summary
        
        //Pickup
        self.pickUpLocationLabel.text = reservation.rentalLocation?.addLine1
        self.pickUpLocationAddressLabel.text = Utilities.sharedInstance.locationAddress(location: reservation.rentalLocation!)
        
        if let value = Reservation.sharedInstance?.rentalDateTime {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "MMddyyyy hh:mm a"
            let showDate: Date? = inputFormatter.date(from: value)
            inputFormatter.dateFormat = "MM/dd/yyy hh:mm a"
            let resultString = inputFormatter.string(from: (showDate)!)
            print(resultString)
           self.pickUpDateTimeLabel.text = resultString
        }
        
        if reservation.returnLocation?.addLine1 != nil {
            
            //Drop
            self.dropOffLocationLabel.text = reservation.returnLocation?.addLine1
            self.dropOffLocationAddressLabel.text = Utilities.sharedInstance.locationAddress(location: Reservation.sharedInstance!.returnLocation!)
            

            if let value = Reservation.sharedInstance?.returnDateTime {
                let inputFormatter = DateFormatter()
                inputFormatter.dateFormat = "MMddyyyy hh:mm a"
                let showDate: Date? = inputFormatter.date(from: value)
                inputFormatter.dateFormat = "MM/dd/yyy hh:mm a"
                let resultString = inputFormatter.string(from: (showDate)!)
                print(resultString)
                self.dropOffDateTimeLabel.text = resultString
            }
            
        }else{
            
            //Drop
            self.dropOffLocationLabel.text = reservation.rentalLocation?.addLine1
            self.dropOffLocationAddressLabel.text = Utilities.sharedInstance.locationAddress(location: Reservation.sharedInstance!.rentalLocation!)
            //self.dropOffDateTimeLabel.text = Reservation.sharedInstance?.returnDateTime
            
            if let value = Reservation.sharedInstance?.returnDateTime {
                let inputFormatter = DateFormatter()
                inputFormatter.dateFormat = "MMddyyyy hh:mm a"
                let showDate: Date? = inputFormatter.date(from: value)
                inputFormatter.dateFormat = "MM/dd/yyy hh:mm a"
                let resultString = inputFormatter.string(from: (showDate)!)
                print(resultString)
                self.dropOffDateTimeLabel.text = resultString
            }
        }
        
        
        
        // Car details
        if let carNameLabel = self.reservation.selectedCar?.modelDesc {
            self.selectedCarNameLabel.text = carNameLabel
        }
        
        var carDescription = ""
        if let classDesc = self.reservation.selectedCar?.classDesc {
            carDescription = classDesc
        }
        if let classCode = self.reservation.selectedCar?.classCode {
            carDescription += "| \(classCode)"
        }
        self.selectedCarDescriptionLabel.text = carDescription
        
        if let imagePath = self.reservation.selectedCar?.classImageURL2 {
            if imagePath.isEmpty == false {
                let urlRequest = URLRequest(url: URL(string: imagePath)!)
                downloader.download(urlRequest) { response in
                    if let image = response.result.value {
                        self.selectedCarImageView.image = image
                    } else {
                        self.selectedCarImageView.image = UIImage(named: "Placeholder")
                    }
                }
            }
        }
        
        
        let currencyCode = self.reservation.selectedCar?.currencyCode
        
        
        
        var displayRate = self.reservation.selectedCar?.payLaterRate
        self.constraintPaymentViewHeight.priority = UILayoutPriorityRequired
        self.constraintPaymentViewBottomSpace.priority = UILayoutPriorityDefaultLow
        self.constraintPaymentViewHeight.constant = 0
        if self.reservation.prepaid == "Y" {
            displayRate = self.reservation.selectedCar?.payNowRate
            self.constraintPaymentViewHeight.priority = UILayoutPriorityDefaultLow
            self.constraintPaymentViewBottomSpace.priority = UILayoutPriorityRequired
        }else{
            displayRate = self.reservation.selectedCar?.payLaterRate

        }
        
        //commented Dially Rate Code:
      /*
        var rateCharges = Utilities.displayRateWithCurrency(rate: "NA", currency: currencyCode)
        if let rateCrg = displayRate?.dailyRate {
            rateCharges = Utilities.displayRateWithCurrency(rate: rateCrg, currency: currencyCode)
        }
        self.dailyRateLabel.text = rateCharges
        self.carDetailsDailyRateLabel.text = rateCharges
        
       */
        
        //Replace the Rate Charge:
       
         var rateCharges = Utilities.displayRateWithCurrency(rate: "NA", currency: currencyCode)
         if let rateCrg = displayRate?.rateCharge {
         rateCharges = Utilities.displayRateWithCurrency(rate: rateCrg, currency: currencyCode)
         }
         self.dailyRateLabel.text = rateCharges
         self.carDetailsDailyRateLabel.text = rateCharges
         
       
        
        if let airCondition = self.reservation.selectedCar?.airConditioning {
            if airCondition == "Yes" {
                self.airConditionLabel.text = "A/C"
            } else {
                self.airConditionLabel.text = "NA"
            }
        }
        
        if let transmission = self.reservation.selectedCar?.transmission {
            self.transmissionLabel.text = String(transmission.characters[transmission.characters.startIndex])
        }
        
        //        self.doorsLabel.text = "1"
        
        if let passengers = self.reservation.selectedCar?.passengers {
            self.passengersLabel.text = passengers
        }
        
        if let luggage = self.reservation.selectedCar?.luggage {
            self.luggageLabel.text = luggage
        }
        
        
        

        // Fees and options
        
        var totalCharges = Utilities.displayRateWithCurrency(rate: "NA", currency: currencyCode)
        if let totCharges = displayRate?.totalRate {
            totalCharges = Utilities.displayRateWithCurrency(rate: totCharges, currency: currencyCode)
        }
        self.totalCharges.text = totalCharges
        self.carDetailsTotalRateLabel.text = totalCharges
        
        var taxesBreakupText = ""
        var taxesFeesText = ""
        for tax in displayRate!.taxes! {
            taxesBreakupText = taxesBreakupText.appending(tax.taxDescription)
            taxesBreakupText = taxesBreakupText.appending("\n")
            
            let charge = Utilities.displayRateWithCurrency(rate: tax.taxCharge, currency: currencyCode)
            taxesFeesText = taxesFeesText.appending(charge)
            taxesFeesText = taxesFeesText.appending("\n")
        }
        
        
        //Font Purpose:Taxes
        var taxandFeestotalStartPosition = -1
        var taxtandFeesStartPosition = -1
        var taxtandFeesLength = 0
        
        taxandFeestotalStartPosition = taxesBreakupText.characters.count
        taxtandFeesStartPosition = taxesFeesText.characters.count
        taxtandFeesLength = totalCharges.characters.count + 2
        
       
        let totalTaxes = Double(displayRate!.totalTaxes!)!
        let totalExtras = Double(displayRate!.totalExtras!)!
        let dispTotalExtras = "\(totalTaxes )"
        self.totalTaxesLabel.text = Utilities.displayRateWithCurrency(rate: displayRate!.totalTaxes!, currency: currencyCode)
 
        
        
        //Adding Additional SectionScreen:
        
        taxesBreakupText = taxesBreakupText.appending("\n")
        taxesBreakupText = taxesBreakupText.appending("Taxes and Fees Total")
        taxesBreakupText = taxesBreakupText.appending("\n")
        
        taxesFeesText = taxesFeesText.appending("\n")
        taxesFeesText = taxesFeesText.appending(self.totalTaxesLabel.text!)
        self.totalTaxesLabel.text = ""
        taxesFeesText = taxesFeesText.appending("\n")
        
        // Remove last \n from texts
        var endIndex1 = taxesBreakupText.index(taxesBreakupText.endIndex, offsetBy: 0)
        taxesBreakupText = taxesBreakupText.substring(to: endIndex1)
        endIndex1 = taxesFeesText.index(taxesFeesText.endIndex, offsetBy: 0)
        taxesFeesText = taxesFeesText.substring(to: endIndex1)
        
        
        //For Bold Font For :TaxAndFee Total
        
        if taxandFeestotalStartPosition != -1 {
            
            let textRange = NSRange(location: taxandFeestotalStartPosition , length: 21)
            self.taxesBreakupLabel.attributedText = attributedText(text: taxesBreakupText, range: textRange)
          
            let chargeRange = NSRange(location: taxtandFeesStartPosition, length: taxtandFeesLength - 1)
            self.taxesBreakupCharges.attributedText = attributedText(text: taxesFeesText, range: chargeRange)
           
           // self.taxesBreakupCharges.text = taxesFeesText

            
        } else {
            self.taxesBreakupLabel.text = taxesBreakupText
            self.taxesBreakupCharges.text = taxesFeesText
        }
        
        
        
   
        
        //
        var extraTaxesBreakupText = ""
        var extraTaxeschargesText = ""
        
        var extratTotalTextStartPosition = -1
        var extratTotalChargeStartPosition = -1
        var extratTotalChargeLength = 0
        
        for extra in displayRate!.extras! {
            if extra.extraDescription == "" && extra.extraAmount == "" {
                continue
            }
            
            if extra.extraDescription == "UNDER AGE DRIVER" {
                
                
             
                //
                extraTaxesBreakupText = extraTaxesBreakupText.appending(extra.extraDescription)
                extraTaxesBreakupText = extraTaxesBreakupText.appending("\n")
                
                let charge = Utilities.displayRateWithCurrency(rate: extra.extraAmount, currency: currencyCode)
                extraTaxeschargesText = extraTaxeschargesText.appending(charge)
                extraTaxeschargesText = extraTaxeschargesText.appending("\n")
                //
                
                
            }else{
                //
                extraTaxesBreakupText = extraTaxesBreakupText.appending(extra.extraDescription)
                extraTaxesBreakupText = extraTaxesBreakupText.appending("\n")
                
                let charge = Utilities.displayRateWithCurrency(rate: extra.extraAmount, currency: currencyCode)
                extraTaxeschargesText = extraTaxeschargesText.appending(charge)
                extraTaxeschargesText = extraTaxeschargesText.appending("\n")
            }
            
            
            
            
            
            
            
        }
        
        //TotalExtras
        
        
        var totalExtrasCount = Utilities.displayRateWithCurrency(rate: displayRate!.totalExtras!, currency: currencyCode)
        
        extratTotalTextStartPosition = extraTaxesBreakupText.characters.count
        extratTotalChargeStartPosition = extraTaxeschargesText.characters.count
        
        extratTotalChargeLength = totalExtrasCount.characters.count + 2
        
        
        
        
        extraTaxesBreakupText = extraTaxesBreakupText.appending("\n")
        extraTaxesBreakupText = extraTaxesBreakupText.appending("Extra Total")
        extraTaxesBreakupText = extraTaxesBreakupText.appending("\n")
        
        
        
        extraTaxeschargesText = extraTaxeschargesText.appending("\n")
        
        extraTaxeschargesText = extraTaxeschargesText.appending(totalExtrasCount)
        extraTaxeschargesText = extraTaxeschargesText.appending("\n")
        
        
        
        // Remove last \n from texts
        var endIndex = extraTaxesBreakupText.index(extraTaxesBreakupText.endIndex, offsetBy: -1)
        extraTaxesBreakupText = extraTaxesBreakupText.substring(to: endIndex)
        
        endIndex = extraTaxeschargesText.index(extraTaxeschargesText.endIndex, offsetBy: -1)
        extraTaxeschargesText = extraTaxeschargesText.substring(to: endIndex)
        
        
        
        
        //For Bold Font For :Extra Tax Total
        
        if extratTotalTextStartPosition != -1 {
            
         
            let textRange = NSRange(location: extratTotalTextStartPosition  , length: 12)
            self.extraBreakupLabel.attributedText = attributedText(text: extraTaxesBreakupText, range: textRange)

          
            let chargeRange = NSRange(location: extratTotalChargeStartPosition, length: extratTotalChargeLength-1)
            self.extrafeesLabel.attributedText = attributedText(text: extraTaxeschargesText, range: chargeRange)

        } else {
            self.extraBreakupLabel.text = extraTaxesBreakupText
            self.extrafeesLabel.text = extraTaxeschargesText
        }
        
    
        
        // Disocunt Information
        if let discountAmount = displayRate?.discountAmount {
            self.discountAmountLabel.text = Utilities.displayRateWithCurrency(rate: discountAmount, currency: currencyCode)
            self.constraintDiscountViewTopSpace.constant = 35
            self.constraintDiscountViewHeight.constant = 0.5
            self.discountAmountLabel.isHidden = false
            self.discountPercentLabel.isHidden = false
        } else {
            self.constraintDiscountViewTopSpace.constant = 0
            self.constraintDiscountViewHeight.constant = 0
            self.discountAmountLabel.isHidden = true
            self.discountPercentLabel.isHidden = true
        }
 
 
        // Renter information
        var renterNameText = ""
        if let firstName = self.reservation.renterProfile?.firstName {
            renterNameText = renterNameText.appending(firstName)
        }
        if let lastName = self.reservation.renterProfile?.lastName {
            renterNameText = renterNameText.appending(" \(lastName)")
        }
        self.renterNameLabel.text = renterNameText
        
       self.renterAddressLabel.text = renterAddressText(profile: self.reservation.renterProfile!)
        
        //Card:
        
        
        if self.reservation.prepaid == "Y" {
            if let cardNumber = self.reservation.cardNumber {
                self.paymentCardNumberLabel.text = "xxx-xxx-xxx-\(cardNumber)"
            }else{
                self.paymentCardNumberLabel.text = "xxx-xxx-xxx-xxx"

            }
            self.billingPersonNameLabel.text = renterNameText
            if self.reservation.billingProfile?.streetAddress == nil  {
                self.billingAddressLabel.text = renterAddressText(profile: self.reservation.renterProfile!)
            } else {
                self.billingAddressLabel.text = renterAddressText(profile: self.reservation.billingProfile!)
            }
            
            if let image = cardImage(cardType: self.reservation.cardType!) {
                self.paymentCardImageView.image = image
            }
        }
        
        
        
        
        self.constraintPaymentViewHeight.priority = UILayoutPriorityRequired
        self.constraintPaymentViewBottomSpace.priority = UILayoutPriorityDefaultLow
        self.constraintPaymentViewHeight.constant = 0
        if self.reservation.prepaid == "Y" {
            self.constraintPaymentViewHeight.priority = UILayoutPriorityDefaultLow
            self.constraintPaymentViewBottomSpace.priority = UILayoutPriorityRequired
        }
 
    }
    
    func visibilityDateTimeFormat(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let yourDate = dateFormatter.date(from: date)

        return dateFormatter.string(from: yourDate!)
    }

    func cardImage(cardType: String) -> UIImage? {
        var imageName = ""
        if cardType == "VI" {
            imageName = "CardVISA"
        } else if cardType == "AX" {
            imageName = "CardAmericanExpress"
        } else if cardType == "MC" {
            imageName = "CardMasterCard"
        }
        if imageName != "" {
            return UIImage(named: imageName)
        }
        return nil
    }
    
    func renterAddressText(profile: UserLoyaltyProfile) -> String {
        if self.reservation.prepaid == "N" && profile.streetAddress == "" {
            return profile.email!
        } else {
            var renterAddressText = ""
            var shouldAddComma = false
            if let addressOne = profile.streetAddress {
                if addressOne.isEmpty == false {
                    shouldAddComma = true
                    renterAddressText = renterAddressText.appending(addressOne)
                }
            }
            if let addressTwo = profile.streetAddressTwo {
                if addressTwo.isEmpty == false {
                    if shouldAddComma {
                        renterAddressText = renterAddressText.appending(", ")
                    }
                    shouldAddComma = true
                    renterAddressText = renterAddressText.appending("\(addressTwo)")
                }
            }
            if let city = profile.city {
                if city.isEmpty == false {
                    if shouldAddComma {
                        renterAddressText = renterAddressText.appending(", ")
                    }
                    shouldAddComma = true
                    renterAddressText = renterAddressText.appending("\(city),")
                } else {
                    shouldAddComma = false
                }
            }
            if renterAddressText.characters.count > 0 {
                renterAddressText = renterAddressText.appending("\n")
            }
            shouldAddComma = false
            if let state = profile.state {
                if state.isEmpty == false {
                    shouldAddComma = true
                    renterAddressText = renterAddressText.appending("\(state)")
                } else {
                    shouldAddComma = false
                }
            }
            if let postalCode = profile.postalCode {
                if postalCode.isEmpty == false {
                    shouldAddComma = true
                    renterAddressText = renterAddressText.appending(" \(postalCode)")
                }
            }
            if let country = profile.country {
                if country.isEmpty == false {
                    if shouldAddComma {
                        renterAddressText = renterAddressText.appending(", ")
                    }
                    renterAddressText = renterAddressText.appending("\(country)")
                }
            }
            return renterAddressText
        }
    }
    
    //MARK:- Font attribute
    func attributedText(text: String, range: NSRange) -> NSAttributedString {
        let formattedAttributedString = NSMutableAttributedString(string: text)
        let font = UIFont(name: "Montserrat-Regular", size: 12)
        let color = UIColor(red: 0, green: 0, blue: 51/255, alpha: 1)
        formattedAttributedString.addAttribute(NSFontAttributeName, value: font!,range: range)
        formattedAttributedString.addAttribute(NSForegroundColorAttributeName, value: color,range: range)
        return formattedAttributedString
    }
    //MARK:- IB Actions
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        //self.popvi
    }
    @IBAction func callButtonTapped(_ sender: Any) {
        let callNumber = "1-800-777-5500"
        guard let number = URL(string: "tel://" + callNumber) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(number, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            if let url = URL(string: "tel://\(callNumber)") {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func cancelResevationButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        
        
        var message = "If you used a credit card to reserve your vehicle, a change of $50 wil be added to cancel a reservation.\n Please call 1-8000-777-5500"
        if self.isMember(of: ReservationConfirmationViewController.self) {
            message = "Are you sure you want to continue?"
        }
        
        let alertController = UIAlertController(title: "ARE YOU SURE YOU WANT TO CANCEL YOU RESERVATION?", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (UIAlertAction) in
        }
        alertController.addAction(cancelAction)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            //self.serverLogoutUser()
            self.cancenReservationAPICall()
        }
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        //  self.performSegue(withIdentifier: "webViewSegue", sender: self)
//       AlertManager.sharedInstance.show(title: "ARE YOU SURE YOU WANT TO CANCEL YOU RESERVATION?", message:"If you used a credit card to reserve your vehicle, a change of $50 wil be added to cancel a reservation.\n Please call 1-8000-777-5500", fromVC: self)
        
       //cancenReservationAPICall()
        
    }
 
    @IBAction func homeButtonTapped(_ sender: Any) {
        Reservation.sharedInstance?.clearObject()
        var findCarVC:FindACarViewController?
        for viewController in self.navigationController!.viewControllers {
            if viewController.isKind(of: FindACarViewController.self) {
                findCarVC = viewController as? FindACarViewController
                break
            }
        }
        findCarVC?.shouldClearData = true
        self.navigationController?.popToViewController(findCarVC!, animated: true)
    }
    
    //MARK: API CALLS
    func cancenReservationAPICall()  {
        
        if NetworkReachabilityManager()!.isReachable {
            
            //Service Call
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true); NetworkManager.sharedInstance.cancelReservation(locaionId:  reservation.rentalLocationId!, lastname: (self.reservation.renterProfile?.lastName)!, confirmationNumber:  self.reservationNumberLabel.text!, onCompletion:{ (jsonResponse, error) -> Void in
                
                progressHUD.removeFromSuperview()
                if error != nil {
                    let error: Error = (error?.localizedDescription)! as! Error
                    print(error.localizedDescription)
                    AlertManager.sharedInstance.show(title: "Error", message: error.localizedDescription, fromVC: self)
                }else{
                    if jsonResponse?["status"].string == "error"  {
                        //Failure:
                        if let  messageValue = jsonResponse?["error"]["errorMessage"].string {
                            
                            
                           // AlertManager.sharedInstance.show(title: "Error", message: messageValue, fromVC: self)
                            
                            
                            let alertController = UIAlertController(title: "Error", message: messageValue, preferredStyle: .alert)
                            
                            
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                                self.dismiss(animated: true, completion: nil)
                            }
                            alertController.addAction(defaultAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }else{
                        
                        print(jsonResponse)
                        
                        if (jsonResponse?["Message"].dictionary?.count)! > 0 {
                            //Sucess Message
                            
                        
                            self.constraintscrollViewBottomSpace.priority = UILayoutPriorityDefaultLow
                            
                            self.reservationStatusLabel.text = "Your reservation has been canceled!"
                            self.cancelButton.isHidden = true
                            
                            self.constraintscrollViewBottomSpace.constant = 0
                            
                            /*
                            let alertController = UIAlertController(title: "Success", message: jsonResponse!["Message"]["MessageDescription"].string!, preferredStyle: .alert)
                            
                            
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                                
                                self.constraintscrollViewBottomSpace.priority = UILayoutPriorityDefaultLow
                               
                                self.reservationStatusLabel.text = "Your reservation has been canceled!"
                                self.cancelButton.isHidden = true
                                
                                self.constraintscrollViewBottomSpace.constant = 0
                                
                                //self.dismiss(animated: true, completion: nil)
                            }
                            alertController.addAction(defaultAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                            */
                            return
                            
                        }
                        if (jsonResponse?["error"].dictionary?.count)! > 0 {
                            //failure Message
                      
                            
                            let alertController = UIAlertController(title: "Error", message: (jsonResponse?["error"]["errorMessage"].string)!, preferredStyle: .alert)
                            


                            let defaultAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                                //self.dismiss(animated: true, completion: nil)
                            }
                            alertController.addAction(defaultAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                        }
                        
                        
                    }
                    
                }
            })
            
            
        } else {
            AlertManager.sharedInstance.show(title: "Error", message: "The Internet connection appears to be offline.", fromVC: self)
        }

    }
}

//MARK: Web View Controller Delegate
extension MyReservationViewController:WebViewControllerDelegate{
    func webViewControllerDidSelectAgree() {
        //        if shouldShowLocationPolicy {
        //            self.readLocationRentalPoliciesSwitch.setOn(true, animated: true)
        //        } else {
        //            self.termsAndConditionsSwitch.setOn(true, animated: true)
        //        }
    }
    
    func webViewControllerDidSelectCancel() {
        //        if shouldShowLocationPolicy {
        //            self.readLocationRentalPoliciesSwitch.setOn(false, animated: true)
        //        } else {
        //            self.termsAndConditionsSwitch.setOn(false, animated: true)
        //        }
    }
}

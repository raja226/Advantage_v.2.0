//
//  ReserveCarViewController.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 5/22/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import MBProgressHUD

class applyPromoCodeCell  : UITableViewCell {
    @IBOutlet weak var applyCodeButton: UIButton!
}

class ReserveCarViewController: LogoutFunctionalityViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, LoginTableViewCellDelegate, WebViewControllerDelegate, PaymentDetailsTableViewCellDelegate, PaymentBreakupViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var footerView: UIView!
    
    @IBOutlet weak var termsAndConditionsSwitch: UISwitch!
    @IBOutlet weak var readLocationRentalPoliciesSwitch: UISwitch!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    var profileDetailsArray = [ProfileField]()
    
    var datePicker : UIDatePicker!
    var pickerView : UIPickerView!
    
    var pickerViewDataSource = [Any]()
    var activeField: UITextField?
    
    var stateList:[USState]?
    
    let tagDateOfBirthTextField = 101
    let tagFirstNameTextField = 102
    let tagLastNameTextField = 103
    let tagPhoneNumberTextField = 104
    
    var tagEmailAddressTextField = -1
    var tagPasswordTextField = -1
    var tagConfirmPasswordTextField = -1
    var tagStreetAddressOneTextField = 105
    var tagStreetAddressTwoTextField = 106
    var tagPostalCodeTextField = 107
    var tagCityTextField = 108
    var tagStateTextField = 109
    
    let sectionOneTextFieldOffset = 100
    let sectionFourTextFieldOffset = 700
    
    var userLoyaltyProfile: UserLoyaltyProfile?
    
    var promoCodesDataSource = [[String: String]]()
    var promocodeAdded = 1
    
    var isGuestUser = false
    var clearField = false
    var isSummaryExpanded = false
    var isLoginCellExpanded = false
    
    var termsAndConditionsURLPath: String?
    var locationPolicyHTMLString: String?
    var shouldShowLocationPolicy = false
    
    var selectedState:USState?
    
    var hasPromocodeChanged = false
    
    var gotPayNowRequestBillResponse = false
    var gotPayLaterRequestBillResponse = false
    
    var preReservation: PreReservation?
    
    var shouldCallAddReservation = false
    var isComingFromPolicies = false
    
    var shouldShowPaymentBreakup = false
    
    var shouldShowAddReservationErrorMessage = false
    var addReservationErrorMessage = "Something went wrong. Please try again"
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.tableView.isHidden = true
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = self.footerView
        
        self.tableView.estimatedRowHeight = 68.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        setupDatePicker()
        setupPickerView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        buildPromocodesDataSource()
        
        NotificationCenter.default.addObserver(self, selector: #selector(paymentBreackupDismissed), name: Notification.Name("PaymentBreakupDismissed"), object: nil)
        
        self.isGuestUser = true
        self.buildProfileFieldsArray()
    }
    
    func paymentBreackupDismissed() {
        if shouldShowAddReservationErrorMessage {
            shouldShowAddReservationErrorMessage = false
            AlertManager.sharedInstance.show(title: "Error", message: addReservationErrorMessage, fromVC: self)
        }
    }
    
    func buildPromocodesDataSource() {
        if let promocodeList = Reservation.sharedInstance?.promoCodes {
            let validPromocodeList = promocodeList.filter{$0.code != nil}
            if validPromocodeList.count > 0 {
                for (index, promocode) in validPromocodeList.enumerated() {
                    var state = "remove"
                    if index == 0 && validPromocodeList.count < 4 {
                        state = "add"
                    }
                    let rowInfo = ["state":state, "value":promocode.code!, "payNowStatus":promocode.status!, "payLaterStatus": "", "lastAppliedValue":"", "PayNowPromoMsg":"", "PayLaterPromoMsg":""]
                    self.promoCodesDataSource.append(rowInfo)
                }
            } else {
                let rowInfo = ["state":"add", "value":"", "payNowStatus": "", "payLaterStatus": "", "lastAppliedValue":"", "PayNowPromoMsg":"", "PayLaterPromoMsg":""]
                self.promoCodesDataSource.append(rowInfo)
            }
        } else {
            let rowInfo = ["state":"add", "value":"","payNowStatus":"", "payLaterStatus":"", "lastAppliedValue":"", "PayNowPromoMsg":"", "PayLaterPromoMsg":""]
            self.promoCodesDataSource.append(rowInfo)
        }
        
        promocodeAdded = self.promoCodesDataSource.count
        
        let indexSet: IndexSet = [4]
        self.tableView.reloadSections(indexSet, with: .automatic)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.stateList == nil {
            initiateGetUSStates()
        }
        
        if isComingFromPolicies {
            isComingFromPolicies = false
        } else {
            updateCharges()
        }
    }
    
    @IBAction func showReservationDescriptionButtonTapped(_ sender: UIButton) {
        if isSummaryExpanded {
            isSummaryExpanded = false
        } else {
            isSummaryExpanded = true
        }
        let lastIndexPath = IndexPath(row: 0, section: 0)
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [lastIndexPath], with: .automatic)
        self.tableView.endUpdates()
    }
    
    @IBAction func editReservationSummaryButtonTapped(_ sender: UIButton) {
        var viewController: UIViewController?
        for navViewController in self.navigationController!.viewControllers {
            if navViewController.isKind(of: FindACarViewController.self) {
                viewController = navViewController
                break
            }
        }
        if let viewController = viewController {
            self.navigationController?.popToViewController(viewController, animated: true)
        }
    }
    
    @IBAction func toggleLoginCellButtonTapped(_ sender: UIButton) {
        if isLoginCellExpanded {
            isLoginCellExpanded = false
        } else {
            isLoginCellExpanded = true
        }
        let lastIndexPath = IndexPath(row: 0, section: 1)
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [lastIndexPath], with: .automatic)
        self.tableView.endUpdates()
    }
    
    func updateCharges() {
        trimPromocodes()
        var promoCodes = [String]()
        for rowInfo in  promoCodesDataSource {
            if rowInfo["value"] != "" {
                promoCodes.append(rowInfo["value"]!)
            }
        }
        
        // Calling request bill twice, once for Pay Now values and another for Pay Later values
        
        self.gotPayNowRequestBillResponse = false
        self.gotPayLaterRequestBillResponse = false
        
        if Reservation.sharedInstance!.selectedCar!.hasPostpaidOnly {
            self.gotPayNowRequestBillResponse = true
            serverFetchUpdatedChargeValues(prepaid: "N", promoCodes: promoCodes)
        } else {
            serverFetchUpdatedChargeValues(prepaid: "Y", promoCodes: promoCodes)
            serverFetchUpdatedChargeValues(prepaid: "N", promoCodes: promoCodes)
        }
    }
    
    func serverFetchUpdatedChargeValues(prepaid: String, promoCodes: [String]) {
        let progressHUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
        let serivceSuccessHandlerInVC : (_ billingData :BillingDetails) -> Void = {
            
            [weak self] (billingData :BillingDetails)  in
            progressHUD.removeFromSuperview()
            
            // Updating rate values after applying promo codes
            // Update values in SelectetCar object of Reservation object.
            if prepaid == "Y" {
                self?.gotPayNowRequestBillResponse = true
                Reservation.sharedInstance?.selectedCar?.payNowRate.dailyRate = billingData.dailyRate
                Reservation.sharedInstance?.selectedCar?.payNowRate.rateCharge = billingData.rateCharge
                Reservation.sharedInstance?.selectedCar?.payNowRate.totalRate = billingData.totalCharges
                
                Reservation.sharedInstance?.selectedCar?.payNowRate.totalExtras = billingData.extrasTotal
                Reservation.sharedInstance?.selectedCar?.payNowRate.totalTaxes = billingData.taxesTotal
                Reservation.sharedInstance?.selectedCar?.payNowRate.taxes = billingData.taxes
                Reservation.sharedInstance?.selectedCar?.payNowRate.extras = billingData.extras
                Reservation.sharedInstance?.selectedCar?.payNowRate.discountAmount = billingData.discountAmount
                Reservation.sharedInstance?.selectedCar?.payNowRate.discountPercent = billingData.discountPercent
                
                self?.updateStatus(serverPromocodes: billingData.promoCodes, updatePayNowPromocodes: true)
            } else {
                self?.gotPayLaterRequestBillResponse = true
                Reservation.sharedInstance?.selectedCar?.payLaterRate.dailyRate = billingData.dailyRate
                Reservation.sharedInstance?.selectedCar?.payLaterRate.rateCharge = billingData.rateCharge
                Reservation.sharedInstance?.selectedCar?.payLaterRate.totalRate = billingData.totalCharges
                
                Reservation.sharedInstance?.selectedCar?.payLaterRate.totalExtras = billingData.extrasTotal
                Reservation.sharedInstance?.selectedCar?.payLaterRate.totalTaxes = billingData.taxesTotal
                Reservation.sharedInstance?.selectedCar?.payLaterRate.extras = billingData.extras
                Reservation.sharedInstance?.selectedCar?.payLaterRate.taxes = billingData.taxes
                Reservation.sharedInstance?.selectedCar?.payLaterRate.discountAmount = billingData.discountAmount
                Reservation.sharedInstance?.selectedCar?.payLaterRate.discountPercent = billingData.discountPercent
                
                self?.updateStatus(serverPromocodes: billingData.promoCodes, updatePayNowPromocodes: false)
            }
            self?.updatePromocodeAndChargeValues()
        }
        
        let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
            (errorValue:Any)  in
            progressHUD.removeFromSuperview()
            print(errorValue)
            if let errorMessage = errorValue as? String {
                AlertManager.sharedInstance.show(title: "Failed", message: errorMessage, fromVC: self)
            } else if let error = errorValue as? Error {
                AlertManager.sharedInstance.show(title: "Error", message: error.localizedDescription, fromVC: self)
            }
        }
        
        var extraParameters: [String]?
        if (self.valueForField(tag: tagDateOfBirthTextField).isEmpty == false) && (self.renterAge() < 25) {
            extraParameters = ["UAGE"]
        }
        Reservation.sharedInstance?.vehicleOptions = extraParameters
        DataManager.sharedInstance.requestBillCall(reservationData: Reservation.sharedInstance!, promoCodes: promoCodes, prepaid: prepaid, serviceSuccessHandler: serivceSuccessHandlerInVC, extraOptions: extraParameters, serviceFailureHnadler: serviceFailureHandlerInVC)
    }
    
    func updateStatus(serverPromocodes: [PromoCode], updatePayNowPromocodes: Bool) {
        var serverPromocodes = serverPromocodes
        for (j, dataSource) in self.promoCodesDataSource.enumerated() {
            var index = -1
            for promocode in serverPromocodes {
                if let serverCode = promocode.code {
                    if dataSource["value"]?.caseInsensitiveCompare(serverCode) == .orderedSame {
                        index = index + 1
                        if updatePayNowPromocodes {
                            self.promoCodesDataSource[j]["payNowStatus"] = promocode.status
                            self.promoCodesDataSource[j]["PayNowPromoMsg"] = promocode.message
                        } else {
                            self.promoCodesDataSource[j]["payLaterStatus"] = promocode.status
                            self.promoCodesDataSource[j]["PayLaterPromoMsg"] = promocode.message
                        }
                        self.promoCodesDataSource[j]["lastAppliedValue"] = dataSource["value"]
                        break
                    }
                }
            }
            let dsfndsoin = serverPromocodes.index(where: { (item) -> Bool in
                if let itemCode = item.code, let dataSourceValue = dataSource["value"] {
                    return itemCode.caseInsensitiveCompare(dataSourceValue) == .orderedSame
                }
                return false
            })
            
            if let validIndex = dsfndsoin {
                serverPromocodes.remove(at: validIndex)
            }
        }
    }
    
    func updatePromocodeAndChargeValues() {
        // Update promocode and billing section
        if gotPayNowRequestBillResponse && gotPayLaterRequestBillResponse {
            hasPromocodeChanged = false
            let indexSet: IndexSet = [3, 4]
            self.tableView.reloadSections(indexSet, with: .automatic)
            
            if shouldShowPaymentBreakup {
                shouldShowPaymentBreakup = false
                self.performSegue(withIdentifier: "paymentBreakupSegue", sender: self)
            }
        }
    }
    
    func trimPromocodes() {
        for i in (0..<promoCodesDataSource.count).reversed() {
            var rowInfo = promoCodesDataSource[i]
            if rowInfo["value"] != "" {
                var promocode = rowInfo["value"]!
                promocode = promocode.trimmingCharacters(in: .whitespacesAndNewlines)
                rowInfo["value"] = promocode
                promoCodesDataSource[i] = rowInfo
            }
        }
    }
    
    func isThereChangeInPromocodes() -> (hasChange: Bool, promoCodes: [String]) {
        var promoCodes = [String]()
        var isThereChange = false
        for i in (0..<promoCodesDataSource.count).reversed() {
            var rowInfo = promoCodesDataSource[i]
            if rowInfo["value"] != "" {
                var promocode = rowInfo["value"]!
                promocode = promocode.trimmingCharacters(in: .whitespacesAndNewlines)
                rowInfo["value"] = promocode
                promoCodes.append(promocode)
                promoCodesDataSource[i] = rowInfo
                if rowInfo["value"]!.caseInsensitiveCompare(rowInfo["lastAppliedValue"]!) != .orderedSame {
                    isThereChange = true
                }
            }
        }
        if isThereChange || hasPromocodeChanged {
            return (true, promoCodes)
        }
        return (false, promoCodes)
    }
    
    @IBAction func applyPromoCodeButtonTapped(_ sender: Any) {
        let changeResult = isThereChangeInPromocodes()
        if changeResult.hasChange {
            updateCharges()
            self.activeField?.resignFirstResponder()
        } else if changeResult.promoCodes.count == 0 {
            AlertManager.sharedInstance.show(title: "Error", message: "Please enter promo code", fromVC: self)
        }
//        else {
//            AlertManager.sharedInstance.show(title: "Error", message: "No change in promo code", fromVC: self)
//        }
    }
    
    @IBAction func payNowSwitchTapped(_ sender: UISwitch) {
//        let changeResult = isThereChangeInPromocodes()
//        if changeResult.hasChange {
//            AlertManager.sharedInstance.show(title: "Error", message: "Please apply promo code", fromVC: self)
//            sender.setOn(sender.isOn, animated: true)
//        } else {
            if sender.isOn {
                Reservation.sharedInstance?.prepaid = "Y"
            } else {
                Reservation.sharedInstance?.prepaid = "N"
            }
//        }
        refreshProfileFields()
        self.tableView.reloadData()
    }
    
    @IBAction func payLaterSwitchTapped(_ sender: UISwitch) {
//        let changeResult = isThereChangeInPromocodes()
//        if changeResult.hasChange {
//            AlertManager.sharedInstance.show(title: "Error", message: "Please apply promo code", fromVC: self)
//            sender.setOn(sender.isOn, animated: true)
//        } else {
            if sender.isOn {
                Reservation.sharedInstance?.prepaid = "N"
            } else {
                Reservation.sharedInstance?.prepaid = "Y"
            }
            refreshProfileFields()
            self.tableView.reloadData()
//        }
    }
    
    @IBAction func saveButtonTapped(sender: UIButton) {
        
        assignValue()
        var requiredFieldsFilled = true
        
        let payOnline = Reservation.sharedInstance?.prepaid == "Y" ? true : false
        
        var validationTags = [tagDateOfBirthTextField, tagFirstNameTextField, tagLastNameTextField, tagPhoneNumberTextField, tagEmailAddressTextField, tagStreetAddressOneTextField, tagPostalCodeTextField, tagCityTextField, tagStateTextField]
        if payOnline == false {
            validationTags = [tagFirstNameTextField, tagLastNameTextField, tagPhoneNumberTextField, tagEmailAddressTextField]
        }
        
        for field in self.profileDetailsArray {
            if validationTags.contains(field.fieldTag) == false {
                continue
            }
            if field.fieldValue.isEmpty {
                requiredFieldsFilled = false
                AlertManager.sharedInstance.show(title: "Error", message: "\(field.fieldPlaceholder) is required", fromVC: self)
                break
            }
        }
        
        if requiredFieldsFilled {
            self.activeField?.resignFirstResponder()
            
            let emailAddress = valueForField(tag: tagEmailAddressTextField)
            let phoneNumber = valueForField(tag: tagPhoneNumberTextField)
            let postalCode = valueForField(tag: tagPostalCodeTextField)
            
            if phoneNumber.characters.count < 10 {
                AlertManager.sharedInstance.show(title: "Error", message: "Please enter valid Phone Number", fromVC: self)
            } else if Utilities.sharedInstance.validateEmail(enteredEmail: emailAddress) == false {
                AlertManager.sharedInstance.show(title: "Error", message: "Please enter valid email address", fromVC: self)
            } else if (postalCode.characters.count > 0) && (Utilities.sharedInstance.validatePostalCode(enteredPostalCode: postalCode) == false) {
                AlertManager.sharedInstance.show(title: "Error", message: "The postal code must contain 5 digits", fromVC: self)
            } else if self.readLocationRentalPoliciesSwitch.isOn == false {
                AlertManager.sharedInstance.show(title: "Error", message: "Please read and accept the Location Rental Policies.", fromVC: self)
            } else if self.termsAndConditionsSwitch.isOn == false {
                AlertManager.sharedInstance.show(title: "Error", message: "Please read and accept the Terms and Conditions.", fromVC: self)
            } else {
                // Call /requestBillMobile API first to show final taxes and fess break up
                self.shouldShowPaymentBreakup = true
                self.updateCharges()
            }
        }
    }
    
    func renterAge() -> Int {
        var renterAge = 25
        
        if let age = Calendar.current.dateComponents([.year], from: self.datePicker.date, to: Reservation.sharedInstance!.pickUpdateAsDate).year {
            renterAge = age
        }
        
        return renterAge
    }
    
    func serverAddReservation() {
        let payOnline = Reservation.sharedInstance?.prepaid == "Y" ? true : false
        
        var hasTotalTaxes = false
        if payOnline {
            if let _ = Reservation.sharedInstance?.selectedCar?.payNowRate.totalTaxes {
                hasTotalTaxes = true
            }
        } else {
            if let _ = Reservation.sharedInstance?.selectedCar?.payLaterRate.totalTaxes {
                hasTotalTaxes = true
            }
        }
        
        let renterProfile = UserLoyaltyProfile()
        renterProfile.dateOfBirth = valueForField(tag: tagDateOfBirthTextField)
        renterProfile.firstName = valueForField(tag: tagFirstNameTextField)
        renterProfile.lastName = valueForField(tag: tagLastNameTextField)
        renterProfile.phoneNumber = valueForField(tag: tagPhoneNumberTextField)
        renterProfile.email = valueForField(tag: tagEmailAddressTextField)
        renterProfile.streetAddress = valueForField(tag: tagStreetAddressOneTextField)
        renterProfile.streetAddressTwo = valueForField(tag: tagStreetAddressTwoTextField)
        renterProfile.postalCode = valueForField(tag: tagPostalCodeTextField)
        renterProfile.city = valueForField(tag: tagCityTextField)
        renterProfile.state = ""
        if let stateCode = self.selectedState?.stateCode {
            renterProfile.state = stateCode
        }
        Reservation.sharedInstance?.renterProfile = renterProfile
        
        if hasTotalTaxes {
            
            let progressHUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
            
            if payOnline == false {
                let serivceSuccessHandlerInVC : (_ confirmationNumber :String) -> Void = {
                    [weak self] (confirmationNumb :String)  in
                    progressHUD.removeFromSuperview()
                    Reservation.sharedInstance?.confirmationNumber = confirmationNumb
                    self?.performSegue(withIdentifier: "confirmationSegue", sender: self)
                }
                
                let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
                    (errorValue:Any)  in
                    progressHUD.removeFromSuperview()
                    print(errorValue)
                    self.shouldShowAddReservationErrorMessage = true
                    if let errorMessage = errorValue as? String {
                        self.addReservationErrorMessage = errorMessage
                    } else if let error = errorValue as? Error {
                        self.addReservationErrorMessage = error.localizedDescription
                    }
                }
                DataManager.sharedInstance.addReservationCall(Reservation.sharedInstance!,  serviceSuccessHandler: serivceSuccessHandlerInVC, serviceFailureHnadler: serviceFailureHandlerInVC)
            } else {
                let serivceSuccessHandlerInVC : (_ preReservation: PreReservation) -> Void = {
                    [weak self] (preReservation: PreReservation) in
                    progressHUD.removeFromSuperview()
                    if preReservation.addRezRequest == "" || preReservation.authToken == "" {
                        self?.shouldShowAddReservationErrorMessage = true
                    } else {
                        self?.preReservation = preReservation
                        self?.performSegue(withIdentifier: "paymentSegue", sender: self)
                    }
                }
                
                let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
                    (errorValue:Any)  in
                    progressHUD.removeFromSuperview()
                    print(errorValue)
                    self.shouldShowAddReservationErrorMessage = true
                    if let errorMessage = errorValue as? String {
                        self.addReservationErrorMessage = errorMessage
                    } else if let error = errorValue as? Error {
                        self.addReservationErrorMessage = error.localizedDescription
                    }
                }
                DataManager.sharedInstance.preReservationCall(Reservation.sharedInstance!,  serviceSuccessHandler: serivceSuccessHandlerInVC, serviceFailureHnadler: serviceFailureHandlerInVC)
            }
        } else {
            AlertManager.sharedInstance.show(title: "Error", message: "Can not proceed right now. Please try again later.", fromVC: self)
        }
    }
    
    func arePasswordsEqual() -> Bool {
        if isGuestUser {
            let password = valueForField(tag: tagPasswordTextField)
            let confirmPassword = valueForField(tag: tagConfirmPasswordTextField)
            return password == confirmPassword
        }
        return true
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func termsAndConditionButtonTapped(_ sender: Any) {
        self.initiateGetFormattedTermsAndConditions()
    }
    
    @IBAction func locationRentalPolicyButtonTapped(_ sender: Any) {
        self.initiateGetLocationPolicy()
    }
    
    func initiateGetLocationPolicy() {
        if let _ = self.locationPolicyHTMLString {
            self.shouldShowLocationPolicy = true
            self.performSegue(withIdentifier: "webViewSegue", sender: self)
        } else {
            let progressHUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
            let serivceSuccessHandlerInVC : (String) -> Void = {
                [weak self] (policyHTMLString: String)  in
                progressHUD.removeFromSuperview()
                self?.locationPolicyHTMLString = policyHTMLString
                self?.shouldShowLocationPolicy = true
                self?.performSegue(withIdentifier: "webViewSegue", sender: self)
            }
            
            let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
                (errorValue:Any)  in
                progressHUD.removeFromSuperview()
                print(errorValue)
                if let errorMessage = errorValue as? String {
                    AlertManager.sharedInstance.show(title: "Failed", message: errorMessage, fromVC: self)
                } else if let error = errorValue as? Error {
                    AlertManager.sharedInstance.show(title: "Error", message: error.localizedDescription, fromVC: self)
                } else {
                    AlertManager.sharedInstance.show(title: "Failed", message: "Please try again", fromVC: self)
                }
            }
            
            DataManager.sharedInstance.getPolicyCall(rentalLocationId: Reservation.sharedInstance!.rentalLocationId!, serviceSuccessHandler: serivceSuccessHandlerInVC, serviceFailureHandler: serviceFailureHandlerInVC)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webViewSegue" {
            self.isComingFromPolicies = true
            let webViewController = segue.destination as! WebViewController
            if shouldShowLocationPolicy {
                webViewController.shouldShowWebView = true
                webViewController.pageTitle = "Location Rental Policy"
                webViewController.pageDescription = self.locationPolicyHTMLString!
            } else {
                webViewController.shouldShowWebView = true
                webViewController.pageTitle = "Terms and Conditions"
                webViewController.pageDescription = self.termsAndConditionsURLPath!
            }
            webViewController.delegate = self
        } else if segue.identifier == "paymentSegue" {
            self.isComingFromPolicies = true
            let paymentController = segue.destination as! PaymentViewController
            paymentController.preReservation = self.preReservation!
        } else if segue.identifier == "paymentBreakupSegue" {
            self.isComingFromPolicies = true
            let paymentController = segue.destination as! PaymentBreakupViewController
            paymentController.delegate = self
        }
    }
    
    // VIMP: Do not delete this, it used for unwinding segue
    @IBAction func unwindFromViewController(segue:UIStoryboardSegue) {
        
    }
    
    func serverFetchLoyaltyProfile() {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        let serivceSuccessHandlerInVC : (UserLoyaltyProfile)->Void = {
            [weak self] (loyaltyProfile:UserLoyaltyProfile)  in
            progressHUD.removeFromSuperview()
            
            UserDefaults.standard.set(loyaltyProfile.firstName, forKey: "FirstName")
            
            self?.tableView.isHidden = false
            self?.isGuestUser = false
            self?.userLoyaltyProfile = loyaltyProfile
            
            UserDefaults.standard.set(self?.userLoyaltyProfile?.firstName, forKey: "FirstName")
            
            if let preferredReturnLocationCode = self?.userLoyaltyProfile?.preferredRentalLocationCode {
                UserDefaults.standard.set(self?.userLoyaltyProfile?.preferredRentalLocationCode, forKey: "preferredRentalLocationCode")
            }else{
                UserDefaults.standard.set("", forKey: "preferredRentalLocationCode")
            }
            
            if let preferredReturnLocationCode = self?.userLoyaltyProfile?.preferredReturnLocationCode {
                UserDefaults.standard.set(self?.userLoyaltyProfile?.preferredReturnLocationCode, forKey: "preferredReturnLocationCode")
            }else{
                UserDefaults.standard.set("", forKey: "preferredReturnLocationCode")
            }

            self?.buildProfileFieldsArray()
        }
        
        let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
            (errorValue:Any)  in
            print(errorValue)
            self.isGuestUser = true
            self.buildProfileFieldsArray()
            self.tableView.isHidden = false
            progressHUD.removeFromSuperview()
        }
        
        let memberNumber = UserDefaults.standard.double(forKey: "memberNumber")
        DataManager.sharedInstance.getLoyaltyProfileCall(memberNumber: memberNumber, serviceSuccessHandler: serivceSuccessHandlerInVC, serviceFailureHnadler: serviceFailureHandlerInVC)
    }
    
    func selectedStateName(stateCode: String) -> String {
        if let stateList = self.stateList {
            let selectedState = stateList.filter {$0.stateCode == stateCode}.last
            if selectedState != nil {
                self.selectedState = selectedState
                return selectedState!.stateName
            }
        }
        return ""
    }
    
    func selectedBirthDate(dob: String) {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "MM/dd/yyyy"
        if let date = dateFormatter1.date(from: dob) {
            self.datePicker.date = date
        }
    }
    
    func buildProfileFieldsArray() {
        
        let payOnline = Reservation.sharedInstance?.prepaid == "Y" ? true : false
        
        self.logoutButton.isHidden = false
        if isGuestUser {
            self.logoutButton.isHidden = true
            tagEmailAddressTextField = 105
            tagStreetAddressOneTextField = 106
            tagStreetAddressTwoTextField = 107
            tagPostalCodeTextField = 108
            tagCityTextField = 109
            tagStateTextField = 110
        }
        
        let stateField = ProfileField()
        stateField.fieldName = payOnline ? "State*" : "State"
        stateField.fieldPlaceholder = "State"
        stateField.fieldValue = isGuestUser ? "" : selectedStateName(stateCode: self.userLoyaltyProfile!.state!)
        stateField.fieldTag = tagStateTextField
        stateField.disablePasteOption = true
        
        let cityField = ProfileField()
        cityField.fieldName = payOnline ? "City*" : "City"
        cityField.fieldPlaceholder = "City"
        cityField.fieldValue = isGuestUser ? "" : self.userLoyaltyProfile!.city!
        cityField.fieldTag = tagCityTextField
        
        let postalField = ProfileField()
        postalField.fieldName = payOnline ? "Postal Code*" : "Postal Code"
        postalField.fieldPlaceholder = "Postal Code"
        postalField.fieldKeyboardType = .numberPad
        postalField.fieldValue = isGuestUser ? "" :  self.userLoyaltyProfile!.postalCode!
        postalField.fieldTag = tagPostalCodeTextField
        
        let streetTwoField = ProfileField()
        streetTwoField.fieldName = "Street Address"
        streetTwoField.fieldPlaceholder = "Street Address 2"
        streetTwoField.fieldValue = isGuestUser ? "" :  self.userLoyaltyProfile!.streetAddressTwo!
        streetTwoField.fieldTag = tagStreetAddressTwoTextField
        
        let streetOneField = ProfileField()
        streetOneField.fieldName = payOnline ? "Street Address*" : "Street Address"
        streetOneField.fieldPlaceholder = "Street Address"
        streetOneField.fieldValue = isGuestUser ? "" :  self.userLoyaltyProfile!.streetAddress!
        streetOneField.fieldTag = tagStreetAddressOneTextField
        
        let confirmPasswordField = ProfileField()
        confirmPasswordField.fieldName = "Confirm Password"
        confirmPasswordField.fieldPlaceholder = "Confirm Password"
        confirmPasswordField.isSecureTextEntry = true
        confirmPasswordField.fieldTag = tagConfirmPasswordTextField
        
        let passwordField = ProfileField()
        passwordField.fieldName = "Password"
        passwordField.fieldPlaceholder = "Password"
        passwordField.isSecureTextEntry = true
        passwordField.fieldTag = tagPasswordTextField
        
        let emailField = ProfileField()
        emailField.fieldName = "Email*"
        emailField.fieldPlaceholder = "Email"
        if isGuestUser {
            emailField.fieldValue = ""
        } else {
            let emailAddress = UserDefaults.standard.string(forKey: "loggedInUserEmailAddress")
            emailField.fieldValue = emailAddress!
            emailField.isEnabled = false
        }
        emailField.fieldKeyboardType = .emailAddress
        emailField.fieldTag = tagEmailAddressTextField
        
        let phoneField = ProfileField()
        phoneField.fieldName = "Phone Number*"
        phoneField.fieldPlaceholder = "Phone Number"
        phoneField.fieldKeyboardType = .phonePad
        phoneField.fieldValue = isGuestUser ? "" :  self.userLoyaltyProfile!.phoneNumber!.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        phoneField.fieldTag = tagPhoneNumberTextField
        
        let lnField = ProfileField()
        lnField.fieldName = "Last Name*"
        lnField.fieldPlaceholder = "Last Name"
        lnField.fieldValue = isGuestUser ? "" :  self.userLoyaltyProfile!.lastName!
        lnField.fieldTag = tagLastNameTextField
        lnField.autocapitalizationType = .sentences
        
        let fnField = ProfileField()
        fnField.fieldName = "First Name*"
        fnField.fieldPlaceholder = "First Name"
        fnField.fieldValue = isGuestUser ? "" :  self.userLoyaltyProfile!.firstName!
        fnField.fieldTag = tagFirstNameTextField
        fnField.autocapitalizationType = .sentences
        
        let dobField = ProfileField()
        dobField.fieldName = payOnline ? "Date of Birth*" : "Date of Birth"
        dobField.fieldPlaceholder = "Date of Birth"
        dobField.fieldValue = isGuestUser ? "" :  self.userLoyaltyProfile!.dateOfBirth!
        dobField.fieldTag = tagDateOfBirthTextField
        dobField.rightView = UIImageView(image: UIImage(named: "Calendar_Icon_"))
        dobField.rightViewMode = .always
        if let profile = self.userLoyaltyProfile {
            if let dob = profile.dateOfBirth {
                self.selectedBirthDate(dob: dob)
            }
        }
        dobField.disablePasteOption = true
        
        profileDetailsArray = [dobField, fnField, lnField, phoneField, emailField, streetOneField, streetTwoField, postalField, cityField, stateField]
        
        self.tableView.reloadData()
    }
    
    func refreshProfileFields() {
        let payOnline = Reservation.sharedInstance?.prepaid == "Y" ? true : false
        let validationTags = [tagDateOfBirthTextField, tagStreetAddressOneTextField, tagPostalCodeTextField, tagCityTextField, tagStateTextField]
        for field in self.profileDetailsArray {
            if validationTags.contains(field.fieldTag) == false {
                continue
            }
            if payOnline {
                // Add star
                field.fieldName = "\(field.fieldName)*"
            } else {
                // Remove star
                let index = field.fieldName.index(field.fieldName.endIndex, offsetBy: -1)
                let firstFiveCharString = field.fieldName.substring(to: index)
                field.fieldName = firstFiveCharString
            }
        }
    }
    
    func valueForField(tag: Int) -> String {
        if let profileField = self.profileDetailsArray.filter({ $0.fieldTag == tag }).last {
            return profileField.fieldValue
        }
        return ""
    }
    
    func loginButtonTapped(cell: LoginTableViewCell) {
        
        if cell.userNameTextField.text?.characters.count == 0 {
            AlertManager.sharedInstance.show(title: "Error", message: "Username can not be empty", fromVC: self)
        } else if Utilities.sharedInstance.validateEmail(enteredEmail: cell.userNameTextField.text!) == false {
            AlertManager.sharedInstance.show(title: "Error", message: "Please enter valid username", fromVC: self)
        } else if cell.passwordTextField.text?.characters.count == 0 {
            AlertManager.sharedInstance.show(title: "Error", message: "Password can not be empty", fromVC: self)
        } else {
            self.view.endEditing(true)
            
            let progressHUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
            let serivceSuccessHandlerInVC : (Login)->Void = {
                [weak self] (loginData:Login)  in
                progressHUD.removeFromSuperview()
                
                //FIXME: Temporary save in NSUserDefaults
                UserDefaults.standard.set(loginData.access_token, forKey: "access_token")
                UserDefaults.standard.set(loginData.memberNumber, forKey: "memberNumber")
                UserDefaults.standard.set(cell.userNameTextField.text!, forKey: "loggedInUserEmailAddress")
                UserDefaults.standard.set(loginData.loyalty_message, forKey: "loggedInUserLoyaltyStatus")
                UserDefaults.standard.synchronize()
                
                // Fetch get loyalty profile for this logged in user
                self?.serverFetchLoyaltyProfile()
            }
            
            let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
                (errorValue:Any)  in
                progressHUD.removeFromSuperview()
                print(errorValue)
                if let errorMessage = errorValue as? String {
                    AlertManager.sharedInstance.show(title: "Login Failed", message: errorMessage, fromVC: self)
                } else if let error = errorValue as? Error {
                    AlertManager.sharedInstance.show(title: "Error", message: error.localizedDescription, fromVC: self)
                } else {
                    AlertManager.sharedInstance.show(title: "Login Failed", message: "Please try again", fromVC: self)
                }
            }
            
            DataManager.sharedInstance.loginServiceCall(cell.userNameTextField.text!, cell.passwordTextField.text!, serviceSuccessHandler: serivceSuccessHandlerInVC, serviceFailureHnadler: serviceFailureHandlerInVC)
        }
    }
    
    func keyboardWillShow(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardRectangle.height, 0)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        UIView.animate(withDuration: 0.2, animations: { self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0) })
    }
    
    func initiateGetUSStates() {
        let progressHUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
        let serivceSuccessHandlerInVC : ([USState])->Void = {
            [weak self] (USStates:[USState])  in
            progressHUD.removeFromSuperview()
            self?.stateList = USStates
            if let _ = UserDefaults.standard.string(forKey: "access_token") {
                self?.isGuestUser = false
                if self?.userLoyaltyProfile == nil {
                    self?.serverFetchLoyaltyProfile()
                } else {
                    self?.tableView.isHidden = false
                }
            } else {
                self?.isGuestUser = true
                self?.buildProfileFieldsArray()
                self?.tableView.isHidden = false
            }
            self?.activeField?.becomeFirstResponder()
        }
        
        let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
            (errorValue:Any)  in
            progressHUD.removeFromSuperview()
            print(errorValue)
            if let _ = self.activeField {
                if let errorMessage = errorValue as? String {
                    AlertManager.sharedInstance.show(title: "Failed", message: errorMessage, fromVC: self)
                } else if let error = errorValue as? Error {
                    AlertManager.sharedInstance.show(title: "Error", message: error.localizedDescription, fromVC: self)
                } else {
                    AlertManager.sharedInstance.show(title: "Failed", message: "Please try again", fromVC: self)
                }
            }
        }
        
        DataManager.sharedInstance.getUSStatesServiceCall("Advantage", serviceSuccessHandler: serivceSuccessHandlerInVC, serviceFailureHnadler: serviceFailureHandlerInVC)
    }
    
    func setupDatePicker() {
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePickerMode.date
        self.datePicker.minimumDate = Reservation.sharedInstance!.minimumDateOfBirth()
        self.datePicker.maximumDate = Date()
        self.datePicker.date = Reservation.sharedInstance!.maximumDateOfBirth()
//        self.datePicker.addTarget(self, action: #selector(updateDateField), for: .valueChanged)
    }
    
    func updateDateField() {
        var renterAge = 25
        if let age = Calendar.current.dateComponents([.year], from: self.datePicker.date, to: Reservation.sharedInstance!.pickUpdateAsDate).year {
            renterAge = age
        }
        if renterAge < 21 {
            self.activeField?.text = ""
            self.datePicker.date = Reservation.sharedInstance!.maximumDateOfBirth()
            self.activeField!.resignFirstResponder()
            AlertManager.sharedInstance.show(title: "Error", message: "Driver under 21 may not rent a car.", fromVC: self)
        } else {
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "MM/dd/yyyy"
            self.activeField?.text = dateFormatter1.string(from: datePicker.date)
        }
        if let profileField = self.profileDetailsArray.filter({ $0.fieldTag == self.activeField!.tag }).last {
            profileField.fieldValue = self.activeField!.text!
        }
    }
    
    func setupPickerView() {
        self.pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
    }
    
    func setupKeyboardToolbar(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.barTintColor = UIColor(red: 44/255, green: 99/255, blue: 167/255, alpha: 1)
        toolBar.tintColor = UIColor.white
        toolBar.sizeToFit()
        
        let doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneBarButtonTapped))
        let spaceBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let nextBarButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextBarButtonTapped))
        let previousBarButton = UIBarButtonItem(title: "Prev", style: .done, target: self, action: #selector(previousBarButtonTapped))
        
        toolBar.setItems([doneBarButton, spaceBarButton, previousBarButton, nextBarButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    func doneBarButtonTapped() {
        assignValue()
        if self.activeField?.tag == tagDateOfBirthTextField {
            updateDateField()
        }
        self.view.endEditing(true)
        self.activeField?.resignFirstResponder()
        self.activeField = nil
    }
    
    func nextBarButtonTapped() {
        let nextTag = self.activeField!.tag + 1
        assignValue()
        if self.activeField?.tag == tagDateOfBirthTextField {
            self.updateDateField()
        }
        let nextResponder = self.tableView.viewWithTag(nextTag)
        if nextResponder is UITextField {
            if rowVisible() {
                nextResponder?.becomeFirstResponder()
            } else {
                self.activeField?.resignFirstResponder()
            }
        } else {
            self.activeField?.resignFirstResponder()
        }
    }
    
    func previousBarButtonTapped() {
        let previousTag = self.activeField!.tag - 1
        assignValue()
        if self.activeField?.tag == tagDateOfBirthTextField {
            self.updateDateField()
        }
        let nextResponder = self.tableView.viewWithTag(previousTag)
        if nextResponder is UITextField {
            if rowVisible() {
                nextResponder?.becomeFirstResponder()
            } else {
                self.activeField?.resignFirstResponder()
            }
        } else {
            self.activeField?.resignFirstResponder()
        }
    }
    
    func rowVisible() -> Bool {
        if self.activeField!.tag > 100 && self.activeField!.tag < 200 {
            let row = self.activeField!.tag - 101
            let indexPath = IndexPath(row: row, section: 2)
            if self.tableView.indexPathsForVisibleRows!.contains(indexPath) {
                return true
            }
            return false
        } else if self.activeField!.tag == 10 || self.activeField!.tag == 11 {
            let indexPath = IndexPath(row: 0, section: 1)
            if self.tableView.indexPathsForVisibleRows!.contains(indexPath) {
                return true
            }
            return false
        }
        return true
    }
    
    func assignValue() {
        if activeField != nil {
            if self.activeField?.tag == tagStateTextField {
                let state = self.stateList?[self.pickerView.selectedRow(inComponent: 0)]
                self.selectedState = state
                self.activeField?.text = state?.stateName
            }
//            else if self.activeField?.tag == tagDateOfBirthTextField {
//                self.updateDateField()
//            }
            
            if let profileField = self.profileDetailsArray.filter({ $0.fieldTag == self.activeField!.tag }).last {
                profileField.fieldValue = self.activeField!.text!
            }
        }
    }
    
    //MARK: UITableView Delegate / Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section ==  1 {
            if isGuestUser {
                return 1
            }
            return 0
        } else if section == 2 {
            return profileDetailsArray.count
        } else if section == 4 {
            return promoCodesDataSource.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        
        switch section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryCell") as? ReservationSummaryCell
            
            cell?.shouldShowCarSection = true
            cell?.manageUserInterface(showFullSummary: isSummaryExpanded)
            
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoginCell", for: indexPath) as? LoginTableViewCell
            
            cell?.setCellData(showExpanded: self.isLoginCellExpanded)
            cell?.delegate = self
            
            return cell!
            
        case 2:
            let profileField = profileDetailsArray[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileMyDetailsCell", for: indexPath) as? EditProfileMyDetailsTableViewCell
            if profileField.fieldTag == tagDateOfBirthTextField {
                cell?.detailTextField.inputView = self.datePicker
            } else if profileField.fieldTag == tagStateTextField {
                cell?.detailTextField.inputView = self.pickerView
            } else {
                cell?.detailTextField.inputView = nil
            }
            cell?.setCellData(profileField: profileDetailsArray[indexPath.row], isReservePage: true)
            cell?.constraintTitleLabelWidth.constant = 120
            
            return cell!
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as?PaymentDetailsTableViewCell
            cell?.delegate = self
            let currencyCode = Reservation.sharedInstance?.selectedCar?.currencyCode
            if let payOnlineTotal = Reservation.sharedInstance?.selectedCar?.payNowRate.totalRate {
                cell?.payNowTotalLabel.text = Utilities.displayRateWithCurrency(rate: payOnlineTotal, currency: currencyCode)
            }
            if let payLaterTotal = Reservation.sharedInstance?.selectedCar?.payLaterRate.totalRate {
                cell?.payLaterTotalLabel.text = Utilities.displayRateWithCurrency(rate: payLaterTotal, currency: currencyCode)
            }
            if Reservation.sharedInstance?.prepaid == "Y" {
                cell?.payNowSwitch.setOn(true, animated: true)
                cell?.payLaterSwitch.setOn(false, animated: true)
                cell?.payNowTotalLabel.textColor = UIColor(red: 0/255, green: 0/255, blue: 51/255, alpha: 1)
                cell?.payLaterTotalLabel.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
            } else {
                cell?.payLaterSwitch.setOn(true, animated: true)
                cell?.payNowSwitch.setOn(false, animated: true)
                cell?.payLaterTotalLabel.textColor = UIColor(red: 0/255, green: 0/255, blue: 51/255, alpha: 1)
                cell?.payNowTotalLabel.textColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
            }
            
            if Reservation.sharedInstance!.selectedCar!.hasPostpaidOnly {
                cell?.payNowStackView.isHidden = true
                cell?.payNowSwitch.isHidden = true
                cell?.payNowTotalLabel.isHidden = true
                cell?.payLaterSwitch.isEnabled = false
            } else {
                cell?.payNowStackView.isHidden = false
                cell?.payNowSwitch.isHidden = false
                cell?.payNowTotalLabel.isHidden = false
                cell?.payLaterSwitch.isEnabled = true
            }
            
            return cell!
            
        case 4:
            
            let rowInfo = promoCodesDataSource[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: promoCodeCellId, for: indexPath) as! PromoCodeCell
            
            cell.rowTextField.delegate = self
            cell.rowTextField.text = rowInfo["value"]
            cell.rowAddRemoveButton.tag = indexPath.row
            cell.rowTextField.tag =  sectionFourTextFieldOffset + indexPath.row
            cell.rowAddRemoveButton.addTarget(self, action: #selector(addDeletePromoCodeButtonTapped), for: .touchUpInside)
            cell.rowAddRemoveButton.setImage(UIImage(named: "Add_Icon"), for: .normal)
            if rowInfo["state"] == "remove" {
                cell.rowAddRemoveButton.setImage(UIImage(named: "Close_icon"), for: .normal)
            }
            cell.codeValidationLabel.isHidden = true
            cell.lineSepratorView.backgroundColor = UIColor(red: 204/255, green:204/255, blue: 204/255, alpha: 1)
            cell.rowTextField?.textColor = UIColor(red: 0/255, green: 0/255, blue: 51/255, alpha: 1)
            
            var status = rowInfo["payLaterStatus"]
            var message = rowInfo["PayLaterPromoMsg"]
            if Reservation.sharedInstance?.prepaid == "Y" {
                message = rowInfo["PayNowPromoMsg"]
                status = rowInfo["payNowStatus"]
            }
            if status != "" {
                cell.codeValidationLabel.isHidden = false
                cell.codeValidationLabel.text = message
                if status == "OK"  {
                    cell.codeValidationLabel.textColor = UIColor(red: 153/255, green: 204/255, blue: 0/255, alpha: 1)
                } else {
                    cell.lineSepratorView.backgroundColor = UIColor(red: 198/255, green: 17/255, blue: 17/255, alpha: 1)
                    cell.rowTextField?.textColor = UIColor(red: 198/255, green: 17/255, blue: 17/255, alpha: 1)
                    cell.codeValidationLabel.textColor = UIColor(red: 198/255, green: 17/255, blue: 17/255, alpha: 1)
                }
            }
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? applyPromoCodeCell
            cell?.applyCodeButton.layer.borderWidth = 1
            cell?.applyCodeButton.layer.cornerRadius = 8
            cell?.applyCodeButton.layer.borderColor = UIColor(red: 0/255, green: 83/255, blue: 159/255, alpha: 1).cgColor
            return cell!
        default :return UITableViewCell()
        }
    }
    
    func addDeletePromoCodeButtonTapped(sender: UIButton) {
        
        let buttonPosition = sender.convert(CGPoint(), to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at:buttonPosition)!
        
        var clickedRowInfo = promoCodesDataSource[indexPath.row]
        if clickedRowInfo["state"] == "add" {
            
            promocodeAdded = promocodeAdded + 1
            var addingRowInfo = ["state":"add", "value":"","payNowStatus":"", "payLaterStatus":"", "lastAppliedValue":"", "PayNowPromoMsg":"", "PayLaterPromoMsg":""]
            if promocodeAdded == 4 {
                addingRowInfo["state"] = "remove"
            }
            self.promoCodesDataSource.insert(addingRowInfo, at: indexPath.row)
            let localIndexPath = IndexPath(row: indexPath.row, section: 4)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [localIndexPath], with: .automatic)
            self.tableView.endUpdates()
            
            // Update current row
            sender.setImage(UIImage(named: "Close_icon"), for: .normal)
            clickedRowInfo["state"] = "remove"
            self.promoCodesDataSource[indexPath.row+1] = clickedRowInfo
        } else {
            var clickedRowInfo = promoCodesDataSource[indexPath.row]
            if clickedRowInfo["value"] != "" {
                hasPromocodeChanged = true
            }
            promocodeAdded = promocodeAdded - 1
            self.promoCodesDataSource.remove(at: indexPath.row)
            let indexPath = IndexPath(row: indexPath.row, section: 4)
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            
            // Make sure we have 1 plus button
            if promocodeAdded == 3 ||  promocodeAdded == 2 || promocodeAdded == 1 {
                var firstCodeRowInfo = self.promoCodesDataSource.first!
                firstCodeRowInfo["state"] = "add"
                self.promoCodesDataSource[0] = firstCodeRowInfo
                let lastIndexPath = IndexPath(row: 0, section: 4)
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [lastIndexPath], with: .automatic)
                self.tableView.endUpdates()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let section = indexPath.section
        
        switch section {
        case 0:
            if isSummaryExpanded {
                return 175 + heightOfLocationNameAndAddress()
            } else {
                return 135
            }
        case 1:
            if isGuestUser {
                if isLoginCellExpanded {
                    return 350
                }
                return 74
            }
            return 0
        case 2:
            return 54
        case 3:
            if Reservation.sharedInstance!.selectedCar!.hasPostpaidOnly {
               return 170
            }
            return 226
        case 4:
            return UITableViewAutomaticDimension
        case 5:
            return 0 // 110
        default :return 0
        }
    }
    
    func heightOfLocationNameAndAddress() -> CGFloat {
        let locationFont = UIFont(name: "Montserrat-Medium", size: 10)!
        let rentalLocationHeight = heightForText(text: Reservation.sharedInstance!.rentalLocation!.addLine1!, font: locationFont)
        let returnLocationHeight = heightForText(text: Reservation.sharedInstance!.returnLocation!.addLine1!, font: locationFont)
        
        let addressFont = UIFont(name: "Montserrat-Regular", size: 10)!
        let rentalAddressHeight = heightForText(text: Utilities.sharedInstance.locationAddress(location: Reservation.sharedInstance!.rentalLocation!), font: addressFont)
        let returnAddressHeight = heightForText(text: Utilities.sharedInstance.locationAddress(location: Reservation.sharedInstance!.returnLocation!), font: addressFont)
        
        let maxLocationHeight = rentalLocationHeight > returnLocationHeight ? rentalLocationHeight : returnLocationHeight
        let maxAddressHeight = rentalAddressHeight > returnAddressHeight ? rentalAddressHeight : returnAddressHeight
        return maxAddressHeight + maxLocationHeight
    }
    
    func heightForText(text: String, font: UIFont) -> CGFloat {
        let width = (self.view.frame.size.width - 98)/2
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        
        var returnHeight: CGFloat = 24
        let labelText = text
        label.text = labelText
        label.sizeToFit()
        returnHeight = label.frame.height
        return returnHeight
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 2 || section == 4 {
            let headerView = UIView(frame: CGRect(x: 5, y: 0, width: self.view.frame.width, height: 40))
            
            let headerTitle = UILabel(frame: CGRect(x: 30, y: 0, width: self.view.frame.width-20, height: 40))
            headerTitle.center = headerView.center
            headerTitle.textAlignment = .left
            headerTitle.baselineAdjustment = .alignCenters
            headerTitle.textColor = UIColor(red: 0, green: 159/255, blue: 221/255, alpha: 1.0)
            headerTitle.font = UIFont(name: "Montserrat-Medium", size: 15.0)
            if section == 2 {
                headerTitle.text = "Renter Information"
            }
            if section == 4 {
                headerTitle.text = "Promo or Corporate Code"
            }
            headerView.addSubview(headerTitle)
            
            return headerView
        }
        return UIView(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 || section == 4 {
            return 30
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect.zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    //MARK: UIPickerView Delegate / Datasource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerViewDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributes = [NSForegroundColorAttributeName:UIColor.black, NSFontAttributeName: UIFont(name: "Montserrat", size: 18)!]
        if self.activeField?.tag == tagStateTextField {
            let state = self.stateList![row]
            self.selectedState = state
            return NSAttributedString(string: state.stateName, attributes: attributes)
        }
        return NSAttributedString(string: "")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.activeField?.tag == tagStateTextField {
            let state = self.stateList?[row]
            self.selectedState = state
            self.activeField?.text = state?.stateName
        }
    }
    
    // MARK: - Text Field Delegates
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag >= sectionOneTextFieldOffset && textField.tag < sectionFourTextFieldOffset {
            setupKeyboardToolbar(textField: textField)
        }
        assignValue()
        self.activeField = textField
        if textField.tag == tagStateTextField {
            if self.stateList == nil {
                self.activeField?.resignFirstResponder()
                initiateGetUSStates()
                return false
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeField = textField
        
        if activeField?.tag == tagStateTextField {
            if let stateList = self.stateList {
                self.pickerViewDataSource = stateList
            }
            self.pickerView.reloadAllComponents()
            if activeField?.text?.isEmpty == false {
                let index = self.stateList?.index(where:{$0.stateName == activeField!.text})
                if let index = index {
                    self.pickerView.selectRow(index, inComponent: 0, animated: false)
                } else {
                    self.pickerView.selectRow(0, inComponent: 0, animated: false)
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag >= sectionFourTextFieldOffset {
            hasPromocodeChanged = true
            let cellPosition = textField.convert(CGPoint(), to:self.tableView)
            let indexPath = self.tableView.indexPathForRow(at:cellPosition)!
            if indexPath.section == 4 {
                let cell: PromoCodeCell = tableView.cellForRow(at: indexPath) as! PromoCodeCell
                cell.lineSepratorView.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
                cell.rowTextField?.textColor = UIColor(red: 0/255, green: 0/255, blue: 51/255, alpha: 1)
                cell.codeValidationLabel.isHidden = true
                promoCodesDataSource[indexPath.row]["payNowStatus"] = ""
                promoCodesDataSource[indexPath.row]["payLaterStatus"] = ""
            }
            
            let completeString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let textFieldPosition = textField.convert(CGPoint.zero, to: self.tableView)
            if let indexPath = self.tableView.indexPathForRow(at: textFieldPosition) {
                var clickedRowInfo = self.promoCodesDataSource[indexPath.row]
                clickedRowInfo["value"] = completeString
                self.promoCodesDataSource[indexPath.row] = clickedRowInfo
            }
        }
        if textField.tag == tagPostalCodeTextField {
            guard let text = textField.text else { return true }
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            let newLength = text.characters.count + string.characters.count - range.length
            return (newLength <= 5) && (string == numberFiltered)
        } else if textField.tag == tagPhoneNumberTextField {
            guard let text = textField.text else { return true }
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            let newLength = text.characters.count + string.characters.count - range.length
            return (newLength <= 13) && (string == numberFiltered)
//            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
//            let components = (newString as NSString).components(separatedBy: NSCharacterSet.decimalDigits.inverted)
//            
//            let decimalString = components.joined(separator: "") as NSString
//            let length = decimalString.length
//            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
//            
//            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
//                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
//                return (newLength > 10) ? false : true
//            }
//            var index = 0 as Int
//            let formattedString = NSMutableString()
//            
//            if hasLeadingOne {
//                formattedString.append("1 ")
//                index += 1
//            }
//            if (length - index) > 3 {
//                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
//                formattedString.appendFormat("(%@) ", areaCode)
//                index += 3
//            }
//            if length - index > 3 {
//                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
//                formattedString.appendFormat("%@-", prefix)
//                index += 3
//            }
//            
//            let remainder = decimalString.substring(from: index)
//            formattedString.append(remainder)
//            textField.text = formattedString as String
//            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool  {
        if textField.tag >= sectionFourTextFieldOffset {
            textField.resignFirstResponder()
            return true
        } else {
            nextBarButtonTapped()
            return false
        }
    }
    
    func initiateGetFormattedTermsAndConditions() {

        if let _ = self.termsAndConditionsURLPath {
            self.shouldShowLocationPolicy = false
            self.performSegue(withIdentifier: "webViewSegue", sender: self)
        } else {
            let progressHUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
            let serivceSuccessHandlerInVC : (String) -> Void = {
                [weak self] (policyHTMLString: String)  in
                progressHUD.removeFromSuperview()
                self?.termsAndConditionsURLPath = policyHTMLString
                self?.shouldShowLocationPolicy = false
                self?.performSegue(withIdentifier: "webViewSegue", sender: self)
            }
            
            let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
                (errorValue:Any)  in
                progressHUD.removeFromSuperview()
                print(errorValue)
                if let errorMessage = errorValue as? String {
                    AlertManager.sharedInstance.show(title: "Failed", message: errorMessage, fromVC: self)
                } else if let error = errorValue as? Error {
                    AlertManager.sharedInstance.show(title: "Error", message: error.localizedDescription, fromVC: self)
                } else {
                    AlertManager.sharedInstance.show(title: "Failed", message: "Please try again", fromVC: self)
                }
            }
            
            DataManager.sharedInstance.getFormattedTermsAndConditionsServiceCall("Advantage", locationId: Reservation.sharedInstance!.rentalLocationId!, serviceSuccessHandler: serivceSuccessHandlerInVC, serviceFailureHnadler: serviceFailureHandlerInVC)
        }
    }
    
    //MARK: Web View Controller Delegate
    func webViewControllerDidSelectAgree() {
        if shouldShowLocationPolicy {
            self.readLocationRentalPoliciesSwitch.setOn(true, animated: true)
        } else {
            self.termsAndConditionsSwitch.setOn(true, animated: true)
        }
    }
    
    func webViewControllerDidSelectCancel() {
        if shouldShowLocationPolicy {
            self.readLocationRentalPoliciesSwitch.setOn(false, animated: true)
        } else {
            self.termsAndConditionsSwitch.setOn(false, animated: true)
        }
    }
    
    //MARK: PaymentDetailsTableViewCellDelegate
    func paymentDetailsCellDidUpdatePaySwitch() {
        let indexSet: IndexSet = [4]
        self.tableView.reloadSections(indexSet, with: .automatic)
    }

    //MARK: PaymentBreakupViewControllerDelegate
    func paymentBreakupViewControllerDidSelectYes() {
        self.serverAddReservation()
    }
}

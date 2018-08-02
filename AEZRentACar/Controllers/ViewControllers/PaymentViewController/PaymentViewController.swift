//
//  PaymentViewController.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 8/1/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import Alamofire

class PaymentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var isSummaryExpanded = false
    
    var preReservation = PreReservation()
    
    var firstTimeShowSummary = true
    var hasWebViewStartLoading = false
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let indexSet: IndexSet = [0]
        self.tableView.reloadSections(indexSet, with: .automatic)
        self.tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let scrollInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
            self.tableView.contentInset = scrollInsets
            self.tableView.scrollIndicatorInsets = scrollInsets
            
            let contentOffset = CGPoint(x: 0, y: heightOfCell(isSummaryExpanded: isSummaryExpanded))
            self.tableView.contentOffset = contentOffset
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.tableView.contentInset = UIEdgeInsets.zero
        self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    func createRequest() throws -> URLRequest {
        
        let parameters = ["auth_token":preReservation.authToken, "reservation_data":preReservation.addRezRequest]
        
        let boundary = "----WebKitFormBoundaryCHFjAHyHoalWB7RI"
        
        let url = URL(string: "https://www.advantage.com/Payment/pay.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try createBody(with: parameters, boundary: boundary)
        
        return request
    }
    
    func createBody(with parameters: [String: String], boundary: String) throws -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        
        return body
    }
    
    //MARK: UIWebView Delegate
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let body = request.httpBody {
            hasWebViewStartLoading = true
            print(request)
            let bodyString = String(data: body, encoding: String.Encoding.utf8) as String!
            let keyValueArray = bodyString?.components(separatedBy: "&")
            print("keyValueArray : \(keyValueArray)")
            if let someArray = keyValueArray?.map({
                (value: String) -> (String,String) in
                let keyValue = value.components(separatedBy: "=")
                return (key: keyValue[0], value:keyValue[1] )
            }) {
                print("someArray : \(someArray)")
                var responseInfo = [String:String]()
                for tuple in someArray {
                    responseInfo[tuple.0] = tuple.1
                }
                if let status = responseInfo["Status"] {
                    if status == "OK" {
                        let confirmationNumber = responseInfo["ConfirmationNumber"]
                        if confirmationNumber != nil {
                            Reservation.sharedInstance?.confirmationNumber = confirmationNumber
                            assignBillingInformation(responseInfo: responseInfo)
                            self.performSegue(withIdentifier: "confirmationSegue", sender: self)
                            return false
                        } else {
                            AlertManager.sharedInstance.show(title: "Error", message: "Something went wrong", fromVC: self)
                        }
                    } else {
                        if let errorMessage = responseInfo["errorMessage"] {
                            AlertManager.sharedInstance.show(title: "Error", message: errorMessage, fromVC: self)
                        } else {
                            AlertManager.sharedInstance.show(title: "Error", message: "Something went wrong", fromVC: self)
                        }
                    }
                }
            }
        }
        return true
    }

    func assignBillingInformation(responseInfo: [String:String]) {
        let billingProfile = UserLoyaltyProfile()
        billingProfile.streetAddress = responseInfo["Street"]
        billingProfile.postalCode = responseInfo["Zip"]
        billingProfile.city = responseInfo["City"]
        billingProfile.state = responseInfo["State"]
        billingProfile.country = responseInfo["Country"]
        
        Reservation.sharedInstance?.billingProfile = billingProfile
        
        Reservation.sharedInstance?.cardNumber = responseInfo["CardLastFour"]
        Reservation.sharedInstance?.cardType = responseInfo["CardType"]
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showReservationDescriptionButtonTapped(_ sender: UIButton) {
        if isSummaryExpanded {
            isSummaryExpanded = false
        } else {
            isSummaryExpanded = true
        }
                
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        self.tableView.endUpdates()
        
        if firstTimeShowSummary {
            self.tableView.reloadData()
        }
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
    
    @IBAction func editCarButtonTapped(_ sender: UIButton) {
        var viewController: UIViewController?
        for navViewController in self.navigationController!.viewControllers {
            if navViewController.isKind(of: ChooseACarViewController.self) {
                viewController = navViewController
                break
            }
        }
        if let viewController = viewController {
            self.navigationController?.popToViewController(viewController, animated: true)
        }
    }
    
    //MARK: UITableView Delegate / Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryCell") as? ReservationSummaryCell
            cell?.shouldShowCarSection = true
            cell?.manageUserInterface(showFullSummary: isSummaryExpanded)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WebViewCell")
            if hasWebViewStartLoading == false {
                if let paymentWebView = cell?.viewWithTag(585) as? UIWebView {
                    paymentWebView.scalesPageToFit = false
                    paymentWebView.scrollView.bounces = false
                    paymentWebView.delegate = self
                    do {
                        let request = try createRequest()
                        paymentWebView.loadRequest(request)
                    } catch {
                        print(error)
                    }
                }
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return heightOfCell(isSummaryExpanded: isSummaryExpanded)
        } else {
            return self.view.frame.size.height - self.tableView.frame.origin.y - heightOfCell(isSummaryExpanded: isSummaryExpanded)
        }
    }
    
    func heightOfCell(isSummaryExpanded: Bool) -> CGFloat {
        if isSummaryExpanded {
            let value = 175 + heightOfLocationNameAndAddress()
            return value
        } else {
            return 135
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
}

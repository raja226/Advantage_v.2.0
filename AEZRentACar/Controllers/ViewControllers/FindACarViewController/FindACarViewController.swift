//
//  FindACarViewController.swift
//  AEZRentACar
//
//  Created by Anjali Panjawani on 6/29/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit
import QuartzCore
import MBProgressHUD
import SwiftyJSON

class PromoCodeCell: UITableViewCell {
    @IBOutlet weak var rowTextField: UITextField!
    @IBOutlet weak var rowAddRemoveButton: UIButton!
    @IBOutlet weak var codeValidationLabel: UILabel!
    @IBOutlet weak var lineSepratorView: UIView!
}

let promoCodeCellId = "PromoCodeCell"

let tagRentalDateTextField = 400
let tagRentalTimeTextField = 401
let tagReturnDateTextField = 402
let tagReturnTimeTextField = 403
let tagRentalLocationTextField = 501
let tagReturnLocationTextField = 502



class FindACarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, LocationSearchResultsViewControllerDelegate, DatePickerViewControllerDelegate {
    var loginDataSouce = LoginViewController()

    @IBOutlet var headerView: FindACarHeaderView!
    @IBOutlet weak var findCarTableView: UITableView!
    
    @IBOutlet weak var constraintBannerImageViewHeight: NSLayoutConstraint!
    
    var promoCodesDataSource = [[String: String]]()
    var aezRates: AEZRates?
    var promocodeAdded = 1
    
    var activeField: UITextField?
    
    var locationobject: Location?

    var rentalLocation: Location?
    var returnLocation: Location?
    var rentalDate: Date?
    var rentalTime: Date?
    var returnDate: Date?
    var returnTime: Date?
    
    var tableViewTopInset: CGFloat = 148
    
    var shouldClearData = false
    
    //Creating Viewcontroller Object
    var sidementViewObject = UIViewController()
    
    var preferedrentalLocationValue : String?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       loginDataSouce.custumdelegate = self
        //Notification For First Time Login
          NotificationCenter.default.addObserver(self, selector: #selector(userinfo), name: Notification.Name("FindACarPreferrredLocationData"), object: nil)
        
        //Notification logOut
        NotificationCenter.default.addObserver(self, selector: #selector(userinfo), name: Notification.Name("Logout"), object: nil)
        
        //Notification BookingAnother
        NotificationCenter.default.addObserver(self, selector: #selector(userinfo), name: Notification.Name("BookingAnother"), object: nil)
        
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let rowInfo1 = ["rowIdentifier":promoCodeCellId, "rowTitle":"Promo Code", "rowHeight":"50", "state":"add", "value":""]
        
        self.promoCodesDataSource = [rowInfo1]
        
        self.findCarTableView.tableFooterView = UIView()
        self.findCarTableView.tableHeaderView = self.headerView
        
        if UIScreen.main.bounds.size.width == 375 {
            self.constraintBannerImageViewHeight.constant = 246
            tableViewTopInset = 173
        } else if UIScreen.main.bounds.size.width == 414 {
            self.constraintBannerImageViewHeight.constant = 271
            tableViewTopInset = 190
        }
        
        self.findCarTableView.contentInset = UIEdgeInsetsMake(tableViewTopInset, 0, 0, 0)
        
        // Give drop shadow to views
        let shadowColor = UIColor(red: 28.0/255.0, green: 47.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
        //for shadow
        let dateTimeContainerView:UIView = UIView(frame:self.headerView.dateTimeView.frame)
        dateTimeContainerView.backgroundColor = UIColor.clear
        dateTimeContainerView.layer.shadowColor = shadowColor
        dateTimeContainerView.layer.shadowOffset =  CGSize(width: 0, height: 5)
        dateTimeContainerView.layer.shadowOpacity = 0.13
        dateTimeContainerView.layer.shadowRadius = 7
        
        //for rounded corners
        self.headerView.dateTimeView.layer.cornerRadius = 10
        self.headerView.dateTimeView.layer.masksToBounds = true
        self.headerView.addSubview(dateTimeContainerView)
        dateTimeContainerView.addSubview( self.headerView.dateTimeView)
        
        //for shadow
        let locationContainerView:UIView = UIView(frame:self.headerView.locationView.frame)
        locationContainerView.backgroundColor = UIColor.clear
        locationContainerView.layer.shadowColor = shadowColor
        locationContainerView.layer.shadowOffset =  CGSize(width: 0, height: 5)
        locationContainerView.layer.shadowOpacity = 0.13
        locationContainerView.layer.shadowRadius = 7
        
        //for rounded corners
        self.headerView.locationView.layer.cornerRadius = 10
        self.headerView.locationView.layer.masksToBounds = true
        self.headerView.addSubview(locationContainerView)
        locationContainerView.addSubview( self.headerView.locationView)
    }
    
    //MARK: Notification Received
    
    
    func userinfo(notification: NSNotification){
        
        if notification.name.rawValue == "BookingAnother" {
      
          preferedrentalLocationValue = ""
            
            if let firstName:String = UserDefaults.standard.object(forKey: "FirstName") as? String {
                
                if firstName == "" {
                    //logout
                }else{
                    if let preferredRentalLocationCode:String = UserDefaults.standard.object(forKey: "preferredRentalLocationCode") as? String {
                        
                        if  preferredRentalLocationCode == "" {
                            
                        }else {
                            preferedrentalLocationValue = preferredRentalLocationCode as? String
                            
                            
                            if let preferredReturnLocationCode:String = UserDefaults.standard.object(forKey: "preferredReturnLocationCode") as? String {
                                
                                
                                if preferredReturnLocationCode == "" {
                                 
                                }else{
                                    
                                    if preferredReturnLocationCode.count >= 1 {
                                        if preferredReturnLocationCode == preferedrentalLocationValue {
                                            
                                        }else{
                                            
                                            preferedrentalLocationValue = preferedrentalLocationValue! + "," + preferredReturnLocationCode
                                        }
                                    }
                                    
                                    
                                }
                                
                            }
                          print(preferedrentalLocationValue)
                            preferredlocationAPICall()

                            
                        }
                        
                        
                        
                        
                        
                        
                    }
                    

                }
                
                
                
            }else{
                print("Negative case fail")
            }
          
        }
        
        else if notification.name.rawValue == "Logout" {
             UserDefaults.standard.removeObject(forKey: "preferredRentalLocationCode")
             UserDefaults.standard.removeObject(forKey: "preferredReturnLocationCode")
            self.clearFields()
            shouldClearData = false

        }else {
            let userLoyaltyProfile = notification.object as? UserLoyaltyProfile
            
            
            if !(userLoyaltyProfile?.preferredRentalLocationCode?.isEmpty)! {
                print(userLoyaltyProfile?.preferredRentalLocationCode)
                print(userLoyaltyProfile?.preferredReturnLocationCode)
             
                if let preferredReturnLocationCode = userLoyaltyProfile?.preferredRentalLocationCode {
                    UserDefaults.standard.set(userLoyaltyProfile?.preferredRentalLocationCode, forKey: "preferredRentalLocationCode")
                }else{
                    UserDefaults.standard.set("", forKey: "preferredRentalLocationCode")
                }
            
                if let preferredReturnLocationCode = userLoyaltyProfile?.preferredReturnLocationCode {
                    UserDefaults.standard.set(userLoyaltyProfile?.preferredReturnLocationCode, forKey: "preferredReturnLocationCode")
                }else{
                    UserDefaults.standard.set("", forKey: "preferredReturnLocationCode")
                }
             
                
                if   !(userLoyaltyProfile?.preferredRentalLocationCode?.isEmpty)! {
                    let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true);

                    
                    var locationsids = (userLoyaltyProfile?.preferredRentalLocationCode!)
                    
                    if   !(userLoyaltyProfile?.preferredReturnLocationCode == "")  {
                        
                       
                        locationsids = locationsids! + "," + (userLoyaltyProfile?.preferredReturnLocationCode)!
                    }
                    
                    
                    NetworkManager.sharedInstance.getLocations(locaionId: locationsids!, onCompletion: {(jsonResponse, error) -> Void in
                        
                        
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
                                
                                if (jsonResponse?["d"].array?.count)! > 0 {
                                    
                                    self.headerView.returnTotextFieldConstraint.constant = 12
                                    self.headerView.showReturnToLocation.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 51.0/255.0, alpha: 1.0)
                                    self.headerView.showReturnToLocation.font = UIFont(name: "Montserrat-Medium", size: 13.0)
                                    self.headerView.returnToLocationLabel.isHidden = false
                                    
                                    self.headerView.pickUpTextFieldConstraint.constant = 12
                                    self.headerView.showPickUpLocation.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 51.0/255.0, alpha: 1.0)
                                    self.headerView.showPickUpLocation.font = UIFont(name: "Montserrat-Medium", size: 13.0)
                                    self.headerView.pickUpLocationLabel.isHidden = false
                                    
                                    
                                    
                                    if let items = jsonResponse?["d"].array {
                                        for anItem in items {
                                            print(anItem["LocationCode"].string)
                                            if (jsonResponse?["d"].array?.count == 2) {
                                    
                                                if userLoyaltyProfile?.preferredRentalLocationCode == anItem["LocationCode"].string {
                                                    
                                                    
                                                    
                                                    let jsonObject: [String:String]  =
                                                        [
                                                            "text": anItem["LocationName"].string!,
                                                            "id": anItem["LocationCode"].string!,
                                                            ]
                                                    
                                                    
                                                    
                                                    let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                                                    
                                                    // let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                                                    
                                                    //print(jsonString)
                                                    self.rentalLocation = Location(locationData:JSON(jsonData))
                                                    
                                                    self.headerView.showPickUpLocation.text = anItem["LocationName"].string!
                                                    
                                                    
                                                  //  self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                                    
                                                  //  self.returnLocation = Location(locationData:JSON(jsonData))
                                                    
                                                    
                                                }
                                                
                                                if userLoyaltyProfile?.preferredReturnLocationCode == anItem["LocationCode"].string {
                                                    
                                                    self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                                    self.returnLocation?.locationID = anItem["LocationCode"].string!
                                                    self.returnLocation?.locationText = anItem["LocationName"].string!
                                                    
                                                    
                                                    let jsonObject: [String:String]  =
                                                        [
                                                            "text": anItem["LocationName"].string!,
                                                            "id": anItem["LocationCode"].string!,
                                                            ]
                                                    
                                                    
                                                    
                                                    let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                                                    //print(jsonString)
                                                    //self.returnLocation = Location(locationData:JSON(jsonData))
                                                    
                                                    
                                                      self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                                    
                                                      self.returnLocation = Location(locationData:JSON(jsonData))
                                                }
                                            }
                                            
                                            if (jsonResponse?["d"].array?.count == 3) {
                                                
                                                if userLoyaltyProfile?.preferredRentalLocationCode == anItem["LocationCode"].string {
                                                    
                                                    
                                                    
                                                    let jsonObject: [String:String]  =
                                                        [
                                                            "text": anItem["LocationName"].string!,
                                                            "id": anItem["LocationCode"].string!,
                                                            ]
                                                    
                                                    
                                                    
                                                    let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                                                    
                                                    // let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                                                    
                                                    //print(jsonString)
                                                    self.rentalLocation = Location(locationData:JSON(jsonData))
                                                    
                                                    self.headerView.showPickUpLocation.text = anItem["LocationName"].string!
                                                    
                                                    
                                                    //  self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                                    
                                                    //  self.returnLocation = Location(locationData:JSON(jsonData))
                                                    
                                                    
                                                }
                                                
                                                if userLoyaltyProfile?.preferredReturnLocationCode == anItem["LocationCode"].string {
                                                    
                                                    self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                                    self.returnLocation?.locationID = anItem["LocationCode"].string!
                                                    self.returnLocation?.locationText = anItem["LocationName"].string!
                                                    
                                                    
                                                    let jsonObject: [String:String]  =
                                                        [
                                                            "text": anItem["LocationName"].string!,
                                                            "id": anItem["LocationCode"].string!,
                                                            ]
                                                    
                                                    
                                                    
                                                    let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                                                    //print(jsonString)
                                                    //self.returnLocation = Location(locationData:JSON(jsonData))
                                                    
                                                    
                                                    self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                                    
                                                    self.returnLocation = Location(locationData:JSON(jsonData))
                                                }
                                            }
                                            if (jsonResponse?["d"].array?.count == 1) {
                                                
                                                if userLoyaltyProfile?.preferredRentalLocationCode == anItem["LocationCode"].string {
                                                    
                                                    
                                                    
                                                    let jsonObject: [String:String]  =
                                                        [
                                                            "text": anItem["LocationName"].string!,
                                                            "id": anItem["LocationCode"].string!,
                                                            ]
                                                    
                                                    
                                                    
                                                    let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                                                    
                                                  
                                                    self.rentalLocation = Location(locationData:JSON(jsonData))
                                                    
                                                    self.headerView.showPickUpLocation.text = anItem["LocationName"].string!
                                                    
                                                    
                                                    self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                                    
                                                    self.returnLocation = Location(locationData:JSON(jsonData))
                                                    
                                                    
                                                }
                                                
                                                if userLoyaltyProfile?.preferredReturnLocationCode == anItem["LocationCode"].string {
                                                    
                                                    self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                                    self.returnLocation?.locationID = anItem["LocationCode"].string!
                                                    self.returnLocation?.locationText = anItem["LocationName"].string!
                                                    
                                                    
                                                    let jsonObject: [String:String]  =
                                                        [
                                                            "text": anItem["LocationName"].string!,
                                                            "id": anItem["LocationCode"].string!,
                                                            ]
                                                    
                                                    
                                                    
                                                    let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                                                    //print(jsonString)
                                                    self.returnLocation = Location(locationData:JSON(jsonData))
                                                    
                                                }
                                            }
                                            
                                            

                                        }
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                }
                            }
                        }
                    })
                }
                
                

                
            }

        }
       
        
    }
    
    
    func preferredlocationAPICall()  {
        
      
        if !(preferedrentalLocationValue?.isEmpty)!  {
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true);
            
            NetworkManager.sharedInstance.getLocations(locaionId: preferedrentalLocationValue!, onCompletion: {(jsonResponse, error) -> Void in
                
                
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
                        
                        if (jsonResponse?["d"].array?.count)! > 0 {
                            
                            self.headerView.returnTotextFieldConstraint.constant = 12
                            self.headerView.showReturnToLocation.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 51.0/255.0, alpha: 1.0)
                            self.headerView.showReturnToLocation.font = UIFont(name: "Montserrat-Medium", size: 13.0)
                            self.headerView.returnToLocationLabel.isHidden = false
                            
                            self.headerView.pickUpTextFieldConstraint.constant = 12
                            self.headerView.showPickUpLocation.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 51.0/255.0, alpha: 1.0)
                            self.headerView.showPickUpLocation.font = UIFont(name: "Montserrat-Medium", size: 13.0)
                            self.headerView.pickUpLocationLabel.isHidden = false
                            
                            
                            var fromlocationId = ""
                            var droplocationId = ""
                            var carselecteditem = ""
                            
                            if let items = jsonResponse?["d"].array {
                                for anItem in items {
                                    print(anItem["LocationCode"].string)
                                    
                             
                                    if (jsonResponse?["d"].array?.count == 2) {
                                        
                                        // component separatore String:
                                        var myString: String = self.preferedrentalLocationValue!
                                        var myStringArr = myString.components(separatedBy: ",")
                                        
                                           fromlocationId =  myStringArr[0]
                                        
                                            droplocationId =  myStringArr[1]
                                        
                                        
                                        
                                        if fromlocationId == anItem["LocationCode"].string {
                                            
                                            let jsonObject: [String:String]  =
                                                [
                                                    "text": anItem["LocationName"].string!,
                                                    "id": anItem["LocationCode"].string!,
                                                    ]
                                            
                                            let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                                            
                                            self.rentalLocation = Location(locationData:JSON(jsonData))
                                            
                                            self.headerView.showPickUpLocation.text = anItem["LocationName"].string!
                                            
                                            
                                           
                                            
                                        }
                                        
                                        if droplocationId == anItem["LocationCode"].string {
                                            
                                            self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                            self.returnLocation?.locationID = anItem["LocationCode"].string!
                                            self.returnLocation?.locationText = anItem["LocationName"].string!
                                            
                                            let jsonObject: [String:String]  =
                                                [
                                                    "text": anItem["LocationName"].string!,
                                                    "id": anItem["LocationCode"].string!,
                                                    ]
                                            
                                            
                                            let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                                            //print(jsonString)
                                           // self.returnLocation = Location(locationData:JSON(jsonData))
                                            
                                            self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                            
                                            self.returnLocation = Location(locationData:JSON(jsonData))
                                            
                                        }

                                    }
                                    
                                     if (jsonResponse?["d"].array?.count == 3) {
                                        
                                        
                                        // component separatore String:
                                        var myString: String = self.preferedrentalLocationValue!
                                        var myStringArr = myString.components(separatedBy: ",")
                                        
                                        fromlocationId =  myStringArr[0]
                                        
                                       var myStringArr1 =  myStringArr[1].components(separatedBy: ",")
                                        droplocationId =  myStringArr1[0]
                                        
                                        carselecteditem =  myStringArr1[1]
                                        
                                        
                                        
                                        if fromlocationId == anItem["LocationCode"].string {
                                            
                                            let jsonObject: [String:String]  =
                                                [
                                                    "text": anItem["LocationName"].string!,
                                                    "id": anItem["LocationCode"].string!,
                                                    ]
                                            
                                            let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                                            
                                            self.rentalLocation = Location(locationData:JSON(jsonData))
                                            
                                            self.headerView.showPickUpLocation.text = anItem["LocationName"].string!
                                            
                                            
                                           
                                            
                                        }
                                        
                                        if droplocationId == anItem["LocationCode"].string {
                                            
                                            self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                            self.returnLocation?.locationID = anItem["LocationCode"].string!
                                            self.returnLocation?.locationText = anItem["LocationName"].string!
                                            
                                            let jsonObject: [String:String]  =
                                                [
                                                    "text": anItem["LocationName"].string!,
                                                    "id": anItem["LocationCode"].string!,
                                                    ]
                                            
                                            
                                            let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                                            //print(jsonString)
                                           // self.returnLocation = Location(locationData:JSON(jsonData))
                                            
                                            self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                            
                                            self.returnLocation = Location(locationData:JSON(jsonData))
                                            
                                        }


                                     }else{
                                        
                                        if self.preferedrentalLocationValue == anItem["LocationCode"].string {
                                            
                                            let jsonObject: [String:String]  =
                                                [
                                                    "text": anItem["LocationName"].string!,
                                                    "id": anItem["LocationCode"].string!,
                                                    ]
                                     
                                            let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                                          
                                            self.rentalLocation = Location(locationData:JSON(jsonData))
                                            
                                            self.headerView.showPickUpLocation.text = anItem["LocationName"].string!
                                            
                                            
                                           
                                        
                                        }
                                        
                                        if self.preferedrentalLocationValue == anItem["LocationCode"].string {
                                            
                                            self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                            self.returnLocation?.locationID = anItem["LocationCode"].string!
                                            self.returnLocation?.locationText = anItem["LocationName"].string!
                                            
                                            let jsonObject: [String:String]  =
                                                [
                                                    "text": anItem["LocationName"].string!,
                                                    "id": anItem["LocationCode"].string!,
                                                    ]
                                            
                                           
                                            let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
                                            //print(jsonString)
                                            //self.returnLocation = Location(locationData:JSON(jsonData))
                                            
                                            self.headerView.showReturnToLocation.text = anItem["LocationName"].string!
                                            
                                            self.returnLocation = Location(locationData:JSON(jsonData))
                                            
                                        }
                                    }
                                  

                                    
                                    

                                }
                                
                                
                            }
                            
                            
                            
                            
                            
                            
                            
                        }
                    }
                }
            })
        }
    }

    
    @IBAction func tapButtonAction(_ sender: Any) {
        //StoryBoard :
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        sidementViewObject = storyboard.instantiateViewController(withIdentifier: "SildeMenuViewController") as! SlideMenuViewController
       
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.layer.add(transition, forKey: nil)

        addChildViewController(sidementViewObject)
        view.addSubview(sidementViewObject.view)
        sidementViewObject.didMove(toParentViewController: self)
        
        
        /*
         //Adding Child View:
        addChildViewController(sidementViewObject)
        
        //sidementViewObject.view.frame =  CGRect(x:0, y: 0, width:self.view.frame.width - 100, height:self.view.frame.height)
        
         view.addSubview(sidementViewObject.view)
         sidementViewObject.didMove(toParentViewController: self)
 
         */
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if shouldClearData {
            shouldClearData = false
            clearFields()
        }
        
        
      
    }
    
    func clearFields() {
        rentalLocation = nil
        returnLocation = nil
        rentalDate = nil
        rentalTime = nil
        returnDate = nil
        returnTime = nil
        
        clearTextField(textField: self.headerView.showPickUpDate); self.headerView.showPickUpDate.text = "Pick up date"
        clearTextField(textField: self.headerView.showPickUpTime); self.headerView.showPickUpTime.text = "Time"
        clearTextField(textField: self.headerView.showReturnDate); self.headerView.showReturnDate.text = "Return date"
        clearTextField(textField: self.headerView.showReturnTime); self.headerView.showReturnTime.text = "Time"
        clearTextField(textField: self.headerView.showPickUpLocation); self.headerView.showPickUpLocation.text = "Pick up from"
        clearTextField(textField: self.headerView.showReturnToLocation); self.headerView.showReturnToLocation.text = "Return to"
        
        self.headerView.rentalDateTextFieldConstraint.constant = 15
        self.headerView.rentalTimeTextFieldConstraint.constant = 15
        self.headerView.returnDateTextFieldConstraint.constant = 15
        self.headerView.returnTimeTextFieldConstraint.constant = 15
        self.headerView.returnTotextFieldConstraint.constant = 15
        self.headerView.pickUpTextFieldConstraint.constant = 15
        self.headerView.dropToTextFieldConstraint.constant = 15
        
        self.headerView.pickUpDateLabel.isHidden = true
        self.headerView.pickUpTimeLabel.isHidden = true
        self.headerView.returnDateLabel.isHidden = true
        self.headerView.returnTimeLabel.isHidden = true
        self.headerView.returnToLocationLabel.isHidden = true
        self.headerView.pickUpLocationLabel.isHidden = true
        
        promocodeAdded = 1
        
        let rowInfo1 = ["rowIdentifier":promoCodeCellId, "rowTitle":"Promo Code", "rowHeight":"50", "state":"add", "value":""]
        self.promoCodesDataSource = [rowInfo1]
        self.findCarTableView.reloadData()
    }
    
    func clearTextField(textField: UITextField) {
        let font = UIFont(name: "Montserrat-Medium", size: 10)
        let color = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1.0)
        textField.font = font
        textField.textColor = color
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        
        if rentalLocation == nil {
            AlertManager.sharedInstance.show(title: "Error", message: "Please select rental location.", fromVC: self)
        } else if  returnLocation == nil {
            AlertManager.sharedInstance.show(title: "Error", message: "Please select return location.", fromVC: self)
        } else if rentalDate == nil {
            AlertManager.sharedInstance.show(title: "Error", message: "Please select rental date.", fromVC: self)
        } else if rentalTime == nil {
            AlertManager.sharedInstance.show(title: "Error", message: "Please select rental time.", fromVC: self)
        } else if returnDate == nil {
            AlertManager.sharedInstance.show(title: "Error", message: "Please select return date.", fromVC: self)
        } else if returnTime == nil {
            AlertManager.sharedInstance.show(title: "Error", message: "Please select return time.", fromVC: self)
        } else if isRentalDateGreaterThanReturnDate() {
            AlertManager.sharedInstance.show(title: "Error", message: "The return date can not be earlier than the rental date.", fromVC: self)
        } else if isRentalAndReturnDateSame() == false {
            AlertManager.sharedInstance.show(title: "Error", message: "The rental date can not be the same as the return date.", fromVC: self)
        } else {
            var promoCodes = [String]()
            for var rowInfo in promoCodesDataSource.reversed() {
                if rowInfo["rowIdentifier"] == promoCodeCellId {
                    if rowInfo["value"]?.isEmpty == false {
                        var promocode = rowInfo["value"]!
                        promocode = promocode.trimmingCharacters(in: .whitespacesAndNewlines)
                        rowInfo["value"] = promocode
                        promoCodes.append(promocode)
                    }
                } else {
                    break
                }
            }
            
            let rentalDateTimeAsString = addReservationDateFormat(date: self.rentalDate!, time: self.rentalTime!)
            let returnDateTimeAsString = addReservationDateFormat(date: self.returnDate!, time: self.returnTime!)
            
            let localReturnLocation = returnLocation
            
            let pickupDate = apiDateFormat(date: self.rentalDate!)
            let pickupTime = apiTimeFormat(time: self.rentalTime!)
            let dropoffDate = apiDateFormat(date: self.returnDate!)
            let dropoffTime = apiTimeFormat(time: self.returnTime!)
            
            let fullPickUpDate = addReservationFullDate(date: self.rentalDate!)
            let fullDropOffDate = addReservationFullDate(date: self.returnDate!)
            
            let pickUpDateTimeAsString = apiDateTimeFormat(date: self.rentalDate!, time: self.rentalTime!)
            let dropOffDateTimeAsSting = apiDateTimeFormat(date: self.returnDate!, time: self.returnTime!)
            
            let progressHUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
            
            let serivceSuccessHandlerInVC : (_ aezRates:AEZRates) -> Void = {
                [weak self] (aezRates:AEZRates)  in
                progressHUD.removeFromSuperview()
                if aezRates.rentalLocation?.addLine1 == nil || aezRates.returnLocation?.addLine1 == nil {
                    AlertManager.sharedInstance.show(title: "Error", message: "Something went wrong. Please try again later.", fromVC: self!)
                } else {
                    self?.aezRates = aezRates
                    Reservation.sharedInstance?.promoCodes = aezRates.promoCodes
                    Reservation.sharedInstance?.rentalLocationId = self?.rentalLocation!.locationID
                    Reservation.sharedInstance?.rentalLocation = aezRates.rentalLocation
                    Reservation.sharedInstance?.returnLocationId = localReturnLocation?.locationID
                    Reservation.sharedInstance?.returnLocation = aezRates.returnLocation
                    Reservation.sharedInstance?.pickUpDateTime = rentalDateTimeAsString
                    Reservation.sharedInstance?.dropOffDateTime = returnDateTimeAsString
                    Reservation.sharedInstance?.pickUpdate = pickupDate
                    Reservation.sharedInstance?.pickUptime = pickupTime
                    Reservation.sharedInstance?.dropOffDate = dropoffDate
                    Reservation.sharedInstance?.dropOffTime = dropoffTime
                    Reservation.sharedInstance?.pickupDateFormatted = fullPickUpDate
                    Reservation.sharedInstance?.dropoffDateFormatted = fullDropOffDate
                    Reservation.sharedInstance?.rentalDateTime = pickUpDateTimeAsString
                    Reservation.sharedInstance?.returnDateTime = dropOffDateTimeAsSting
                    
                    Reservation.sharedInstance?.pickUpdateAsDate = (self?.rentalDate!)!
                    
                    self?.performSegue(withIdentifier: "ChooseCarSegue", sender: self)
                }
            }
            
            let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
                (errorValue:Any)  in
                print(errorValue)
                progressHUD.removeFromSuperview()
                if let errorMessage = errorValue as? String {
                    AlertManager.sharedInstance.show(title: "Failed", message: errorMessage, fromVC: self)
                } else if let error = errorValue as? Error {
                    AlertManager.sharedInstance.show(title: "Error", message: error.localizedDescription, fromVC: self)
                }
            }
            
            DataManager.sharedInstance.getRatesCall(rentalLocationID: rentalLocation!.locationID, returnLocationID: localReturnLocation!.locationID, pickupDate: pickupDate, pickupTime: pickupTime, dropOffDate: dropoffDate, dropOffTime: dropoffTime, promoCodes: promoCodes, serviceSuccessHandler: serivceSuccessHandlerInVC, serviceFailureHandler: serviceFailureHandlerInVC)
        }
    }
    
    //MARK: UITableView Delegate / Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.promoCodesDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var rowInfo = promoCodesDataSource[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: promoCodeCellId, for: indexPath) as! PromoCodeCell
        
        cell.rowTextField.text = rowInfo["value"]
        cell.rowAddRemoveButton.tag = indexPath.row
        cell.rowAddRemoveButton.addTarget(self, action: #selector(addDeletePromoCodeButtonTapped), for: .touchUpInside)
        cell.rowAddRemoveButton.setImage(UIImage(named: "Add_Icon"), for: .normal)
        if rowInfo["state"] == "remove" {
            cell.rowAddRemoveButton.setImage(UIImage(named: "Close_icon"), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowHeight = promoCodesDataSource[indexPath.row]["rowHeight"]
        guard let height = NumberFormatter().number(from: rowHeight!) else { return 50 }
        return CGFloat(height)
    }
    
    func addDeletePromoCodeButtonTapped(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to:self.findCarTableView)
        let indexPath = self.findCarTableView.indexPathForRow(at:buttonPosition)!
        
        var clickedRowInfo = promoCodesDataSource[indexPath.row]
        if clickedRowInfo["state"] == "add" {
            promocodeAdded = promocodeAdded + 1
            var addingRowInfo = ["rowIdentifier":promoCodeCellId, "rowTitle":"Promo Code", "rowHeight":"50", "state":"add", "value":""]
            if promocodeAdded == 4{
                addingRowInfo["state"] = "remove"
            }
            self.promoCodesDataSource.insert(addingRowInfo, at: indexPath.row)
            let localIndexPath = IndexPath(row: indexPath.row, section: 0)
            self.findCarTableView.beginUpdates()
            self.findCarTableView.insertRows(at: [localIndexPath], with: .automatic)
            self.findCarTableView.endUpdates()
            
            let scrollToIndexPath = IndexPath(row: indexPath.row+1, section: 0)
            self.findCarTableView.scrollToRow(at: scrollToIndexPath, at: .bottom, animated: true)
            
            // Update current row
            sender.setImage(UIImage(named: "Close_icon"), for: .normal)
            clickedRowInfo["state"] = "remove"
            self.promoCodesDataSource[indexPath.row+1] = clickedRowInfo
            if let activeField = self.activeField {
                if activeField.tag == indexPath.row  {
                    self.activeField!.tag = indexPath.row + 1
                }
            }
        } else {
            if let activeField = self.activeField {
                if activeField.tag == indexPath.row {
                    self.activeField!.tag = -651561
                    self.activeField = nil
                }
            }
            promocodeAdded = promocodeAdded - 1
            self.promoCodesDataSource.remove(at: indexPath.row)
            let indexPath = IndexPath(row: indexPath.row, section: 0)
            self.findCarTableView.beginUpdates()
            self.findCarTableView.deleteRows(at: [indexPath], with: .automatic)
            self.findCarTableView.endUpdates()
            
            // Make sure we have 1 plus button
            if promocodeAdded == 3 ||  promocodeAdded == 2 || promocodeAdded == 1 {
                var firstCodeRowInfo = self.promoCodesDataSource.first!
                firstCodeRowInfo["state"] = "add"
                self.promoCodesDataSource[0] = firstCodeRowInfo
                let lastIndexPath = IndexPath(row: 0, section: 0)
                self.findCarTableView.beginUpdates()
                self.findCarTableView.reloadRows(at: [lastIndexPath], with: .automatic)
                self.findCarTableView.endUpdates()
            }
        }
    }
    
    // MARK: - Keyboard Management
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            let tableViewBottomSpace = UIScreen.main.bounds.size.height - (self.findCarTableView.frame.origin.y + self.findCarTableView.frame.size.height)
            self.findCarTableView.contentInset = UIEdgeInsetsMake(tableViewTopInset, 0, keyboardHeight-tableViewBottomSpace, 0)
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            // For some reason adding inset in keyboardWillShow is animated by itself but removing is not, that's why we have to use animateWithDuration here
            self.findCarTableView.contentInset = UIEdgeInsetsMake(self.tableViewTopInset, 0, 0, 0)
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool  {
        let textFieldPosition = textField.convert(CGPoint.zero, to: self.findCarTableView)
        if let indexPath = self.findCarTableView.indexPathForRow(at: textFieldPosition) {
            var clickedRowInfo = self.promoCodesDataSource[indexPath.row]
            clickedRowInfo["value"] = textField.text
            self.promoCodesDataSource[indexPath.row] = clickedRowInfo
        }
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.activeField = textField
        if textField.tag == tagRentalLocationTextField || textField.tag == tagReturnLocationTextField {
            self.performSegue(withIdentifier: "LocationResultsSegue", sender: self)
            return false
        } else if textField.tag == tagRentalDateTextField || textField.tag == tagRentalTimeTextField || textField.tag == tagReturnDateTextField || textField.tag == tagReturnTimeTextField {
            self.performSegue(withIdentifier: "DatePickerSegue", sender: self)
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let textFieldPosition = textField.convert(CGPoint.zero, to: self.findCarTableView)
        if let indexPath = self.findCarTableView.indexPathForRow(at: textFieldPosition) {
            var clickedRowInfo = self.promoCodesDataSource[indexPath.row]
            clickedRowInfo["value"] = textField.text
            self.promoCodesDataSource[indexPath.row] = clickedRowInfo
        }
    }
    
    func roundOffMinutes() -> Int {
        var minutes = Calendar.current.component(.minute, from: Date())
        if minutes > 30 {
            minutes = 0
        } else {
            minutes = 30
        }
        return minutes
    }
    
    func todaysDateRoundOff() -> Date {
        let calender = Calendar.current
        let now = Date()
        var components = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        
        var hour = components.hour!
        let minute = roundOffMinutes()
        if minute == 0 {
            hour = hour + 1
        }
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        let date = calender.date(from: components)!
        return date
    }
    
    func assignSelectedAndMinimumDate(datePickerVC: DatePickerViewController) {
        let textField = self.activeField!
        
        var selectedDate = todaysDateRoundOff()
        var minimumDate = todaysDateRoundOff()
        
        if textField.tag == tagRentalDateTextField || textField.tag == tagRentalTimeTextField {
            if let rentalDate = self.rentalDate, let rentalTime = self.rentalTime {
                selectedDate = completeDateTime(date: rentalDate, time: rentalTime)
            }
        } else if textField.tag == tagReturnDateTextField || textField.tag == tagReturnTimeTextField {
            var minimumReturnDate = todaysDateRoundOff().addingTimeInterval(1800)
            var defaultSelectedDate = todaysDateRoundOff().addingTimeInterval(48*60*60)
            if let rentalDate = self.rentalDate, let rentalTime = self.rentalTime {
                defaultSelectedDate = completeDateTime(date: rentalDate, time: rentalTime).addingTimeInterval(48*60*60)
                minimumReturnDate = completeDateTime(date: rentalDate, time: rentalTime).addingTimeInterval(1800)
            }
            minimumDate = minimumReturnDate
            selectedDate = defaultSelectedDate
        }
        
        datePickerVC.selectedDate = selectedDate
        datePickerVC.minimumDate = minimumDate
    }
    
    func isRentalAndReturnDateSame() -> Bool {
        let completeRentalDate = completeDateTime(date: rentalDate!, time: rentalTime!)
        let completeReturnDate = completeDateTime(date: returnDate!, time: returnTime!)
        
        let hoursDifference = Calendar.current.dateComponents([.minute], from: completeRentalDate, to: completeReturnDate).minute ?? 0
        if hoursDifference == 0 {
            return false
        }
        return true
    }
    
    func updateDateField(selectedDate: Date) {
        let dateFormatter1 = DateFormatter()
        let timeFormatter = DateFormatter()
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "MM/dd/yyyy,hh:mm a"
        dateFormatter1.dateFormat = "MM/dd/yyyy"
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.locale = Locale(identifier: "en_US")
        
        if activeField?.tag == tagRentalDateTextField || activeField?.tag == tagRentalTimeTextField {
            self.rentalDate = selectedDate
            self.headerView.rentalDateTextFieldConstraint.constant = 12
            
            self.headerView.showPickUpDate.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            self.headerView.showPickUpDate.font = UIFont(name: "Montserrat-Medium", size: 13.0)
            self.headerView.pickUpDateLabel.isHidden = false
            
            self.rentalTime = selectedDate
            self.headerView.rentalTimeTextFieldConstraint.constant = 12
            self.headerView.showPickUpTime.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            self.headerView.showPickUpTime.font = UIFont(name: "Montserrat-Medium", size: 13.0)
            self.headerView.pickUpTimeLabel.isHidden = false
            
            self.headerView.showPickUpTime.text = timeFormatter.string(from: selectedDate)
            self.headerView.showPickUpDate.text = dateFormatter1.string(from: selectedDate)
        } else {
            self.returnDate = selectedDate
            self.headerView.returnDateTextFieldConstraint.constant = 12
            self.headerView.showReturnDate.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            self.headerView.showReturnDate.font = UIFont(name: "Montserrat-Medium", size: 13.0)
            self.headerView.returnDateLabel.isHidden = false
            
            self.returnTime = selectedDate
            self.headerView.returnTimeTextFieldConstraint.constant = 12
            self.headerView.showReturnTime.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            self.headerView.showReturnTime.font = UIFont(name: "Montserrat-Medium", size: 13.0)
            self.headerView.returnTimeLabel.isHidden = false
            
            self.headerView.showReturnTime.text = timeFormatter.string(from: selectedDate)
            self.headerView.showReturnDate.text = dateFormatter1.string(from: selectedDate)
        }
    }
    
    func isRentalDateGreaterThanReturnDate() -> Bool {
        let calender = Calendar.current
        let result = calender.compare(rentalDate!, to: returnDate!, toGranularity: .day)
        if result == .orderedDescending {
            return true
        }
        return false
    }
    
    func addReservationFullDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE - MMMM dd, yyyy | h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        return dateFormatter.string(from:date)
    }
    
    func completeDateTime(date: Date, time: Date) -> Date {
        let completeDateTimeInString = addReservationDateFormat(date: date, time: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy, hh:mm a"
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.date(from: completeDateTimeInString)!
    }
    
    func addReservationDateFormat(date: Date, time: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.locale = Locale(identifier: "en_US")
        
        return dateFormatter.string(from:date) + ", " + timeFormatter.string(from:time)
    }
    
    func apiDateTimeFormat(date: Date, time: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyyyy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.locale = Locale(identifier: "en_US")
        
        return dateFormatter.string(from:date) + " " + timeFormatter.string(from:time)
    }
    
    func apiDateFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyyyy"
        return dateFormatter.string(from:date)
    }
    
    func apiTimeFormat(time: Date) -> String {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "hh:mma"
        dateFormatter1.locale = Locale(identifier: "en_US")
        return dateFormatter1.string(from:time)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LocationResultsSegue" {
            let locationResultsViewController = segue.destination as! LocationSearchResultsViewController
            locationResultsViewController.delegate  = self
        } else if segue.identifier == "ChooseCarSegue" {
            let chooseCarVC = segue.destination as! ChooseACarViewController
            chooseCarVC.aezRates = self.aezRates!
        } else if segue.identifier == "DatePickerSegue" {
            let datePickerVC = segue.destination as! DatePickerViewController
            datePickerVC.activeField = self.activeField
            assignSelectedAndMinimumDate(datePickerVC: datePickerVC)
            datePickerVC.delegate = self
        }
     }
    
    //  MARK: -   LocationSearchResultsViewControllerDelegate
    func locationSearchResultsViewControllerDidSelectLocation(vc:LocationSearchResultsViewController, location: Location) {
        
        self.headerView.returnTotextFieldConstraint.constant = 12
        self.headerView.showReturnToLocation.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        self.headerView.showReturnToLocation.font = UIFont(name: "Montserrat-Medium", size: 13.0)
        self.headerView.returnToLocationLabel.isHidden = false
        
        self.headerView.pickUpTextFieldConstraint.constant = 12
        self.headerView.showPickUpLocation.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        self.headerView.showPickUpLocation.font = UIFont(name: "Montserrat-Medium", size: 13.0)
        self.headerView.pickUpLocationLabel.isHidden = false
        
//        let locationArr = location.locationText.components(separatedBy: "(")
        self.activeField?.text = location.locationText
        if self.activeField?.tag == tagRentalLocationTextField {
            rentalLocation = location
            if self.headerView.showReturnToLocation.text! == "Return to" {
                self.headerView.showReturnToLocation.text = location.locationText
                returnLocation = location
            }
        } else if self.activeField?.tag == tagReturnLocationTextField {
            returnLocation = location
            if self.headerView.showPickUpLocation.text! == "Pick up from" {
                self.headerView.showPickUpLocation.text = location.locationText
                rentalLocation = location
            }
        }
        
        vc.backButtonTapped(self)
    }
    
    //MARK: DatePickerViewControllerDelegate
    func datePickerViewControllerDidSelectDate(selectedDate: Date) {
        updateDateField(selectedDate: selectedDate)
    }
    
    // VIMP: Do not delete this, it used for custom unwind segue
    @IBAction func unwindFromViewController(segue:UIStoryboardSegue) {
        
    }
}
extension FindACarViewController: loginViewcontrollerDelegate {
    func loginDataReceive(userLoyaltyProfileData: UserLoyaltyProfile?, isGuestUser: Bool) {
        print("Delegate called")
    }
    
   
}

//
//  LoginViewController.swift
//  Advantage
//
//  Created by macbook on 6/21/18.
//  Copyright © 2018 Anjali Panjawani. All rights reserved.
//

import UIKit
import MBProgressHUD


protocol loginViewcontrollerDelegate {
func loginDataReceive(userLoyaltyProfileData:UserLoyaltyProfile? , isGuestUser:Bool)
}
class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    var userLoyaltyProfile: UserLoyaltyProfile?
    var isGuestUser = false
    var custumdelegate :loginViewcontrollerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func  textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //MARK: IB Actions
    @IBAction func forgotpasswordTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "ForgotPasswordViewController", sender: self)
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func loginButtonTapped(_ sender: Any) {
        
       
         if userNameTextField.text?.characters.count == 0 {
         AlertManager.sharedInstance.show(title: "Error", message: "Username can not be empty", fromVC: self)
         } else if Utilities.sharedInstance.validateEmail(enteredEmail: userNameTextField.text!) == false {
         AlertManager.sharedInstance.show(title: "Error", message: "Please enter valid username", fromVC: self)
         } else if passwordTextField.text?.characters.count == 0 {
         AlertManager.sharedInstance.show(title: "Error", message: "Password can not be empty", fromVC: self)
         } else {
         self.view.endEditing(true)
         
         let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
         let serivceSuccessHandlerInVC : (Login)->Void = {
         [weak self] (loginData:Login)  in
        progressHUD.removeFromSuperview()
         
         //FIXME: Temporary save in NSUserDefaults
         UserDefaults.standard.set(loginData.access_token, forKey: "access_token")
         UserDefaults.standard.set(loginData.memberNumber, forKey: "memberNumber")
            UserDefaults.standard.set(self?.userNameTextField.text!, forKey: "loggedInUserEmailAddress")
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
         
         DataManager.sharedInstance.loginServiceCall(userNameTextField.text!, passwordTextField.text!, serviceSuccessHandler: serivceSuccessHandlerInVC, serviceFailureHnadler: serviceFailureHandlerInVC)
         }
         
 
    }
    
    func serverFetchLoyaltyProfile() {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        let serivceSuccessHandlerInVC : (UserLoyaltyProfile)->Void = {
            [weak self] (loyaltyProfile:UserLoyaltyProfile)  in
            progressHUD.removeFromSuperview()
            

            let firstName = loyaltyProfile.firstName
            
            UserDefaults.standard.set(firstName, forKey: "FirstName")

            self?.dismiss(animated: true, completion:{
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginSucess"), object: firstName);
                
                //FindACarPreferrredLocationData
                
                 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FindACarPreferrredLocationData"), object: loyaltyProfile);
            })
           
        }
        
        let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
            (errorValue:Any)  in
            print(errorValue)
            
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginSucess"), object: "");
       
            progressHUD.removeFromSuperview()
        }
        
        let memberNumber = UserDefaults.standard.double(forKey: "memberNumber")
        DataManager.sharedInstance.getLoyaltyProfileCall(memberNumber: memberNumber, serviceSuccessHandler: serivceSuccessHandlerInVC, serviceFailureHnadler: serviceFailureHandlerInVC)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

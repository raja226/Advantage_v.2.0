//
//  ForgotPasswordViewController.swift
//  Advantage
//
//  Created by macbook on 6/22/18.
//  Copyright © 2018 Anjali Panjawani. All rights reserved.
//

import UIKit
import MBProgressHUD
import Alamofire
class ForgotPasswordViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    //MARK: IB Actions
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        if userNameTextField.text?.characters.count == 0 {
            AlertManager.sharedInstance.show(title: "Error", message: "Email Id can not be empty", fromVC: self)
        } else if Utilities.sharedInstance.validateEmail(enteredEmail: userNameTextField.text!) == false {
            AlertManager.sharedInstance.show(title: "Error", message: "Please enter valid Email Id", fromVC: self)
        } else {
            self.view.endEditing(true)
            
            if NetworkReachabilityManager()!.isReachable {
                //Service Call
                let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true); NetworkManager.sharedInstance.getForgotPassword(userNameTextField.text!, onCompletion: { (jsonResponse, error) -> Void in
                    
                    progressHUD.removeFromSuperview()
                    if error != nil {
                        
                        if error?._code == NSURLErrorTimedOut {
                            AlertManager.sharedInstance.show(title: "Error", message: (error?.localizedDescription)!, fromVC: self)
                        }else{
                            let error: Error = (error?.localizedDescription)! as! Error
                            print(error.localizedDescription)
                            AlertManager.sharedInstance.show(title: "Error", message: error.localizedDescription, fromVC: self)
                        }
                        
                    }else{
                        if jsonResponse?["status"].string == "error"  {
                            //Failure:
                            if let  messageValue = jsonResponse?["error"]["errorMessage"].string {
                                
                                
                                let alert = UIAlertController(title: "sucess", message: messageValue, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                    switch action.style{
                                    case .default:
                                        print("default")
                                        self.dismiss(animated: true, completion: nil)
                                        
                                    case .cancel:
                                        print("cancel")
                                        
                                    case .destructive:
                                        print("destructive")
                                        
                                        
                                    }}))
                                self.present(alert, animated: true, completion: nil)

                                
                                //AlertManager.sharedInstance.show(title: "error", message: messageValue, fromVC: self)
                            }
                        }else{
                            //sucess:
                            if let  messageValue = jsonResponse?["message"].string {
                                
                                let alert = UIAlertController(title: "sucess", message: messageValue, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                    switch action.style{
                                    case .default:
                                        print("default")
                                        self.dismiss(animated: true, completion: nil)
                                        
                                    case .cancel:
                                        print("cancel")
                                        
                                    case .destructive:
                                        print("destructive")
                                        
                                        
                                    }}))
                                self.present(alert, animated: true, completion: nil)

                                //AlertManager.sharedInstance.show(title: "sucess", message: messageValue, fromVC: self)
                            }
                        }
                        
                    }
                })
            } else {
                AlertManager.sharedInstance.show(title: "Error", message: "The Internet connection appears to be offline.", fromVC: self)
            }
            
        }
    }
    
    func  textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if !(userNameTextField.text?.isEmpty)! {
            submitButtonTapped(self)
        }
        self.view.endEditing(true)

        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

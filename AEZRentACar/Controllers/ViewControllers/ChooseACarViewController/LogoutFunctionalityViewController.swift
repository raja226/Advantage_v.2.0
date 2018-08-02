//
//  LogoutFunctionalityViewController.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 7/31/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit
import MBProgressHUD

class LogoutFunctionalityViewController: UIViewController {
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        
        var message = "The reservation data will be lost once you logout.\nAre you sure you want to continue?"
        if self.isMember(of: ReservationConfirmationViewController.self) {
            message = "Are you sure you want to continue?"
        }
        
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (UIAlertAction) in
        }
        alertController.addAction(cancelAction)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            self.serverLogoutUser()
        }
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func serverLogoutUser() {
        var progressHUD = MBProgressHUD()
        if let navigation = self.navigationController {
            print(self.navigationController?.view)
            
             progressHUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)

        }else{
            //side menu logout:
             progressHUD = MBProgressHUD.showAdded(to: SlideMenuViewController().view, animated: true)
        }
        
        
        let serivceSuccessHandlerInVC : (_ responseValue:Any) -> Void = {
            [weak self] (responseValue: Any)  in
            progressHUD.removeFromSuperview()
            DispatchQueue.main.async {
                self?.clearUserPrefereces()
            }
        }
        
        let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
            (errorValue:Any)  in
            progressHUD.removeFromSuperview()
            self.clearUserPrefereces()
        }
        
        if let emailAddress = UserDefaults.standard.string(forKey: "loggedInUserEmailAddress"), let accessToken = UserDefaults.standard.string(forKey: "access_token") {
            DataManager.sharedInstance.postLogoutCall(accessToken: accessToken, email: emailAddress, serviceSuccessHandler: serivceSuccessHandlerInVC, serviceFailureHnadler: serviceFailureHandlerInVC)
        } else {
            clearUserPrefereces()
        }
    }
    
    func clearUserPrefereces() {
        UserDefaults.standard.set(nil, forKey: "access_token")
        UserDefaults.standard.set(nil, forKey: "memberNumber")
        UserDefaults.standard.set(nil, forKey: "loggedInUserEmailAddress")
        UserDefaults.standard.set(nil, forKey: "loggedInUserLoyaltyStatus")
        UserDefaults.standard.synchronize()
        
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
}

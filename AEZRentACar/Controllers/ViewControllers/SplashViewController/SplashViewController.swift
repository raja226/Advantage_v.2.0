//
//  SplashViewController.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 7/6/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    @IBOutlet weak var imageviewTopConstaints: NSLayoutConstraint!
    @IBOutlet weak var imageviewBottomConstaints: NSLayoutConstraint!

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = UIImage(named: "Default-736h")

        
/*
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
            case 1334:
                print("iPhone 6/6S/7/8")
                
               

            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
            case 2436:
                print("iPhone X")
                let screenSize: CGRect = UIScreen.main.bounds
                if #available(iOS 11.0, *) {
                    imageviewTopConstaints.priority = UILayoutPriorityRequired
                    imageviewTopConstaints.constant = -44
                    
                    imageviewBottomConstaints.priority = UILayoutPriorityRequired
                    
                    imageviewBottomConstaints.constant = 34
                    
                   // imageView.frame = CGRect(x: 0, y: -90, width: 50, height: screenSize.height + 90)
                } else {
                    // Fallback on earlier versions
                    
                   

                    
                }
            default:
                print("unknown")
            }
        }

        
       
        // Do any additional setup after loading the view.
        if UIScreen.main.bounds.height == 568 {
            self.imageView.image = UIImage(named: "Default-568h")
        } else if UIScreen.main.bounds.height == 667 {
            self.imageView.image = UIImage(named: "Default-667h")
        } else {
            self.imageView.image = UIImage(named: "Default-736h")
        }
        */
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(initiateUser), userInfo: nil, repeats: false)
    }
    
    func initiateUser() {
        if let accessToken = UserDefaults.standard.string(forKey: "access_token") {
            let serivceSuccessHandlerInVC : (User)->Void = {
                [weak self] (user:User)  in
                self!.showLandingPage()
            }
            
            let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
                (errorValue:Any)  in
                print(errorValue)
                UserDefaults.standard.set(nil, forKey: "access_token")
                UserDefaults.standard.set(nil, forKey: "memberNumber")
                UserDefaults.standard.set(nil, forKey: "loggedInUserEmailAddress")
                UserDefaults.standard.set(nil, forKey: "loggedInUserLoyaltyStatus")
                UserDefaults.standard.synchronize()
                
                self.showLandingPage()
            }
            
            DataManager.sharedInstance.getUser(accessToken, serviceSuccessHandler: serivceSuccessHandlerInVC, serviceFailureHnadler: serviceFailureHandlerInVC)
        } else {
            showLandingPage()
        }
    }
    
    func showLandingPage() {
        self.performSegue(withIdentifier: "FindACarSegue", sender: self)
    }
}

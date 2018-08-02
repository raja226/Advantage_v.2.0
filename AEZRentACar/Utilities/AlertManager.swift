//
//  AlertManager.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 4/12/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit

class AlertManager: NSObject {
    
    static let sharedInstance: AlertManager = AlertManager()
    
    typealias completionHandler = ((_ tappedButtonTitle: String) -> Void)?
    
    func show(title: String, message: String, fromVC: UIViewController) {
        show(title: title, message: message, fromVC: fromVC, completion: nil)
    }
    
    func show(title: String, message: String, fromVC: UIViewController, completion:completionHandler) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            
            completion?("OK")
        }
        alertController.addAction(defaultAction)
        
        fromVC.present(alertController, animated: true, completion: nil)
    }
}

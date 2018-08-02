//
//  PaymentBreakupDismissSegue.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 10/12/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit

class PaymentBreakupDismissSegue: UIStoryboardSegue {
    override func perform() {
        // Assign the source and destination views to local variables.
        let datePickerVC = self.source as! PaymentBreakupViewController
        let datePickerView = self.source.view!
        let findACarView = self.destination.view!
        
        // Specify the initial position of the destination view.
        findACarView.frame = datePickerView.frame
        
        // Animate the transition.
        datePickerVC.constraintContainerViewCenter.constant = datePickerView.frame.size.height/2
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            datePickerVC.view.backgroundColor = UIColor.clear
            datePickerVC.containerView.layoutIfNeeded()
            datePickerView.layoutIfNeeded()
        }) { (Finished) -> Void in
            self.source.dismiss(animated: false, completion: {
                NotificationCenter.default.post(name: Notification.Name("PaymentBreakupDismissed"), object: nil)
            })
        }
    }
}

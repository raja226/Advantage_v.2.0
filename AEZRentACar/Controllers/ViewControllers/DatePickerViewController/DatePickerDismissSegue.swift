//
//  DatePickerDismissSegue.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 7/12/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit

class DatePickerDismissSegue: UIStoryboardSegue {
    override func perform() {
        // Assign the source and destination views to local variables.
        let datePickerVC = self.source as! DatePickerViewController
        let datePickerView = self.source.view!
        let findACarView = self.destination.view!
        
        // Specify the initial position of the destination view.
        findACarView.frame = datePickerView.frame
        
        // Access the app's key window and insert the destination view above the current (source) one.
//        let window = UIApplication.shared.keyWindow
//        window?.insertSubview(findACarView, aboveSubview: datePickerView)
        
        // Animate the transition.
        datePickerVC.constraintDateViewBottomSpace.constant = -330
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            datePickerVC.view.backgroundColor = UIColor.clear
            datePickerVC.dateView.layoutIfNeeded()
            datePickerView.layoutIfNeeded()
        }) { (Finished) -> Void in
            self.source.dismiss(animated: false, completion: nil)
        }
    }
}

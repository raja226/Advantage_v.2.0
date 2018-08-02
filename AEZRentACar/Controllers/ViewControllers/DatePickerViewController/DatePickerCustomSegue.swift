//
//  DatePickerCustomSegue.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 7/12/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit

class DatePickerCustomSegue: UIStoryboardSegue {
    override func perform() {
        // Assign the source and destination views to local variables.
        let destinationVC = self.destination as! DatePickerViewController
        let firstVCView = self.source.view
        let secondVCView = self.destination.view

        // Specify the initial position of the destination view.
        secondVCView?.frame = firstVCView!.frame
        
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(secondVCView!, aboveSubview: firstVCView!)
        
        // Animate the transition.
        destinationVC.constraintDateViewBottomSpace.constant = 0
        self.destination.view.bringSubview(toFront: destinationVC.dateView)
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            secondVCView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            destinationVC.dateView.layoutIfNeeded()
            secondVCView?.layoutIfNeeded()
        }) { (Finished) -> Void in
            self.source.present(self.destination, animated: false, completion: nil)
        }
    }
}

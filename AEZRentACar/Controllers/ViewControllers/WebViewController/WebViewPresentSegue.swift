//
//  WebViewPresentSegue.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 7/21/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit

class WebViewPresentSegue: UIStoryboardSegue {
    override func perform() {
        // Assign the source and destination views to local variables.
        let destinationVC = self.destination as! WebViewController
        let firstVCView = self.source.view
        let secondVCView = self.destination.view
        
        // Specify the initial position of the destination view.
        secondVCView?.frame = firstVCView!.frame
        
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(secondVCView!, aboveSubview: firstVCView!)
        
        // Animate the transition.
        destinationVC.constraintContainerViewTopSpace.constant = 100
        self.destination.view.bringSubview(toFront: destinationVC.containerView)
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            secondVCView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            destinationVC.containerView.layoutIfNeeded()
            secondVCView?.layoutIfNeeded()
        }) { (Finished) -> Void in
            self.source.present(self.destination, animated: false, completion: nil)
        }
    }
}

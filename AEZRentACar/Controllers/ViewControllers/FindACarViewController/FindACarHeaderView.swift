//
//  FindACarHeaderView.swift
//  AEZRentACar
//
//  Created by Anjali Panjawani on 6/30/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit
import QuartzCore


class FindACarHeaderView: UIView {
    
       
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var dropView: UIView!
    @IBOutlet weak var dateTimeView: UIView!
    
  
    @IBOutlet weak var showPickUpDate: UITextField!
    @IBOutlet weak var showPickUpTime: UITextField!
    @IBOutlet weak var showReturnDate: UITextField!
    @IBOutlet weak var showReturnTime: UITextField!
    @IBOutlet weak var showPickUpLocation: UITextField!
    @IBOutlet weak var showReturnToLocation: UITextField!
    
    
    @IBOutlet weak var rentalDateTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var rentalTimeTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var returnDateTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var returnTimeTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var returnTotextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickUpTextFieldConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropToTextFieldConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var pickUpDateLabel: UILabel!
    @IBOutlet weak var pickUpTimeLabel: UILabel!
    @IBOutlet weak var returnDateLabel: UILabel!
    @IBOutlet weak var returnTimeLabel: UILabel!
    
    @IBOutlet weak var returnToLocationLabel: UILabel!
    @IBOutlet weak var pickUpLocationLabel: UILabel!
    /*
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

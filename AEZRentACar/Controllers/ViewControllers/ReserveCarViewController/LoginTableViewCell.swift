//
//  LoginTableViewCell.swift
//  AEZRentACar
//
//  Created by Anjali Panjawani on 7/14/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit
import MBProgressHUD


class CustomButton: UIButton {
    
    var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            
            let shadowColor = UIColor(red: 28.0/255.0, green: 47.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
            shadowLayer.shadowColor = shadowColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.0, height: 4.0)
            shadowLayer.shadowOpacity = 0.13
            shadowLayer.shadowRadius = 2
            
            layer.insertSublayer(shadowLayer, at: 0)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }        
    }

}


protocol LoginTableViewCellDelegate {
    func loginButtonTapped(cell:LoginTableViewCell)
}


class LoginTableViewCell: UITableViewCell {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var summaryView: UIView!
    
    var delegate: LoginTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal func setCellData(showExpanded: Bool) {
     
        self.loginButton.layer.borderWidth = 1
        self.loginButton.layer.cornerRadius = 8
        self.loginButton.layer.borderColor = UIColor(red: 0/255, green: 83/255, blue: 159/255, alpha: 1).cgColor
        
        if showExpanded {
            self.toggleButton.setImage(UIImage(named: "DropupIcon"), for: .normal)
        } else {
            self.toggleButton.setImage(UIImage(named: "DropdownIcon"), for: .normal)
        }
     }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        self.delegate?.loginButtonTapped(cell: self)
    }

    override func layoutSubviews() {
        summaryView.layer.cornerRadius = 10
        
        let shadowColor = UIColor(red: 28.0/255.0, green: 47.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
        summaryView.layer.shadowColor = shadowColor
        summaryView.layer.shadowOffset =  CGSize(width: 0, height: 2.5)
        summaryView.layer.shadowOpacity = 0.13
        summaryView.layer.shadowRadius = 3.5
        summaryView.layer.shadowPath = UIBezierPath(roundedRect: summaryView.bounds, cornerRadius: 10).cgPath
        summaryView.layer.masksToBounds = false
    }
}

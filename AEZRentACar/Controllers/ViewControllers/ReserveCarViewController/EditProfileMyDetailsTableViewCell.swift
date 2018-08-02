//
//  EditProfileMyDetailsTableViewCell.swift
//  AEZRentACar
//
//  Created by Swapnil Rane on 12/05/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit


class ProfileField : NSObject {
    var fieldName = ""
    var fieldPlaceholder = ""
    var fieldValue = ""
    var fieldKeyboardType = UIKeyboardType.default
    var fieldTag = 100
    
    var isEnabled = true
    var isSecureTextEntry = false
    var rightView: UIView?
    var leftView: UIView?
    var rightViewMode = UITextFieldViewMode.never
    var leftViewMode = UITextFieldViewMode.never
    var autocapitalizationType = UITextAutocapitalizationType.none
    
    var disablePasteOption = false
}


class EditProfileMyDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailTextField: UITextField!
    
 
    @IBOutlet weak var rightImageView: UIImageView!
    
    @IBOutlet weak var constraintTitleLabelWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal func setCellData(profileField: ProfileField, isReservePage: Bool) {
        titleLabel.text = profileField.fieldName
        detailTextField.placeholder = profileField.fieldPlaceholder
        detailTextField.tag = profileField.fieldTag
        detailTextField.keyboardType = profileField.fieldKeyboardType
        detailTextField.text = profileField.fieldValue
        detailTextField.isEnabled = profileField.isEnabled
        detailTextField.isSecureTextEntry = profileField.isSecureTextEntry
        detailTextField.textColor = UIColor.black
        detailTextField.autocapitalizationType = profileField.autocapitalizationType
        
        detailTextField.readonly = profileField.disablePasteOption
        
        if profileField.isEnabled == false {
            detailTextField.textColor = UIColor.darkGray
        }
        
        if isReservePage {
           
            self.rightImageView.isHidden = true
            
            let aezTextField = detailTextField as? AEZTextField
            aezTextField?.shouldAddLeftSpace = false
            
            if let _ = profileField.leftView {
                aezTextField?.shouldAddLeftSpace = true
              
            }
            
            if let _ = profileField.rightView {
                self.rightImageView.isHidden = false
            }
        }
    }
}

//
//  ReservationSummaryCell.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 7/13/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit

class ReservationSummaryCell: UITableViewCell {

    @IBOutlet weak var expandCollapseButton: UIButton!
    
    @IBOutlet weak var returnDateTimeLabel: UILabel!
    @IBOutlet weak var rentalLocationLabel: VerticalTopAlignLabel!
    @IBOutlet weak var returnLocationLabel: VerticalTopAlignLabel!
    @IBOutlet weak var rentalDateTimeLabel: UILabel!
    @IBOutlet weak var rentalAddline: VerticalTopAlignLabel!
    @IBOutlet weak var returnAddLine: VerticalTopAlignLabel!
    @IBOutlet weak var returnToLabel: UILabel!
    @IBOutlet weak var pickUpFromLabel: UILabel!
    
    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var summaryShadowView: UIView!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var selectedCarName: UILabel!
    @IBOutlet weak var selectedCarType: UILabel!
    @IBOutlet weak var editCarButton: UIButton!
    
    @IBOutlet weak var returnLocationLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var rentalLocationLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedCarSectionTopConstraint: NSLayoutConstraint!
    
    var shouldShowCarSection = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func manageUserInterface(showFullSummary: Bool) {
        if shouldShowCarSection {
            if let modelDescription = Reservation.sharedInstance?.selectedCar?.modelDesc {
                self.selectedCarName.text = modelDescription
            }
//            if let modelSimilarLabel = Reservation.sharedInstance?.selectedCar?.category {
//                self.selectedCarType.text = modelSimilarLabel.uppercased()
//            }
            self.selectedCarType.text = "Or Similar"
        }
        if showFullSummary {
            self.expandCollapseButton.setImage(UIImage(named: "DropupIcon"), for: .normal)
            self.editButton.isHidden = false
            
            self.pickUpFromLabel.isHidden = false
            self.returnToLabel.isHidden = false
            
            self.returnLocationLabelTopConstraint.constant = 42
            self.rentalLocationLabelTopConstraint.constant = 42
            
            self.rentalLocationLabel.text = Reservation.sharedInstance?.rentalLocation?.addLine1
            self.returnLocationLabel.text = Reservation.sharedInstance?.returnLocation?.addLine1
            
            self.rentalLocationLabel.lineBreakMode = .byWordWrapping
            self.rentalLocationLabel.numberOfLines = 0
            
            self.returnLocationLabel.lineBreakMode = .byWordWrapping
            self.returnLocationLabel.numberOfLines = 0
            
            self.rentalDateTimeLabel.text = Reservation.sharedInstance?.pickUpDateTime
            self.returnDateTimeLabel.text = Reservation.sharedInstance?.dropOffDateTime
            
            self.rentalAddline.text = Utilities.sharedInstance.locationAddress(location: Reservation.sharedInstance!.rentalLocation!)
            self.returnAddLine.text = Utilities.sharedInstance.locationAddress(location: Reservation.sharedInstance!.returnLocation!)
            
            self.rentalAddline.lineBreakMode = .byCharWrapping
            self.rentalAddline.numberOfLines = 0
            
            self.returnAddLine.lineBreakMode = .byCharWrapping
            self.returnAddLine.numberOfLines = 0
            
            self.rentalDateTimeLabel.isHidden = false
            self.returnDateTimeLabel.isHidden = false
            
            if shouldShowCarSection {
                self.editCarButton.isHidden = false
            }
        } else {
            self.expandCollapseButton.setImage(UIImage(named: "DropdownIcon"), for: .normal)
            self.editButton.isHidden = true
            
            self.pickUpFromLabel.isHidden = true
            self.returnToLabel.isHidden = true

            self.returnLocationLabelTopConstraint.constant = 15
            self.rentalLocationLabelTopConstraint.constant = 15
            if shouldShowCarSection {
                self.selectedCarSectionTopConstraint.constant = -15
                self.editCarButton.isHidden = true
            }
            
            self.rentalLocationLabel.text = Reservation.sharedInstance?.rentalLocation?.addLine1
            self.returnLocationLabel.text = Reservation.sharedInstance?.returnLocation?.addLine1
            
            self.rentalLocationLabel.lineBreakMode = .byTruncatingTail
            self.rentalLocationLabel.numberOfLines = 1
            
            self.returnLocationLabel.lineBreakMode = .byTruncatingTail
            self.returnLocationLabel.numberOfLines = 1
            
            self.rentalAddline.text = Reservation.sharedInstance?.pickUpDateTime
            self.returnAddLine.text = Reservation.sharedInstance?.dropOffDateTime
            
            self.rentalAddline.lineBreakMode = .byTruncatingTail
            self.rentalAddline.numberOfLines = 1
            
            self.returnAddLine.lineBreakMode = .byTruncatingTail
            self.returnAddLine.numberOfLines = 1
            
            self.rentalDateTimeLabel.isHidden = true
            self.returnDateTimeLabel.isHidden = true
        }
    }

    override func layoutSubviews() {
        summaryView.layer.cornerRadius = 10
//        summaryView.layer.masksToBounds = true
        summaryShadowView.isHidden = true
        
        let shadowColor = UIColor(red: 28.0/255.0, green: 47.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
        summaryView.layer.shadowColor = shadowColor
        summaryView.layer.shadowOffset =  CGSize(width: 0, height: 2.5)
        summaryView.layer.shadowOpacity = 0.13
        summaryView.layer.shadowRadius = 3.5
        summaryView.layer.shadowPath = UIBezierPath(roundedRect: summaryView.bounds, cornerRadius: 10).cgPath
        summaryView.layer.masksToBounds = false
    }
}

class VerticalTopAlignLabel: UILabel {
    
    override func drawText(in rect:CGRect) {
        guard let labelText = text else {  return super.drawText(in: rect) }
        
        let attributedText = NSAttributedString(string: labelText, attributes: [NSFontAttributeName: font])
        var newRect = rect
        newRect.size.height = attributedText.boundingRect(with: rect.size, options: .usesLineFragmentOrigin, context: nil).size.height
        
        if numberOfLines != 0 {
            newRect.size.height = min(newRect.size.height, CGFloat(numberOfLines) * font.lineHeight)
        }
        
        super.drawText(in: newRect)
    }
    
}

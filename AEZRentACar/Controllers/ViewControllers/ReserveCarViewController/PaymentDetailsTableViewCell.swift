//
//  PaymentDetailsTableViewCell.swift
//  AEZRentACar
//
//  Created by Anjali Panjawani on 7/17/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit

protocol PaymentDetailsTableViewCellDelegate {
    func paymentDetailsCellDidUpdatePaySwitch()
}

class PaymentDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var payNowTotalLabel: UILabel!
    @IBOutlet weak var payLaterTotalLabel: UILabel!
    @IBOutlet weak var payNowSwitch: UISwitch!
    @IBOutlet weak var payLaterSwitch: UISwitch!
    @IBOutlet weak var payNowStackView: UIStackView!
    
    var delegate: PaymentDetailsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

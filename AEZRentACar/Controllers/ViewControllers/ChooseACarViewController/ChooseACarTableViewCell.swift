//
//  ChooseACarTableViewCell.swift
//  AEZRentACar
//
//  Created by Anjali Panjawani on 7/6/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit
import AlamofireImage


class ChooseACarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var modelDescriptionLabel: UILabel!
    @IBOutlet weak var modelSimilarLabel: UILabel!
    @IBOutlet weak var carDetailsLabel: UILabel!
    @IBOutlet weak var airConditionLabel: UILabel!
    
    @IBOutlet weak var passengerLabel: UILabel!
    @IBOutlet weak var doorsLabel: UILabel!
    @IBOutlet weak var luggageLabel: UILabel!
    @IBOutlet weak var payOnlineTotalLabel: UILabel!
    @IBOutlet weak var payAtCounterTotalLabel: UILabel!
    
    @IBOutlet weak var transmissionLabel: UILabel!
    @IBOutlet weak var payOnlineButton: UIButton!
    @IBOutlet weak var payAtCounterButton: UIButton!
    
    @IBOutlet weak var carImageView: UIImageView!
    
    @IBOutlet weak var constraintPayOnlineViewHeight: NSLayoutConstraint!
    @IBOutlet weak var payLaterPayOnlineBorderView: UIView!
    
    var indexPath: NSIndexPath?
    let downloader = ImageDownloader()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    internal func setCellData(response: Vehicle, indexPath: NSIndexPath) {
        
        if response.hasPostpaidOnly {
            self.constraintPayOnlineViewHeight.constant = 0
            self.payLaterPayOnlineBorderView.isHidden = true
        } else {
            self.payLaterPayOnlineBorderView.isHidden = false
            self.constraintPayOnlineViewHeight.constant = 50
        }
        
        self.indexPath = indexPath
        
        self.payAtCounterButton.tag = indexPath.row
        self.payAtCounterButton.layer.cornerRadius = 8
        self.payAtCounterButton.layer.borderWidth = 1
        self.payAtCounterButton.layer.borderColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1).cgColor
        self.payAtCounterButton.titleLabel!.textAlignment = .center
        
        self.payOnlineButton.tag = indexPath.row
        self.payOnlineButton.layer.borderWidth = 1
        self.payOnlineButton.layer.cornerRadius = 8
        self.payOnlineButton.layer.borderColor = UIColor(red: 153/255, green: 204/255, blue: 1/255, alpha: 1).cgColor
        self.payOnlineButton.titleLabel!.textAlignment = .center
        
        modelDescriptionLabel.lineBreakMode = .byWordWrapping
        modelDescriptionLabel.numberOfLines = 2
        
        carDetailsLabel.lineBreakMode = .byWordWrapping // or NSLineBreakMode.ByWordWrapping
        carDetailsLabel.numberOfLines = 2
        
//        if let modelSimilarLabel = response.category {
//            self.modelSimilarLabel.text = modelSimilarLabel.uppercased()
//        }
        self.modelSimilarLabel.text = "Or Similar"
        
        if let modelDescription = response.modelDesc {
            self.modelDescriptionLabel.text = modelDescription
        }
        
        if let classDesc = response.classDesc {
            if let classCode = response.classCode {
                self.carDetailsLabel.text = "\(classDesc)| \(classCode)"
            }
        }
    
        if let imageUrl = response.classImageURL2 {
            let urlRequest = URLRequest(url: URL(string: imageUrl)!)
            self.carImageView?.image = UIImage(named: "Placeholder")
            downloader.download(urlRequest) { response in
                if let image = response.result.value {
                    self.carImageView?.image = image
                } else {
                    self.carImageView?.image = UIImage(named: "Placeholder")
                }
            }
        }
        
        let pcrc = "\(Utilities.displayRateWithCurrency(rate: "NA", currency: response.currencyCode)) Daily"
        payAtCounterButton.setTitle(pcrc, for: .normal)
        payOnlineButton.setTitle(pcrc, for: .normal)
        
        if let payCounterRateCharge = response.payLaterRate.dailyRate {
            let payCounterstring = "\(Utilities.displayRateWithCurrency(rate: payCounterRateCharge, currency: response.currencyCode)) Daily"
            payAtCounterButton.setTitle(payCounterstring, for: .normal)
        }
        
        if let payOnlineRateCharge = response.payNowRate.dailyRate {
            let payOnlineString = "\(Utilities.displayRateWithCurrency(rate: payOnlineRateCharge, currency: response.currencyCode)) Daily"
            payOnlineButton.setTitle(payOnlineString, for: .normal)
        }
        
        
        self.payAtCounterTotalLabel.text = "NA"
        self.payOnlineTotalLabel.text = "NA"
        
        if let payCounterTotalCharge  = response.payLaterRate.totalRate {
            let payCounterTotalString = Utilities.displayRateWithCurrency(rate: payCounterTotalCharge, currency: response.currencyCode)
            self.payAtCounterTotalLabel.text = payCounterTotalString
        }
        
        if let payOnlineTotalCharge  = response.payNowRate.totalRate {
            let payOnlineTotalString = Utilities.displayRateWithCurrency(rate: payOnlineTotalCharge, currency: response.currencyCode)
            self.payOnlineTotalLabel.text = payOnlineTotalString
        }
        
        if let airCondition = response.airConditioning {
            if airCondition == "Yes" {
                self.airConditionLabel.text = "A/C"
            } else {
                self.airConditionLabel.text = "NA"
            }
        }
        
        if let transmission = response.transmission {
            self.transmissionLabel.text = String(transmission.characters[transmission.characters.startIndex])
        }
        
        //    self.doorsLabel.text = "1"
        
        if let passengers = response.passengers {
            self.passengerLabel.text = passengers
        }
        
        if let luggage = response.luggage {
            self.luggageLabel.text = luggage
        }
    }
    
    override func layoutSubviews() {
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 10
        
        let shadowColor = UIColor(red: 28.0/255.0, green: 47.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
        shadowView.layer.shadowColor = shadowColor
        shadowView.layer.shadowOffset =  CGSize(width: 0, height: 2.5)
        shadowView.layer.shadowOpacity = 0.13
        shadowView.layer.shadowRadius = 3.5
        shadowView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 10).cgPath
        shadowView.layer.masksToBounds = false
    }
}

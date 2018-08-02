//
//  PaymentBreakupViewController.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 10/12/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit

protocol PaymentBreakupViewControllerDelegate {
    func paymentBreakupViewControllerDidSelectYes()
}

class PaymentBreakupViewController: UIViewController {
    var myMutableString = NSMutableAttributedString()

    @IBOutlet weak var extraChargesLabel: UILabel!
    @IBOutlet weak var extraTitleLabel: UILabel!
    @IBOutlet weak var taxandFeesSeparatorView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var constraintContainerViewBottomSpace: NSLayoutConstraint!
    
    @IBOutlet weak var constraintDiscountViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintDiscountViewTopSpace: NSLayoutConstraint!
    
    @IBOutlet weak var constraintScrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintContainerViewCenter: NSLayoutConstraint!
    
    @IBOutlet weak var dailyRateLabel: UILabel!
    @IBOutlet weak var taxesBreakupLabel: UILabel!
    @IBOutlet weak var taxesBreakupCharges: UILabel!
    @IBOutlet weak var totalCharges: UILabel!
    @IBOutlet weak var totalTaxesLabel: UILabel!
    @IBOutlet weak var discountPercentLabel: UILabel!
    @IBOutlet weak var discountAmountLabel: UILabel!
    
    var delegate: PaymentBreakupViewControllerDelegate?
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.containerView.layer.cornerRadius = 10
        self.containerView.clipsToBounds = true
        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        populateTaxes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let maxHeight: CGFloat = self.view.frame.size.height - (200 + 188)
        if self.scrollView.contentSize.height < maxHeight {
            self.constraintScrollViewHeight.constant = self.scrollView.contentSize.height
        } else {
            self.constraintScrollViewHeight.constant = maxHeight
        }
    }
    
    func populateTaxes() {
        let currencyCode = Reservation.sharedInstance?.selectedCar?.currencyCode
        
        var displayRate = Reservation.sharedInstance!.selectedCar!.payLaterRate
        if Reservation.sharedInstance!.prepaid == "Y" {
            displayRate = Reservation.sharedInstance!.selectedCar!.payNowRate
        }
        
        // Fees and options
        var rateCharges = Utilities.displayRateWithCurrency(rate: "NA", currency: currencyCode)
        if let rateCrg = displayRate.dailyRate {
            rateCharges = Utilities.displayRateWithCurrency(rate: rateCrg, currency: currencyCode)
        }
        self.dailyRateLabel.text = rateCharges
        
        var totalCharges = Utilities.displayRateWithCurrency(rate: "NA", currency: currencyCode)
        if let totCharges = displayRate.totalRate {
            totalCharges = Utilities.displayRateWithCurrency(rate: totCharges, currency: currencyCode)
        }
       self.totalCharges.text = totalCharges
        
        
        var totalfeeandTaxes = Utilities.displayRateWithCurrency(rate: "NA", currency: currencyCode)
        if let totCharges = displayRate.totalTaxes {
            totalfeeandTaxes = Utilities.displayRateWithCurrency(rate: totCharges, currency: currencyCode)
        }
        var taxesBreakupText = ""
        var taxesFeesText = ""
        for tax in displayRate.taxes! {
            taxesBreakupText = taxesBreakupText.appending(tax.taxDescription)
            taxesBreakupText = taxesBreakupText.appending("\n")
            
            let charge = Utilities.displayRateWithCurrency(rate: tax.taxCharge, currency: currencyCode)
            taxesFeesText = taxesFeesText.appending(charge)
            taxesFeesText = taxesFeesText.appending("\n")
        }
        
        
        // taxes and fees tota Missing :
        let totalTaxes = Double(displayRate.totalTaxes!)!
        let totalExtras = Double(displayRate.totalExtras!)!
        //let dispTotalExtra = "\(totalTaxes + totalExtras)"
        let dispTotalExtra = "\(totalTaxes ) "
        self.totalTaxesLabel.text = Utilities.displayRateWithCurrency(rate: displayRate.totalTaxes!, currency: currencyCode)

        
        //Font:
        
        
        var taxandFeestotalStartPosition = -1
        var taxtandFeesStartPosition = -1
        var taxtandFeesLength = 0
        
        var displayValuesAll = Reservation.sharedInstance!.selectedCar!.payLaterRate

          if Reservation.sharedInstance!.prepaid == "Y" {
            displayValuesAll = Reservation.sharedInstance!.selectedCar!.payNowRate
         }
        
        //let displayValuesAll = Reservation.sharedInstance!.selectedCar!.payLaterRate
        var totalExtrasCharges = Utilities.displayRateWithCurrency(rate: "NA", currency: currencyCode)
        if let totCharges = displayValuesAll.totalExtras {
            totalExtrasCharges = Utilities.displayRateWithCurrency(rate: totCharges, currency: currencyCode)
            
        }
        
        taxandFeestotalStartPosition = taxesBreakupText.characters.count
        taxtandFeesStartPosition = taxesFeesText.characters.count
        taxtandFeesLength = totalfeeandTaxes.characters.count + 2
        
     
        //Adding Additional SectionScreen:
        
        taxesBreakupText = taxesBreakupText.appending("\n")
        taxesBreakupText = taxesBreakupText.appending("Taxes and Fees Total")
        taxesBreakupText = taxesBreakupText.appending("\n")
        
        taxesFeesText = taxesFeesText.appending("\n")
        taxesFeesText = taxesFeesText.appending(self.totalTaxesLabel.text!)
        self.totalTaxesLabel.text = ""
        taxesFeesText = taxesFeesText.appending("\n")
        
        // Remove last \n from texts
        var endIndex1 = taxesBreakupText.index(taxesBreakupText.endIndex, offsetBy: 0)
        taxesBreakupText = taxesBreakupText.substring(to: endIndex1)
        
       var endIndex2 = taxesFeesText.index(taxesFeesText.endIndex, offsetBy: 0)
        taxesFeesText = taxesFeesText.substring(to: endIndex2)
        
        
        //For Bold Font For :TaxAndFee Total
        
        if taxandFeestotalStartPosition != -1 {
            
            let textRange = NSRange(location: taxandFeestotalStartPosition , length: 21)
            self.taxesBreakupLabel.attributedText = attributedText(text: taxesBreakupText, range: textRange)
            
            let chargeRange = NSRange(location: taxtandFeesStartPosition, length: taxtandFeesLength)
            self.taxesBreakupCharges.attributedText = attributedText(text: taxesFeesText, range: chargeRange)
            
        } else {
            self.taxesBreakupLabel.text = taxesBreakupText
            self.taxesBreakupCharges.text = taxesFeesText
        }
        
      
        //
        var extraTaxesBreakupText = ""
        var extraTaxeschargesText = ""
        
        var extratTotalTextStartPosition = -1
        var extratTotalChargeStartPosition = -1
        var extratTotalChargeLength = 0
        
        for extra in displayRate.extras! {
            if extra.extraDescription == "" && extra.extraAmount == "" {
                continue
            }
            
            if extra.extraDescription == "UNDER AGE DRIVER" {
            

                //
                extraTaxesBreakupText = extraTaxesBreakupText.appending(extra.extraDescription)
                extraTaxesBreakupText = extraTaxesBreakupText.appending("\n")
                
                let charge = Utilities.displayRateWithCurrency(rate: extra.extraAmount, currency: currencyCode)
                extraTaxeschargesText = extraTaxeschargesText.appending(charge)
                extraTaxeschargesText = extraTaxeschargesText.appending("\n")
                //

               
            }else{
                //
                extraTaxesBreakupText = extraTaxesBreakupText.appending(extra.extraDescription)
                extraTaxesBreakupText = extraTaxesBreakupText.appending("\n")
                
                let charge = Utilities.displayRateWithCurrency(rate: extra.extraAmount, currency: currencyCode)
                extraTaxeschargesText = extraTaxeschargesText.appending(charge)
                extraTaxeschargesText = extraTaxeschargesText.appending("\n")
            }
          
            
            
 

            
            
        }
        
        //TotalExtras
        

    var totalExtrasCount = Utilities.displayRateWithCurrency(rate: displayRate.totalExtras!, currency: currencyCode)
        
        extratTotalTextStartPosition = extraTaxesBreakupText.characters.count
        extratTotalChargeStartPosition = extraTaxeschargesText.characters.count
 
         extratTotalChargeLength = totalExtrasCount.characters.count + 2
        
        
        
        
        extraTaxesBreakupText = extraTaxesBreakupText.appending("\n")
        extraTaxesBreakupText = extraTaxesBreakupText.appending("Extra Total")
        extraTaxesBreakupText = extraTaxesBreakupText.appending("\n")
        
        
        
        extraTaxeschargesText = extraTaxeschargesText.appending("\n")
        
        extraTaxeschargesText = extraTaxeschargesText.appending(totalExtrasCount)
        extraTaxeschargesText = extraTaxeschargesText.appending("\n")
        
        
        
        // Remove last \n from texts
        var endIndex = extraTaxesBreakupText.index(extraTaxesBreakupText.endIndex, offsetBy: -1)
        extraTaxesBreakupText = extraTaxesBreakupText.substring(to: endIndex)
        
        endIndex = extraTaxeschargesText.index(extraTaxeschargesText.endIndex, offsetBy: -1)
        extraTaxeschargesText = extraTaxeschargesText.substring(to: endIndex)
        
        
        
        
        //For Bold Font For :Extra Tax Total
        
        if extratTotalTextStartPosition != -1 {
            
            let textRange = NSRange(location: extratTotalTextStartPosition  , length: 12)
            self.extraTitleLabel.attributedText = attributedText(text: extraTaxesBreakupText, range: textRange)
            
            //extratTotalChargeLength
            let chargeRange = NSRange(location: extratTotalChargeStartPosition, length: extratTotalChargeLength-1)
            self.extraChargesLabel.attributedText = attributedText(text: extraTaxeschargesText, range: chargeRange)
          
            
        } else {
            self.extraTitleLabel.text = extraTaxesBreakupText
            self.extraChargesLabel.text = extraTaxeschargesText
        }

        //
       
        
        // Discount Information
        if let discountAmount = displayRate.discountAmount {
            self.discountAmountLabel.text = Utilities.displayRateWithCurrency(rate: discountAmount, currency: currencyCode)
            self.constraintDiscountViewTopSpace.constant = 35
            self.constraintDiscountViewHeight.constant = 0.5
            self.discountAmountLabel.isHidden = false
            self.discountPercentLabel.isHidden = false
        } else {
            self.constraintDiscountViewTopSpace.constant = 0
            self.constraintDiscountViewHeight.constant = 0
            self.discountAmountLabel.isHidden = true
            self.discountPercentLabel.isHidden = true
        }
        

        print( self.constraintScrollViewHeight.constant)
        print( self.scrollView.contentSize.height)
        var extrascomponentCount :CGFloat = 1
        if (displayRate.extras?.count)! > 0 {
            extrascomponentCount = CGFloat((displayRate.extras?.count)!)
        }
        
        /*
        containerView.layoutIfNeeded() //set a frame based on constraints
        scrollView.contentSize = CGSize(width: containerView.frame.width, height: containerView.frame.height)
 
 */
     
        let maxHeight: CGFloat = self.view.frame.size.height - (200 + 188)
        if self.scrollView.contentSize.height < maxHeight {
            self.constraintScrollViewHeight.constant = self.scrollView.contentSize.height + 0
        } else {
            self.constraintScrollViewHeight.constant = maxHeight + 0
        }

    }
    
    func attributedText(text: String, range: NSRange) -> NSAttributedString {
        let formattedAttributedString = NSMutableAttributedString(string: text)
        let font = UIFont(name: "Montserrat-Regular", size: 12)
        let color = UIColor(red: 0, green: 0, blue: 51/255, alpha: 1)
        formattedAttributedString.addAttribute(NSFontAttributeName, value: font!,range: range)
        formattedAttributedString.addAttribute(NSForegroundColorAttributeName, value: color,range: range)
        return formattedAttributedString
    }
    
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss()
    }
    
    @IBAction func yesButtonTapped(_ sender: Any) {
        self.delegate?.paymentBreakupViewControllerDidSelectYes()
        dismiss()
    }
    
    @IBAction func noButtonTapped(_ sender: Any) {
        dismiss()
    }
    
    func dismiss() {
        self.constraintContainerViewBottomSpace.constant = -100
        self.performSegue(withIdentifier: "paymentBreackUpUnwindSegue", sender: self)
    }
}

//
//  DatePickerViewController.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 7/11/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate {
    func datePickerViewControllerDidSelectDate(selectedDate: Date)
}

class DatePickerViewController: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var savePickUpButton: UIButton!
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var showDateLabel: UILabel!

    @IBOutlet weak var constraintDateViewBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var constraintDateViewHeight: NSLayoutConstraint!
    
    var activeField: UITextField!
    var selectedDate: Date?
    var minimumDate: Date!
    
    var delegate: DatePickerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.datePicker.addTarget(self, action: #selector(updateDateField), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleTapGesture(_ sender: Any) {
        dismissDatePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let selectedDate = self.selectedDate {
            if self.minimumDate > selectedDate {
                self.datePicker.date = self.minimumDate
            } else {
                self.datePicker.date = selectedDate
            }
        }
        self.datePicker.minimumDate = minimumDate
        self.datePicker.minuteInterval = 30
        self.datePicker.locale = Locale(identifier: "en_US")
        updateDateField()
    }
    
    func updateDateField() {
        
        let dateFormatter1 = DateFormatter()
        let timeFormatter = DateFormatter()
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "MM/dd/yyyy,hh:mm a"
        dateFormatter1.dateFormat = "MM/dd/yyyy"
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.locale = Locale(identifier: "en_US")
        
        if activeField?.tag == tagRentalDateTextField || activeField?.tag == tagRentalTimeTextField {
            self.dateLable.text = "Pick Up Date & Time"
            self.showDateLabel.text = dateFormatter2.string(from: self.datePicker.date)
            self.savePickUpButton.setTitle("Set Pick Up", for: .normal)
        } else {
            self.dateLable.text = "Return Date & Time"
            self.showDateLabel.text = dateFormatter2.string(from: self.datePicker.date)
            self.savePickUpButton.setTitle("Set Return", for: .normal)
        }
    }
    
    @IBAction func selectDateTapped(_ sender: Any) {
        dismissDatePicker()
    }
    
    func dismissDatePicker() {
        self.delegate?.datePickerViewControllerDidSelectDate(selectedDate: self.datePicker.date)
//        self.presentingViewController?.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "DatePickerDismissSegue", sender: self)
    }
}

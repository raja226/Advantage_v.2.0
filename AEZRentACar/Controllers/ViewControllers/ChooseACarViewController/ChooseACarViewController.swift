//
//  ChooseACarViewController.swift
//  AEZRentACar
//
//  Created by Anjali Panjawani on 7/5/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import UIKit
import QuartzCore
import MBProgressHUD
import Alamofire

class ChooseACarViewController: LogoutFunctionalityViewController, UITableViewDataSource,UITableViewDelegate {
  
    @IBOutlet weak var carsTableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    
    var aezRates: AEZRates!
    var vehicleList : [Vehicle]?
    var sortOptionsArr : [VehicleSortOption]?
    var selectedSortName = "Price: Low to High"
    
    var isSummaryExpanded = false
    
    var firstTimeOnThisVC = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.logoutButton.isHidden = true
        
        self.carsTableView.tableFooterView = UIView()
        self.carsTableView.rowHeight = UITableViewAutomaticDimension
        self.carsTableView.estimatedRowHeight = 44
        
        if self.vehicleList == nil {
            self.vehicleList = aezRates.vehicles
            self.sortOptionsArr = aezRates.sortOptions
            
            self.carsTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if firstTimeOnThisVC {
            firstTimeOnThisVC = false
            let indexSet: IndexSet = [0]
            self.carsTableView.reloadSections(indexSet, with: .automatic)
            self.carsTableView.reloadData()
        }
        
        if let _ = UserDefaults.standard.string(forKey: "access_token") {
            self.logoutButton.isHidden = false
        } else {
            self.logoutButton.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func chooseCarShowReservationDescriptionButtonTapped(_ sender: UIButton) {
        if isSummaryExpanded {
            isSummaryExpanded = false
        } else {
            isSummaryExpanded = true
        }
        let lastIndexPath = IndexPath(row: 0, section: 0)
        self.carsTableView.beginUpdates()
        self.carsTableView.reloadRows(at: [lastIndexPath], with: .automatic)
        self.carsTableView.endUpdates()
    }
    
    func sortProduct(button: UIButton, buttonIndex: Int) {
        if let sortName = self.sortOptionsArr?[buttonIndex].name {
            selectedSortName = sortName
        }
        
        if let sortBy = self.sortOptionsArr?[buttonIndex].value{
            switch (sortBy) {
            case "low-high":
                if let vehicleArrForsorting = self.vehicleList {
                    self.vehicleList = vehicleArrForsorting.sorted { (object1, object2) -> Bool in
                        return Double(object1.payLaterRate.dailyRate!)! < Double(object2.payLaterRate.dailyRate!)!
                    }
                }
            case "high-low":
                if let vehicleArrForsorting = self.vehicleList {
                    self.vehicleList =  vehicleArrForsorting.sorted { (object1, object2) -> Bool in
                        return Double(object1.payLaterRate.dailyRate!)! > Double(object2.payLaterRate.dailyRate!)!
                    }
                }
            case "seating":
                if let vehicleArrForsorting = self.vehicleList {
                    self.vehicleList =  vehicleArrForsorting.sorted { (object1, object2) -> Bool in
                        return Int(object1.passengers!)! > Int(object2.passengers!)!
                    }
                }
            case "luggage":
                if let vehicleArrForsorting = self.vehicleList {
                    self.vehicleList =  vehicleArrForsorting.sorted { (object1, object2) -> Bool in
                        return Int(object1.luggage!)! > Int(object2.luggage!)!
                    }
                }
            case "mpg":
                if let vehicleArrForsorting = self.vehicleList {
                    var highwayList = vehicleArrForsorting.filter { $0.mpgHighway != nil }
                    var notHighwayList = vehicleArrForsorting.filter { $0.mpgHighway == nil }
                    
                    highwayList = highwayList.sorted { Int($0.mpgHighway!)! > Int($1.mpgHighway!)!}
                    notHighwayList = notHighwayList.sorted { Double($0.payLaterRate.dailyRate!)! < Double($1.payLaterRate.dailyRate!)!}
                    self.vehicleList = highwayList + notHighwayList
                }
            default:
                break
            }
        }
        
        self.carsTableView.reloadData()
        let zeroIndexPath = IndexPath(row: 0, section: 0)
        self.carsTableView.scrollToRow(at: zeroIndexPath, at: .top, animated: true)
    }
    
    // MARK: - IBOutlet Actions
    
    @IBAction func sortButtonTapped(_ sender: UIButton) {
        let actionSheetController = UIAlertController(title: "SORT BY", message: nil, preferredStyle: .actionSheet)
        if let sortOptions =  self.sortOptionsArr {
            
            for option in sortOptions {
                actionSheetController.addAction(UIAlertAction(title: option.name, style: .default, handler: { action in
                    self.sortProduct(button: sender, buttonIndex: actionSheetController.actions.index(of: action)!) }))
            }
            actionSheetController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func payOnlineButtonTapped(_ sender: UIButton) {
        if NetworkReachabilityManager()!.isReachable {
            Reservation.sharedInstance?.prepaid = "Y"
            let selectedCar = self.vehicleList![sender.tag]
            if let _ = selectedCar.payNowRate.dailyRate {
                Reservation.sharedInstance?.selectedCar = selectedCar
                self.performSegue(withIdentifier: "ReserveSegue", sender: self)
            } else {
                AlertManager.sharedInstance.show(title: "Error", message: "Something went wrong. Please try again later.", fromVC: self)
            }
        } else {
            AlertManager.sharedInstance.show(title: "Error", message: "The Internet connection appears to be offline.", fromVC: self)
        }
    }
    
    @IBAction func payAtCounterButtonTapped(_ sender: UIButton) {
        if NetworkReachabilityManager()!.isReachable {
            Reservation.sharedInstance?.prepaid = "N"
            let selectedCar = self.vehicleList![sender.tag]
            if let _ = selectedCar.payLaterRate.dailyRate {
                Reservation.sharedInstance?.selectedCar = selectedCar
                self.performSegue(withIdentifier: "ReserveSegue", sender: self)
            } else {
                AlertManager.sharedInstance.show(title: "Error", message: "Something went wrong. Please try again later.", fromVC: self)
            }
        } else {
            AlertManager.sharedInstance.show(title: "Error", message: "The Internet connection appears to be offline.", fromVC: self)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // MARK: - TableView delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if vehicleList == nil {
                return 0
            } else {
                return vehicleList!.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            if isSummaryExpanded {
                return 101 + heightOfLocationNameAndAddress()
            } else {
                return 71
            }
        } else {
            let vehicle = vehicleList![indexPath.row]
            if vehicle.hasPostpaidOnly {
                return UITableViewAutomaticDimension
            }
            return UITableViewAutomaticDimension
//            let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 160, height: CGFloat.greatestFiniteMagnitude))
//            
//            let vehicle = vehicleList![indexPath.row]
//            let labelText = vehicle.modelDesc
//           
//            label.numberOfLines = 2
//            label.lineBreakMode = NSLineBreakMode.byWordWrapping
//            label.text = labelText
//            label.sizeToFit()
//            
//            var height = label.frame.height + 270
//            
//            if vehicle.hasPostpaidOnly {
//                height = height - 50
//            }
//            return height
        }
    }
    
    func heightOfLocationNameAndAddress() -> CGFloat {
        let locationFont = UIFont(name: "Montserrat-Medium", size: 10)!
        let rentalLocationHeight = heightForText(text: Reservation.sharedInstance!.rentalLocation!.addLine1!, font: locationFont)
        let returnLocationHeight = heightForText(text: Reservation.sharedInstance!.returnLocation!.addLine1!, font: locationFont)
        
        let addressFont = UIFont(name: "Montserrat-Regular", size: 10)!
        let rentalAddressHeight = heightForText(text: Utilities.sharedInstance.locationAddress(location: Reservation.sharedInstance!.rentalLocation!), font: addressFont)
        let returnAddressHeight = heightForText(text: Utilities.sharedInstance.locationAddress(location: Reservation.sharedInstance!.returnLocation!), font: addressFont)
        
        let maxLocationHeight = rentalLocationHeight > returnLocationHeight ? rentalLocationHeight : returnLocationHeight
        let maxAddressHeight = rentalAddressHeight > returnAddressHeight ? rentalAddressHeight : returnAddressHeight
        return maxAddressHeight + maxLocationHeight
    }
    
    func heightForText(text: String, font: UIFont) -> CGFloat {
        let width = (self.view.frame.size.width - 98)/2
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        
        var returnHeight: CGFloat = 24
        let labelText = text
        label.text = labelText
        label.sizeToFit()
        returnHeight = label.frame.height
        return returnHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryCell") as? ReservationSummaryCell
            cell?.manageUserInterface(showFullSummary: isSummaryExpanded)
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "carDetailCell") as? ChooseACarTableViewCell
            
//            cell?.containerView.layer.cornerRadius = 10
//            cell?.containerView.layer.masksToBounds = true
//            
//            let shadowColor = UIColor(red: 28.0/255.0, green: 47.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
//            cell!.shadowView.layer.shadowColor = shadowColor
//            cell!.shadowView.layer.shadowOffset =  CGSize(width: 0, height: 5)
//            cell!.shadowView.layer.shadowOpacity = 0.13
//            cell!.shadowView.layer.shadowRadius = 7
//            cell!.shadowView.layer.shadowPath = UIBezierPath(roundedRect: cell!.containerView.bounds, cornerRadius: 10).cgPath
//            cell!.shadowView.layer.masksToBounds = false
            
            let vehicle = vehicleList![indexPath.row]
            cell?.setCellData(response: vehicle, indexPath: indexPath as NSIndexPath)
            cell?.payAtCounterButton.tag = indexPath.row
            
            cell?.layoutIfNeeded()
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            cell.setNeedsLayout()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = tableView.dequeueReusableCell(withIdentifier: "SortOptionHeaderCell")?.contentView
            headerView?.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
            if let numOfCarsLabel = headerView?.viewWithTag(656) as? UILabel {
                numOfCarsLabel.text = "We found \(self.vehicleList!.count) Cars:"
            }
            
            if let sortButton = headerView?.viewWithTag(61) as? UIButton {
                sortButton.setTitle(selectedSortName, for: .normal)
            }
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 44
        }
        return 0
    }
}

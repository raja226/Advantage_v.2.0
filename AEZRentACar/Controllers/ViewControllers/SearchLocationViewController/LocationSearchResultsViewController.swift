//
//  LocationSearchResultsViewController.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 4/14/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import MBProgressHUD
import QuartzCore

protocol LocationSearchResultsViewControllerDelegate {
    func locationSearchResultsViewControllerDidSelectLocation(vc:LocationSearchResultsViewController, location: Location)
}

class LocationSearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate {
    
    var locationArray = [Location]()
    var searchTimer : Timer?
    var searchString : String?
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableView: UITableView!

    var delegate: LocationSearchResultsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Search Controller
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        self.extendedLayoutIncludesOpaqueBars = true
        
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.setImage(UIImage(named: "Close_icon"), for: UISearchBarIcon.clear, state: UIControlState.normal)
        searchController.searchBar.setImage(UIImage(named: "Close_icon"), for: UISearchBarIcon.clear, state: UIControlState.highlighted)
        
        self.addBottomBorderWithColor(color: UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0), width: 0.7)
        
        self.tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.backgroundImage = UIImage(named: "Search_bg")
        
        
        self.tableView.estimatedRowHeight = 70.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .singleLine
        
        
        
        let floatVersion = (UIDevice.current.systemVersion as NSString).floatValue

        //let systemVersion = UIDevice.current.systemVersion
        print("iOS\(floatVersion)")
        
        if floatVersion >= 11.0 {
            searchController.searchBar.backgroundImage = UIImage()

        }else{
          
             searchController.searchBar.layer.shadowColor =  UIColor(red: 28.0/255.0, green: 47.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
             
             searchController.searchBar.layer.shadowOffset = CGSize(width: 2, height: 2)
             searchController.searchBar.layer.shadowOpacity = 0.20
             searchController.searchBar.layer.shadowRadius = 1.0
             searchController.searchBar.clipsToBounds = false
             searchController.searchBar.layer.masksToBounds = false
             
            
        }

        

        /*
        searchController.searchBar.layer.shadowColor =  UIColor(red: 28.0/255.0, green: 47.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
 
        searchController.searchBar.layer.shadowOffset = CGSize(width: 2, height: 2)
        searchController.searchBar.layer.shadowOpacity = 0.20
        searchController.searchBar.layer.shadowRadius = 1.0
        searchController.searchBar.clipsToBounds = false
        searchController.searchBar.layer.masksToBounds = false
 
        */
        

    }

    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y:   searchController.searchBar.frame.size.height - width, width: (  searchController.searchBar.frame.size.width), height: width)
         searchController.searchBar.layer.addSublayer(border)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
      
        if #available(iOS 9.0, *) {
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSFontAttributeName:UIFont(name: "Montserrat-Regular", size: 12)!]
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchController.isActive = true
        DispatchQueue.main.async { [unowned self] in
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    // This is workaround to stop scrolling when searchController is inactive.
    func didPresentSearchController(_ searchController: UISearchController) {
        self.tableView.isScrollEnabled = true
    }
    // This is workaround to stop scrolling when searchController is inactive.
    func didDismissSearchController(_ searchController: UISearchController) {
        //searchController.isActive = false

        self.tableView.setContentOffset(CGPoint.zero, animated: true)
        self.tableView.isScrollEnabled = false
    }
    
    func searchEditingChanged(searchStr: String) {
        searchString = searchStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if searchStr.characters.count > 0 {
            if let timer = searchTimer {
                timer.invalidate()
            }
            searchTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(initiateSearchForLocation), userInfo: nil, repeats: false)
        } else {
            DataManager.sharedInstance.cancelSearchLocationServiceCall()
            locationArray.removeAll()
            self.tableView.reloadData()
        }
    }
    
    func initiateSearchForLocation() {
        let progressHUD = MBProgressHUD.showAdded(to: self.tableView, animated: true)
        let serivceSuccessHandlerInVC : ([Location])->Void = {
            [weak self] (locationArray:[Location])  in
            self?.locationArray = locationArray
            self?.tableView.reloadData()
            progressHUD.removeFromSuperview()
        }
        
        let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
            (errorValue:Any)  in
            progressHUD.removeFromSuperview()
            print(errorValue)
            if let errorMessage = errorValue as? String {
                self.searchController.isActive = false
                AlertManager.sharedInstance.show(title: "Failed", message: errorMessage, fromVC: self)
            } else if let error = errorValue as? Error {
                if error.localizedDescription != "cancelled" {
                    self.searchController.isActive = false
                    AlertManager.sharedInstance.show(title: "Error", message: error.localizedDescription, fromVC: self)
                }
            } else {
                self.searchController.isActive = false
                AlertManager.sharedInstance.show(title: "Error", message: "Something went wrong. Please try again later.", fromVC: self)
            }
        }
        
        DataManager.sharedInstance.searchLocationServiceCall(searchString!,serviceSuccessHandler: serivceSuccessHandlerInVC,serviceFailureHnadler: serviceFailureHandlerInVC)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return locationArray.count
        }
        return locationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.textLabel!.text = locationArray[indexPath.row].locationText
        } else {
            cell.textLabel!.text = locationArray[indexPath.row].locationText
        }
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont(name: "Montserrat-Regular", size: 12)
        cell.textLabel?.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor(red: 0/255, green: 0/255, blue: 51/255, alpha: 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = locationArray[indexPath.row]
        if location.locationID != "0" {
            self.delegate?.locationSearchResultsViewControllerDidSelectLocation(vc: self, location: locationArray[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor(red: 155/255, green: 217/255, blue: 248/255, alpha: 1)
        cell?.backgroundColor = UIColor(red: 155/255, green: 217/255, blue: 248/255, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.clear
        cell?.backgroundColor = UIColor.clear
    }
    
    // MARK: - Keyboard Management
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            let tableViewBottomSpace = UIScreen.main.bounds.size.height - (tableView.frame.origin.y + tableView.frame.size.height)
            tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight-tableViewBottomSpace, 0)
            tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight-tableViewBottomSpace, 0)
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            // For some reason adding inset in keyboardWillShow is animated by itself but removing is not, that's why we have to use animateWithDuration here
            self.tableView.contentInset = UIEdgeInsets.zero
            self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
        })
    }
}

extension LocationSearchResultsViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchEditingChanged(searchStr: searchBar.text!)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
}

extension LocationSearchResultsViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        searchEditingChanged(searchStr: searchController.searchBar.text!)
    }
}

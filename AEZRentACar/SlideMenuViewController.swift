//
//  SlideMenuViewController.swift
//  Advantage
//
//  Created by macbook on 6/20/18.
//  Copyright © 2018 Anjali Panjawani. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

class SlideMenuViewController: UIViewController {
    //Declaration:
    
    @IBOutlet weak var useNameLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var menuTableView: UITableView!
    var slideMenuArray = [SlideMenu]()
    var isGuestUser : Bool = false
    //var loginDataSouce = LoginViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
      //
        menuTableView.tableFooterView = UIView(frame: .zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userinfo), name: Notification.Name("loginSucess"), object: nil)
        


        var slidemenuObjcet = SlideMenu()
        
      
        slidemenuObjcet.id = "1"
        slidemenuObjcet.description = "Find a Car"
        slideMenuArray.append(slidemenuObjcet)
        
        slidemenuObjcet.id = "2"
        slidemenuObjcet.description = "My Reservations"
        slideMenuArray.append(slidemenuObjcet)
        
        slidemenuObjcet.id = "3"
        slidemenuObjcet.description = "Logout"
        slideMenuArray.append(slidemenuObjcet)

       
        print(slideMenuArray.count)
        
       
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
     
        loginButton.isHidden = false
        isGuestUser = true
        useNameLabel.text = "Welcome Guest"
        if UserDefaults.standard.object(forKey: "loggedInUserLoyaltyStatus") != nil {
            isGuestUser = false
            loginButton.isHidden = true
        }
        
        if isGuestUser {
             UserDefaults.standard.removeObject(forKey: "FirstName")
        }
        
        if let firstName = UserDefaults.standard.object(forKey: "FirstName") {
            // login
            useNameLabel.text = "Welcome \(firstName)"
        }
        else{
            //not login
            useNameLabel.text = "Welcome Guest"
        }
        
       
        self.menuTableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func userinfo(notification: NSNotification){
        let firstName = notification.object as? String
        
        UserDefaults.standard.set(firstName, forKey: "FirstName")
       
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        hideContentController(content: self)
         let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
         
        let loginViewController = storyBoard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(loginViewController, animated:true, completion:nil)
        
    }
    func logoutButtonTapped() {
    var message = "The reservation data will be lost once you logout.\nAre you sure you want to continue?"
    if self.isMember(of: ReservationConfirmationViewController.self) {
    message = "Are you sure you want to continue?"
    }
    
    let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (UIAlertAction) in
    }
    alertController.addAction(cancelAction)
    
    let defaultAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
    self.serverLogoutUser()
    }
    alertController.addAction(defaultAction)
    
    self.present(alertController, animated: true, completion: nil)
    }
    
    func serverLogoutUser() {
        var progressHUD = MBProgressHUD()
        if let navigation = self.navigationController {
            print(self.navigationController?.view)
            
            progressHUD = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
            
        }else{
            //side menu logout:
            progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        let serivceSuccessHandlerInVC : (_ responseValue:Any) -> Void = {
            [weak self] (responseValue: Any)  in
            progressHUD.removeFromSuperview()
            DispatchQueue.main.async {
                self?.clearUserPrefereces()
                
                
                self?.isGuestUser = true

                self?.hideContentController(content: self!)

            }
        }
        
        let serviceFailureHandlerInVC : (_ errorValue:Any) -> Void = {
            (errorValue:Any)  in
            progressHUD.removeFromSuperview()
            self.clearUserPrefereces()
        }
        
        if let emailAddress = UserDefaults.standard.string(forKey: "loggedInUserEmailAddress"), let accessToken = UserDefaults.standard.string(forKey: "access_token") {
            DataManager.sharedInstance.postLogoutCall(accessToken: accessToken, email: emailAddress, serviceSuccessHandler: serivceSuccessHandlerInVC, serviceFailureHnadler: serviceFailureHandlerInVC)
        } else {
            clearUserPrefereces()
        }
    }
    
    func clearUserPrefereces() {
        UserDefaults.standard.set(nil, forKey: "access_token")
        UserDefaults.standard.set(nil, forKey: "memberNumber")
        UserDefaults.standard.set(nil, forKey: "loggedInUserEmailAddress")
        UserDefaults.standard.set(nil, forKey: "loggedInUserLoyaltyStatus")
        
        UserDefaults.standard.removeObject(forKey: "loggedInUserLoyaltyStatus")

        
        UserDefaults.standard.removeObject(forKey: "FirstName")
        UserDefaults.standard.removeObject(forKey: "loggedInUserLoyaltyStatus")
        
        
       // UserDefaults.standard.removeObject(forKey: "preferredRentalLocationCode")
       // UserDefaults.standard.removeObject(forKey: "preferredReturnLocationCode")
      
        
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Logout"), object: nil);
        
        UserDefaults.standard.synchronize()
        
        
    }
    @IBAction func closeAction(_ sender: Any) {
        
        hideContentController(content: self)
    }
    
    func hideContentController(content: UIViewController) {
        UIView.transition(with: content.view,
         duration:0.6,
         options:UIViewAnimationOptions.curveEaseOut,
         animations: {
         // do something
         }, completion:{
         finished in
        
            content.willMove(toParentViewController: nil)
            content.view.removeFromSuperview()
            content.removeFromParentViewController()
         })
 
        
      
 
        //Animation:
        /*
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.layer.add(transition, forKey: nil)
         */
        /*
        //Code
        
         content.willMove(toParentViewController: nil)
         content.view.removeFromSuperview()
         content.removeFromParentViewController()
 
         */

       
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SlideMenuViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isGuestUser {
            //NOT LOGIN
            return slideMenuArray.count - 1
        }else{
            //LOGIN
            return slideMenuArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text  = slideMenuArray[indexPath.row].description
        return cell!

       
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1 {
            hideContentController(content: self)

            //View  Reservations
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let viewReservationsViewController = storyBoard.instantiateViewController(withIdentifier: "ViewReservationsViewController") as! ViewReservationsViewController
            self.present(viewReservationsViewController, animated:true, completion:nil)
            
        }
        if indexPath.row == 2 {
            //logout Button
            if (NetworkReachabilityManager()?.isReachable)! {
                self.logoutButtonTapped()

            
            }else {
                AlertManager.sharedInstance.show(title: "Error", message: "The Internet connection appears to be offline.", fromVC: self)
            }

           
        }else{
            //find a car:
            hideContentController(content: self)

        }

    }
    
}


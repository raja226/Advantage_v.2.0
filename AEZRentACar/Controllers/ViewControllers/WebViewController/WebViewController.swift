//
//  WebViewController.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 4/26/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit

protocol WebViewControllerDelegate {
    func webViewControllerDidSelectAgree()
    func webViewControllerDidSelectCancel()
}

class WebViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var constraintContainerViewTopSpace: NSLayoutConstraint!
    
    var delegate: WebViewControllerDelegate?
    
    var pageTitle: String = ""
    var webURLLink: String = ""
    var pageDescription: String = ""
    var shouldShowWebView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.containerView.layer.cornerRadius = 10
        self.containerView.clipsToBounds = true
        self.textView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.pageTitleLabel.text = self.pageTitle
        if shouldShowWebView {
            self.webView.isHidden = false
            self.webView.scalesPageToFit = false
            self.textView.isHidden = true
            if self.webURLLink.isEmpty == false {
                self.webView.loadRequest(URLRequest(url: URL(string: self.webURLLink)!))
            } else {
                self.webView.loadHTMLString(self.pageDescription, baseURL: nil)
            }
        } else {
            self.webView.isHidden = true
            self.textView.isHidden = false
            self.textView.text = self.pageDescription
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss()
    }
    
    @IBAction func iAgreeButtonTapped(_ sender: Any) {
        self.delegate?.webViewControllerDidSelectAgree()
        dismiss()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.delegate?.webViewControllerDidSelectCancel()
        dismiss()
    }
    
    func dismiss() {
        self.performSegue(withIdentifier: "webViewUnwindSegue", sender: self)
    }
}

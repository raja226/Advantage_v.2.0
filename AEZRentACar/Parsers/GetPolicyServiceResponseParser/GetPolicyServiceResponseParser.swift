//
//  GetPolicyServiceResponseParser.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 5/24/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import UIKit
import SwiftyJSON

class GetPolicyServiceResponseParser: NSObject {
    func parseGetPolicyServiceResponse(responseData: Any) -> (success: Bool, message: String?, policyHTMLString:String?)  {
        print("parseGetPolicyServiceResponse")
        let responseInJSON = JSON(responseData)
        let status = responseInJSON["status"]
        if status == "success" {
            var policyHTMLString = ""
            let policyList = responseInJSON["policy_text"].array
            for policyInfo in policyList! {
                for subPolicyInfo in policyInfo {
                    policyHTMLString = policyHTMLString.appending("*****\(subPolicyInfo.0) POLICY*****<br>")
                    policyHTMLString = policyHTMLString.appending(subPolicyInfo.1.string!)
                    policyHTMLString = policyHTMLString.appending("<br><br>")
                }
            }
            print("Policy String : \(policyHTMLString)")
            policyHTMLString = "<font face='Montserrat' size='2' color='666666'> \(policyHTMLString)"
            return (success: true, message: nil, policyHTMLString:policyHTMLString)
        } else {
            let message = responseInJSON["error"]["errorMessage"].string!
            return (success: false, message: message, policyHTMLString:nil)
        }
    }
}

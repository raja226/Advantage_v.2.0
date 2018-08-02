//
//  GetUSStatesServiceResponseParser.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/24/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import SwiftyJSON

class GetUSStatesServiceResponseParser: NSObject {
    func parseUSStatesServiceResponse(usstates: Any) -> (success: Bool, stateList: [USState])  {
        var usStatesArray:[USState] = []
        print("parseUSStateServiceResponse")
        let usstatesJSON = JSON(usstates)
        let status = usstatesJSON["status"]
        if status == "success" {
            for state:(String, JSON) in usstatesJSON {
                if state.0 == "status" {
                    continue
                }
                //Do something you want
                print(state)
                usStatesArray.append(USState(stateData: state))
            }
            usStatesArray = usStatesArray.sorted { $0.stateName < $1.stateName }
            return (success: true, stateList: usStatesArray)
        } else {
            return (success: false, stateList: usStatesArray)
        }
    }
}

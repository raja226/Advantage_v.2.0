//
//  USState.swift
//  AEZRentACar
//
//  Created by Ishan Malviya on 4/24/17.
//  Copyright © 2017 Cybage. All rights reserved.
//

import SwiftyJSON

class USState {

    var stateCode: String
    var stateName: String

    init(stateData: (String, JSON)) {
        self.stateCode = stateData.0
        self.stateName = stateData.1.string!
    }
    
}





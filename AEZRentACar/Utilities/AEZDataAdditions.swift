//
//  AEZDataAdditions.swift
//  AEZRentACar
//
//  Created by Bhushan Biniwale on 8/14/17.
//  Copyright © 2017 Anjali Panjawani. All rights reserved.
//

import Foundation

extension Data {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

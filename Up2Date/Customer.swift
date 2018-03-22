//
//  Customer.swift
//  Up2Date
//
//  Created by Brandon Stokes on 6/28/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import Foundation


class Customer {
    
    private var customerKey: String!
    private var email: String!
    private var currentUp2s: [String]!
    private var previousUp2s: [String]!
    
    var _customerKey: String {
        return customerKey
    }
    var _email: String {
        return email
    }
    var _currentUp2s: [String] {
        return currentUp2s
    }
    
    var _previousUp2s: [String] {
        return previousUp2s
    }
    
    init(key: String, dictionary: [String: Any]) {
        self.customerKey = key
        
        if let _email = dictionary["email"] as? String {
            self.email = _email
        }
        if let _currentUp2s = dictionary["currentUp2s"] as? [String] {
            self.currentUp2s = _currentUp2s
        }
        if let _previousUp2s = dictionary["previousUp2s"] as? [String] {
            self.previousUp2s = _previousUp2s
        }
    }
}

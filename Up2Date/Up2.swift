//
//  Up2.swift
//  Up2Date
//
//  Created by Brandon Stokes on 9/6/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import Foundation
import UIKit


class Up2 {
    
    private var nameId: String!
    private var name: String!
    private var address: String!
    private var city: String!
    private var state: String!
    private var zip: String!
    private var area: String!
    private var imageURL: String!
    private var description: String!
    private var type: String!
    private var category: String!
    private var discount: String!
    private var priceRange: String!
    private var clicks: Int!
    private var purchases: Int!
    private var rating: Double!
    private var website: String!
    private var status: String!
    
    var distance: Double = 0
    //var image = UIImage(named: "Logo and Verbage")
    
    
    var _nameId: String {
        return nameId
    }
    var _name: String {
        return name
    }
    var _address: String {
        return address
    }
    var _city: String {
        return city
    }
    var _state: String {
        return state
    }
    var _zip: String {
        return zip
    }
    var _area: String {
        return area
    }
    var _imageURL: String {
        return imageURL
    }
    var _description: String {
        return description
    }
    var _type: String {
        return type
    }
    var _category: String {
        return category
    }
    var _discount: String {
        return discount
    }
    var _priceRange: String {
        return priceRange
    }
    var _clicks: Int {
        return clicks
    }
    var _purchases: Int {
        return purchases
    }
    var _rating: Double {
        return rating
    }
    
    var _website: String {
        return website
    }
    
    var _status: String {
        return status
    }
    
    init(nameId: String, dictionary: [String: Any]) {
        self.nameId = nameId
        
        if let _name = dictionary["name"] as? String {
            self.name = _name
        }
        if let _address = dictionary["address"] as? String {
            self.address = _address
        }
        if let _city = dictionary["city"] as? String {
            self.city = _city
        }
        if let _state = dictionary["state"] as? String {
            self.state = _state
        }
        if let _zip = dictionary["zip"] as? String {
            self.zip = _zip
        }
        if let _area = dictionary["area"] as? String {
            self.area = _area
        }
        if let _imageURL = dictionary["imageURL"] as? String {
            self.imageURL = _imageURL
        }
        if let _description = dictionary["description"] as? String {
            self.description = _description
        }
        if let _type = dictionary["type"] as? String {
            self.type = _type
        }
        if let _category = dictionary["category"] as? String {
            self.category = _category
        }
        if let _discount = dictionary["discount"] as? String {
            self.discount = _discount
        }
        if let _priceRange = dictionary["priceRange"] as? String {
            self.priceRange = _priceRange
        }
        if let _clicks = dictionary["clicks"] as? Int {
            self.clicks = _clicks
        }
        if let _purchases = dictionary["purchases"] as? Int {
            self.purchases = _purchases
        }
        if let _rating = dictionary["rating"] as? Double {
            self.rating = _rating
        }
        if let _website = dictionary["website"] as? String {
            self.website = _website
        }
        if let _status = dictionary["status"] as? String {
            self.status = _status
        }
    }
    
}

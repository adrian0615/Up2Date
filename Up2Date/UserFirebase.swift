//
//  UserFirebase.swift
//  Up2Date
//
//  Created by Brandon Stokes on 9/6/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import Foundation
import FirebaseDatabase


class UserFirebase {
    
    private var _USER_REF = FIRDatabase.database().reference().child("customers(iOS)")
    
    var USER_REF: FIRDatabaseReference {
        return _USER_REF
    }
}

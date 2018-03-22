//
//  Up2Firebase.swift
//  Up2Date
//
//  Created by Brandon Stokes on 9/6/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Up2Firebase {
    
    private var _UP2_REF = FIRDatabase.database().reference().child("up2s")
    
    var UP2_REF: FIRDatabaseReference {
        return _UP2_REF
    }
}

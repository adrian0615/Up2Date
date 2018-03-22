//
//  ConfirmationViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 9/22/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ConfirmationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var up2Firebase = Up2Firebase()
    var userFirebase = UserFirebase()
    var newCustomerRef: FIRDatabaseReference?
    var customerRef: FIRDatabaseReference?
    var firebaseEmailRef = UserDefaults.standard.string(forKey: "FirebaseRef")
    var customerId = UserDefaults.standard.string(forKey: "CustomerId")
    var last4 = UserDefaults.standard.string(forKey: "last4")
    var up2NameIds: [String]? = nil
    var up2Names: [String]? = nil
    var totals: [String]? = nil
    var confirmation: String? = nil
    var card: String? = nil
    var userExists = false
    var email = UserDefaults.standard.string(forKey: "email")
    
    
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var chargedLabel: UILabel!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var confirmationLabel: UILabel!
    
    @IBAction func myUp2sButtonTapped(_ sender: Any) {
        print("MyUp2 Button Tapped")
        
        //Need to append up2sNameIds somehow to user data
        UserDefaults.standard.set(up2NameIds, forKey: "myUp2NameIds")
        
        let myTabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "MyTabBarViewController") as! MyTabBarViewController
        
        self.present(myTabBarVC, animated: true, completion: nil)
        return
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Confirmation"
        
        if email != nil {
            email?.removeLast(4)
        }
        
        up2NameIds = UserDefaults.standard.array(forKey: "cart") as? [String]
        up2Names = UserDefaults.standard.array(forKey: "cartNames") as? [String]
        totals = UserDefaults.standard.array(forKey: "totalsString") as? [String]
        card = UserDefaults.standard.string(forKey: "last4")
        confirmation = UserDefaults.standard.string(forKey: "confirmation")
        
        //addCustomerIDtoFirebase()
        addCurrentUp2s()
        
        if totals!.count < 2 {
            chargedLabel?.text = "Charged: $1.99"
        } else {
            chargedLabel?.text = "Charged: $2.99"
        }
        
        UserDefaults.standard.set(nil, forKey: "cart")
        UserDefaults.standard.set(nil, forKey: "cartNames")
        UserDefaults.standard.set(nil, forKey: "totalsString")
        UserDefaults.standard.set(nil, forKey: "last4")
        UserDefaults.standard.set(nil, forKey: "confirmation")
        UserDefaults.standard.set(false, forKey: "cartHasItems")
        
        
        if card != nil {
            cardLabel.text = "To Card Ending in \(card!)"
        }
        
        confirmationLabel.text = "Successful Payment"
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        cartTableView.delegate = self
        cartTableView.dataSource = self
        
        
    }
    
    func addCustomerIDtoFirebase() {
        
        if firebaseEmailRef == nil {
            customerRef = userFirebase.USER_REF.child(email!)
        } else {
            self.customerRef = userFirebase.USER_REF.child(firebaseEmailRef!)
        }
        let customerIdRef = customerRef?.child("customerId")
        customerIdRef?.setValue(customerId!)
        
        let last4Ref = customerRef?.child("last4")
        last4Ref?.setValue(last4!)
    }
    
    
    func addCurrentUp2s() {
        userFirebase.USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // The snapshot is a current look at our customers data.
            
            print(String(describing: snapshot.value))
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let postDictionary = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        
                        if snap.key == self.email {
                            self.userExists = true
                            
                            let customer = Customer(key: key, dictionary: postDictionary)
                            print(customer)
                            var newUp2NameIds = customer._currentUp2s
                            newUp2NameIds.append(contentsOf: self.up2NameIds!)
                            print(newUp2NameIds)
                            self.userFirebase.USER_REF.child(key).updateChildValues(["currentUp2s": newUp2NameIds])
                            UserDefaults.standard.set(newUp2NameIds, forKey: "currentUp2s")
                            return
                        }
                    }
                }
            }
        })
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //} else if up2Strings != nil && totals != nil {
        // return up2Strings!.count
        
        if up2Names != nil && totals != nil {
            return up2Names!.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as! CartTableViewCell
        
        if (up2Names != nil) && (totals != nil) && (totals! != []) {
            cell.nameLabel.text = up2Names?[indexPath.row]
            cell.amountLabel.text = totals?[indexPath.row]
        }
        
        return cell
    }
    
}

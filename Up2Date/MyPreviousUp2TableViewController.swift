//
//  MyPreviousUp2TableViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 8/8/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MyPreviousUp2TableViewController: UITableViewController {

    let array: [String] = [UserDefaults.standard.string(forKey: "first") ?? "one", UserDefaults.standard.string(forKey: "second") ?? "two"]
    
    var myUp2NameIds: [String]? = nil
    var up2s = [Up2]()
    var up2Firebase = Up2Firebase()
    var userFirebase = UserFirebase()
    var email = UserDefaults.standard.string(forKey: "email")
    var customerExists = false
    
    func homeButtonTapped(_ sender: UIBarButtonItem) {
        print("Back Button Tapped")
        let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        
        self.present(tabBarVC, animated: true, completion: nil)
        return
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Previous"
        
        if email != nil {
            email?.removeLast(4)
        }
        
        checkForCustomer()
        

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title:
            "Home", style: .plain, target: self, action:
            #selector(homeButtonTapped))
        
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func displayMyAlertMessage(userMessage: String) {
        
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        myAlert.addAction(action)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
    func checkForCustomer() {
        userFirebase.USER_REF.observe(.value, with: { (snapshot) in
            
            // The snapshot is a current look at our customers data.
            
            print(String(describing: snapshot.value))
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let postDictionary = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        
                        if snap.key == self.email {
                            self.customerExists = true
                            let customer = Customer(key: key, dictionary: postDictionary)
                            self.myUp2NameIds = customer._previousUp2s
                            self.createUp2s(customerExists: self.customerExists)
                        }
                    }
                }
            }
        })
    }
    
    func createUp2s(customerExists: Bool) {
        if customerExists == true {
            up2Firebase.UP2_REF.observe(.value, with: { (snapshot) in
                
                self.up2s = []
                // The snapshot is a current look at our up2s data.
                print(String(describing: snapshot.value))
                
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    
                    for snap in snapshots {
                        
                        if let postDictionary = snap.value as? Dictionary<String, Any> {
                            let key = snap.key
                            let up2 = Up2(nameId: key, dictionary: postDictionary)
                            
                            if self.myUp2NameIds?.contains(up2._nameId) == true {
                                self.up2s.append(up2)
                                print(self.up2s)
                            } else {
                            }
                        }
                    }
                    
                }
                // Be sure that the tableView updates when there is new data.
                self.tableView.reloadData()
            })
        } else {
            up2s = []
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return up2s.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyUp2TableViewCell", for: indexPath) as! MyUp2TableViewCell
        
        cell.textLabel?.text = up2s[indexPath.row]._name
        cell.textLabel?.textColor = UIColor.red
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        detailVC.up2 = up2s[indexPath.row]
        
        self.navigationController?.pushViewController(detailVC, animated:
            true)
    }

}

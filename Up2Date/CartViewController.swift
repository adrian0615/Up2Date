//
//  CartViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 8/30/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var up2NameIds: [String]? = nil
    var up2Names: [String]? = nil
    var firstUp2: Up2? = nil
    var secondUp2: Up2? = nil
    var up2s: [Up2]? = nil
    var totals: [String]? = nil
    var up2Firebase = Up2Firebase()

    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var cartTableView: UITableView!
    
    @IBAction func loginRegisterButtonTapped(_ sender: Any) {
        let loginNavVC = self.storyboard!.instantiateViewController(withIdentifier: "LoginNavigationController") as! UINavigationController
        
        self.present(loginNavVC, animated: true, completion: nil)
        
    }
    
    func homeButtonTapped(_ sender: UIBarButtonItem) {
        print("Home Button Tapped")
        let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        
        self.present(tabBarVC, animated: true, completion: nil)
        return
    }
    
    func emptyButtonTapped(_ sender: UIBarButtonItem) {
        print("Empty Button Tapped")
        
        UserDefaults.standard.set(nil, forKey: "cart")
        UserDefaults.standard.set(nil, forKey: "cartNames")
        UserDefaults.standard.set(nil, forKey: "totalsString")
        UserDefaults.standard.set(false, forKey: "cartHasItems")
        up2NameIds = []
        up2Names = []
        totals = []
        up2s = []
        
        totalAmountLabel?.text = "$0.00" 
        
        cartTableView.reloadData()
        
        return
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cart"
        
        if UserDefaults.standard.array(forKey: "cart") != nil {
            up2NameIds = UserDefaults.standard.array(forKey: "cart") as? [String]
            up2Names = UserDefaults.standard.array(forKey: "cartNames") as? [String]
            
            totals = UserDefaults.standard.array(forKey: "totalsString") as? [String]
            
            if up2NameIds!.count == 1 {
                totalAmountLabel?.text = "$1.99"
            } else if up2NameIds!.count == 2  {
                totalAmountLabel?.text = "$2.99"
            }
            getUp2()
        }
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(homeButtonTapped))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Empty", style: .plain, target: self, action: #selector(emptyButtonTapped))
        
        navigationController?.navigationBar.tintColor = UIColor.white
        

        cartTableView.delegate = self
        cartTableView.dataSource = self
        
    }
        
    func getUp2() {
        up2Firebase.UP2_REF.observe(.value, with: { (snapshot) in
            
            // The snapshot is a current look at our clients data.
            
            print(String(describing: snapshot.value))
            
            self.up2s = []
            
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our up2 array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        
                        
                        let up2 = Up2(nameId: key, dictionary: postDictionary)
                        
                        for nameId in self.up2NameIds! {
                            if up2._nameId == nameId {
                                self.up2s?.insert(up2, at: 0)
                                print(self.up2s!)
                            }
                        }
                    }
                }
                
            }
            self.cartTableView.reloadData()
        })
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if up2s != nil && totals != nil {
            return up2s!.count
        } else if up2NameIds != nil {
            return up2NameIds!.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as! CartTableViewCell
        
        if up2s != nil && totals != nil && up2s?.count != 0 && totals?.count != 0{
            let up2 = up2s![indexPath.row]
            let amount = totals![indexPath.row]
            cell.configureCell(up2: up2, amount: amount)
        } else {
            cell.nameLabel.text = up2Names?[indexPath.row]
            cell.amountLabel.text = totals?[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if up2s != nil {
            
            let detailVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            
            detailVC.up2 = up2s?[indexPath.row]
            self.navigationController?.pushViewController(detailVC, animated: true)
            
        }
    }

}

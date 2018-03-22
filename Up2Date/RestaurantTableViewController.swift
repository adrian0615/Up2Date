//
//  RestaurantTableViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 7/26/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import GameKit
import CoreLocation
import FirebaseDatabase
import FirebaseStorage

class RestaurantTableViewController: UITableViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var shoppingCartButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var neighborhood: String = "Johns Creek▾"
    
    var up2Firebase = Up2Firebase()
    var up2Image: UIImage? = nil
    var restaurants: [Up2] = []
    var distance = ""
    var distanceInMiles: Double = 0
    var distances: [String] = []
    var userLocation: CLLocation? = nil
    var haveInternet = false
    var internetCheck = InternetCheck()
    static var instance: RestaurantTableViewController?

    @IBAction func shoppingCartButtonTapped(_ sender: Any) {
        
        if UserDefaults.standard.string(forKey: "email") != nil {
            let paymentNavVC = self.storyboard!.instantiateViewController(withIdentifier: "PaymentNavigationController") as! UINavigationController
            
            self.navigationController?.present(paymentNavVC, animated:
                true)
        } else {
            let cartNavVC = self.storyboard!.instantiateViewController(withIdentifier: "CartNavigationController") as! UINavigationController
            
            self.navigationController?.present(cartNavVC, animated:
                true)
        }

        return
    }
    @IBAction func searchButonTapped(_ sender: Any) {
        let restaurantTypeTableVC = self.storyboard!.instantiateViewController(withIdentifier: "RestaurantTypeTableViewController") as! RestaurantTypeTableViewController
        self.navigationController?.pushViewController(restaurantTypeTableVC, animated: true)
        return
    }
    @IBAction func menuButtonTapped(_ sender: Any) {
        /*let myAlert = UIAlertController(title: "Menu", message: nil, preferredStyle: .alert)
        let myUp2Action = UIAlertAction(title: "My Up2's", style: .default, handler: myUp2)
        let typeAction = UIAlertAction(title: "Search By Cuisine Type", style: .default, handler: typeSearch)
        let accountAction = UIAlertAction(title: "Account", style: .default, handler: account)
        let supportAction = UIAlertAction(title: "Support", style: .default, handler: support)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        myAlert.addAction(myUp2Action)
        myAlert.addAction(typeAction)
        myAlert.addAction(accountAction)
        myAlert.addAction(supportAction)
        myAlert.addAction(cancelAction)
        
        self.present(myAlert, animated: true, completion: nil)*/
    }
    
    func myUp2(_ sender: UIAlertAction) {
        print("myUp2 Button Tapped")
        let myTabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "MyTabBarViewController") as! MyTabBarViewController
        self.present(myTabBarVC, animated: true, completion: nil)
        return
    }
    
    func account(_ sender: UIAlertAction) {
        print("Account Button Tapped")
    }
    
    func support(_ sender: UIAlertAction) {
        print("Support Button Tapped")
    }
    
    func locationButtonTapped(_ sender: UIBarButtonItem) {
        print("Location Button Tapped")
        let areaVC = self.storyboard!.instantiateViewController(withIdentifier: "AreaViewController") as! AreaViewController
        self.navigationController?.pushViewController(areaVC, animated:
            true)
        return
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Search Button
        //searchButton.customView?.isHidden = true
        //searchButton.isEnabled = false
        
        haveInternet = internetCheck.isInternetAvailable()
        
        if haveInternet == true {
            getRestaurants()
        } else {
            displayNoInternet()
        }
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if UserDefaults.standard.string(forKey: "neighborhood") != nil {
            title = UserDefaults.standard.string(forKey: "neighborhood")!
        }
        
        self.navigationItem.backBarButtonItem?.title = "Back"
        
        if UserDefaults.standard.bool(forKey: "cartHasItems") == true {
            shoppingCartButton.isEnabled = true
            shoppingCartButton.customView?.isHidden = false
        } else {
            shoppingCartButton.isEnabled = false
            shoppingCartButton.customView?.isHidden = true
        }

        if UserDefaults.standard.double(forKey: "latitude") != 0 && UserDefaults.standard.double(forKey: "longitude") != 0 {
            let lat = UserDefaults.standard.double(forKey: "latitude")
            let long = UserDefaults.standard.double(forKey: "longitude")
            userLocation = CLLocation(latitude: lat, longitude: long)
        }
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        if userLocation != nil {
//            restaurants.sort { $0.distance < $1.distance }
//            update()
//        }
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        if userLocation != nil {
//            restaurants.sort { $0.distance < $1.distance }
//            update()
//        }
//    }
    
    func getRestaurants() {
        
        up2Firebase.UP2_REF.observe(.value, with: { (snapshot) in
            
            // The snapshot is a current look at our clients data.
            print(String(describing: snapshot.value))
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our up2 array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let up2 = Up2(nameId: key, dictionary: postDictionary)
                        
                        if up2._type == "restaurant" && up2._status == "active" {
                            self.getDistance(address: "\(up2._address), \(up2._city), \(up2._state), \(up2._zip)", up2: up2)
                            
                            if self.userLocation == nil {
                                self.restaurants.append(up2)
                                
//                                if self.restaurants.count != 0 {
//                                    self.restaurants = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self.restaurants) as! [Up2]
//                                }
                            }
                            
                        }
                    }
                }
                
            }
            // Be sure that the tableView updates when there is new data.
            self.update()
        })
    }
    
    func getDistance(address: String, up2: Up2) {
        
        if userLocation != nil {
            
            CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
                if error != nil {
                    print(error ?? Error.self)
                    return
                }
                if (placemarks?.count)! > 0 {
                    let placemark = placemarks?[0]
                    let location = placemark?.location
                    if location != nil {
                        let coordinate = CLLocation(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
                        let distanceInMeters = coordinate.distance(from: self.userLocation!)
                        self.distance = String(distanceInMeters / 1609)
                        self.distanceInMiles = distanceInMeters / 1609
                        up2.distance = self.distanceInMiles
                        
                        self.restaurants.append(up2)
                        
                        if self.distance != "" {
                            self.distances.append("\(String(self.distance.prefix(4))) miles")
                            print(self.distances)
                            self.update()
                        }
                    }
                    
                } else {
                    print("Can't find Address")
                }
            })
        }
        return
    }
    
    func update() {
        
        OperationQueue.main.addOperation {
            self.tableView.reloadData()
            return
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        OperationQueue.main.addOperation {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            return
        }
    }

    func displayNoInternet() {
        
        let myAlert = UIAlertController(title: "Alert", message: "No Internet Connection.  Please Try Again Later", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
        
        return
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurants.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell", for: indexPath) as! RestaurantTableViewCell
        
        if restaurants.count != 0 {
            let up2 = restaurants[indexPath.row]
            OperationQueue.main.addOperation {
                cell.configureCell(up2: up2)
                return
            }
            up2Image = cell.restaurantImage.image
            
            if distances != [] && distances.count == restaurants.count {
                //cell.distanceLabel.text = "\(String(String(up2.distance).prefix(4))) miles"
                cell.distanceLabel.isHidden = false
            } else {
                cell.distanceLabel.isHidden = true
            }
        }
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        detailVC.up2 = restaurants[indexPath.row]
        
        self.navigationController?.pushViewController(detailVC, animated:
            true)
    }

}

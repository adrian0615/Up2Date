//
//  ActivityTableViewController.swift
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

class ActivityTableViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var shoppingCartButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var neighborhood: String = "Johns Creek▾"

    var up2Firebase = Up2Firebase()
    var up2Image: UIImage? = nil
    var activities: [Up2] = []
    var distance = ""
    var distanceInMiles: Double = 0
    var distances: [String] = []
    var userLocation: CLLocation? = nil
    var haveInternet = false
    var internetCheck = InternetCheck()
    static var instance: ActivityTableViewController?

    
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
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        let activityTypeTableVC = self.storyboard!.instantiateViewController(withIdentifier: "ActivityTypeTableViewController") as! ActivityTypeTableViewController
        self.navigationController?.pushViewController(activityTypeTableVC, animated: true)
        
        return
    }
    @IBAction func menuButtonTapped(_ sender: Any) {
        /*let myAlert = UIAlertController(title: "Menu", message: nil, preferredStyle: .alert)
        let myUp2Action = UIAlertAction(title: "My Up2's", style: .default, handler: myUp2)
        let typeAction = UIAlertAction(title: "Search By Activity Type", style: .default, handler: typeSearch)
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
    
    func locationButtonTapped(_ sender: UIBarButtonItem) {
        print("Location Button Tapped")
        let areaVC = self.storyboard!.instantiateViewController(withIdentifier: "NavViewController") as! NavViewController
        self.navigationController?.present(areaVC, animated:
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
            OperationQueue.main.addOperation {
                self.getActivities()
                if self.userLocation != nil {
                    self.activities.sort { $0.distance < $1.distance }
                    print(self.activities)
                    self.update()
                }
                return
            }
            
            
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
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: neighborhood, style: .plain, target: self, action: #selector(locationButtonTapped))
        
        navigationController?.navigationBar.tintColor = UIColor.white
        //navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "MarkerFelt-Thin", size: 19.0)!], for: .normal)
        
        if UserDefaults.standard.double(forKey: "latitude") != 0 && UserDefaults.standard.double(forKey: "longitude") != 0 {
            let lat = UserDefaults.standard.double(forKey: "latitude")
            let long = UserDefaults.standard.double(forKey: "longitude")
            userLocation = CLLocation(latitude: lat, longitude: long)
        }
        
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
    }
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        if userLocation != nil {
//            activities.sort { $0.distance < $1.distance }
//            update()
//        } 
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        if userLocation != nil {
//            activities.sort { $0.distance < $1.distance }
//            update()
//        }
//    }
    
    func getActivities() {
        up2Firebase.UP2_REF.observe(.value, with: { (snapshot) in
            
            // The snapshot is a current look at our up2s data.
            print(String(describing: snapshot.value))
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    // Make our up2 array for the tableView.
                    
                    if let postDictionary = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        let up2 = Up2(nameId: key, dictionary: postDictionary)
                        
                        if up2._type == "activity" && up2._status == "active" {
                            self.getDistance(address: "\(up2._address), \(up2._city), \(up2._state), \(up2._zip)", up2: up2)
                            
                            if self.userLocation == nil {
                                self.activities.append(up2)
//                                self.activities = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: self.activities) as! [Up2]
                            }
                        }
                    }
                }
                
            }
            //Make sure Activities updates if there is new data
            self.activities.sort { $0.distance < $1.distance }
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
                        
                        self.activities.append(up2)
                        //self.activities.sort { $0.distance < $1.distance }
                        
                        
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
            return activities.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        
        if activities.count != 0 {
            let up2 = activities[indexPath.row]
            OperationQueue.main.addOperation {
                cell.configureCell(up2: up2)
                return
            }
            up2Image = cell.activityImage.image
            
            if distances != [] && distances.count == activities.count {
                cell.distanceLabel.isHidden = false
            } else {
                cell.distanceLabel.isHidden = true
            }
        }

        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            
            detailVC.up2 = activities[indexPath.row]

        self.navigationController?.pushViewController(detailVC, animated:
            true)
    }

}

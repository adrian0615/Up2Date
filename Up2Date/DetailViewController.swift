//
//  DetailViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 8/2/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AddressBookUI
import FirebaseDatabase

class DetailViewController: UIViewController {
    
    var name: String = ""
    var up2: Up2? = nil
    var userFirebase = UserFirebase()
    var up2Strings: [String]? = nil
    var up2Names: [String]? = nil
    var defaultImage: UIImage? = nil
    var currentDeal = false
    var email = UserDefaults.standard.string(forKey: "email")
    var haveInternet = false
    var internetCheck = InternetCheck()
    
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var buyButton: UIButton!
    
    var pointAnnotation:MKPointAnnotation!
    var pinAnnotationView:MKPinAnnotationView!
    
    var latitude: String? = nil
    var longitude: String? = nil
    
    
    @IBAction func mapButtonTapped(_ sender: Any) {
        
        if longitude != nil && latitude != nil {
            
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://?daddr=\(latitude!),\(longitude!)&directionsmode=driving")!)) {
                UIApplication.shared.openURL(URL(string:
                    "comgooglemaps://?daddr=\(latitude!),\(longitude!)&directionsmode=driving")!)
            } else if (UIApplication.shared.canOpenURL(URL(string:"http://maps.apple.com/?daddr=\(latitude!),\(longitude!)&dirflg=d")!)) {
                print("Can't use Google Maps")
                UIApplication.shared.openURL(URL(string:"http://maps.apple.com/?daddr=\(latitude!),\(longitude!)&dirflg=d")!)
                
            } else {
                print("Doesn't have maps app")
                return
            }
        }
    
    }
    
    func yesActionTapped(_ alert: UIAlertAction) {
        
        currentDeal = false
    
        self.updatePreviousUp2s()
        
    }
    
    func okActionTapped(_ alert: UIAlertAction) {
        updateCurrentUp2s()
    }
    
    @IBAction func addToCartTapped(_ sender: Any) {
        if currentDeal == true {
            let myAlert = UIAlertController(title: "Alert", message: "Up2 is to be redemmed in front of cashier or at checkout of service.  Redeem now?", preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "Yes", style: .default, handler: yesActionTapped)
            let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
            myAlert.addAction(yesAction)
            myAlert.addAction(noAction)
            self.present(myAlert, animated: true, completion: nil)
         return
        }
        
        if UserDefaults.standard.array(forKey: "cart")?.count == 2 {
            let myAlert = UIAlertController(title: "Alert: You Can Only Have 2 Discounts in Your Cart", message: "Please purchase items in your cart or clear cart to purchase this discount", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            myAlert.addAction(okAction)
            self.present(myAlert, animated: true, completion: nil)
            return
        } else {
            if up2 != nil {
                
                UserDefaults.standard.set(true, forKey: "cartHasItems")
                
                if UserDefaults.standard.array(forKey: "cart") == nil {
                    UserDefaults.standard.set([up2?._nameId], forKey: "cart")
                    UserDefaults.standard.set([up2?._name], forKey: "cartNames")
                    UserDefaults.standard.set(["$1.99"], forKey: "totalsString")
                } else if UserDefaults.standard.array(forKey: "cart")!.count == 1 {
                    up2Strings = UserDefaults.standard.array(forKey: "cart") as? [String]
                    up2Strings?.append((up2?._nameId)!)
                    UserDefaults.standard.set(up2Strings, forKey: "cart")
                    up2Names = UserDefaults.standard.array(forKey: "cartNames") as? [String]
                    up2Strings?.append((up2?._nameId)!)
                    up2Names?.append((up2?._name)!)
                    UserDefaults.standard.set(up2Names, forKey: "cartNames")
                    UserDefaults.standard.set(["$1.99", "$1"], forKey: "totalsString")
                } else {
                    UserDefaults.standard.set([up2?._nameId], forKey: "cart")
                    UserDefaults.standard.set([up2?._name], forKey: "cartNames")
                    UserDefaults.standard.set(["$1.99"], forKey: "totalsString")
                }
                
                
                if UserDefaults.standard.string(forKey: "email") == nil {
                    
                    let cartNavVC = self.storyboard!.instantiateViewController(withIdentifier: "CartNavigationController") as! UINavigationController
                    
                    self.tabBarController?.present(cartNavVC, animated: true, completion: nil)
                } else {
                    
                    let paymentNavVC = self.storyboard!.instantiateViewController(withIdentifier: "PaymentNavigationController") as! UINavigationController
                    
                    self.navigationController?.present(paymentNavVC, animated:
                        true)
                }
            }
        }
        
    }
    @IBAction func websiteTapped(_ sender: Any) {
       
        if let url = URL(string: (up2?._website)!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                if up2 != nil && up2?._website != "" {
                    let websiteVC = self.storyboard!.instantiateViewController(withIdentifier: "WebsiteViewController") as! WebsiteViewController
                    
                    websiteVC.websiteURL = up2!._website
                    
                    self.navigationController?.pushViewController(websiteVC, animated:
                        true)
                }
            }
        
        }
        
        return
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        pointAnnotation = MKPointAnnotation()
        
        if email != nil {
            email?.removeLast(4)
        }
        
        if up2 != nil {
            detailImageView.downloadedFrom2(link: up2!._imageURL)
            name = up2!._name
            discountLabel.text = up2!._discount
            descriptionTextView.text = "\n\(up2!._description)"
            addressTextView.text = "\(up2!._address), \(up2!._city), \(up2!._state), \(up2!._zip)"
            
            locationMap(address: "\(up2!._address), \(up2!._city), \(up2!._state), \(up2!._zip)")
        }
        
        title = name
        
        //if an item is already in the cart then the second item is discounted to $1
        if UserDefaults.standard.bool(forKey: "cartHasItems") == true {
            buyButton.setTitle("Buy For $1", for: .normal)
        }
        
        if UserDefaults.standard.array(forKey: "cart")?.count == 2 {
            buyButton.setTitle("Buy For $1.99", for: .normal)
        }
        
        if UserDefaults.standard.array(forKey: "cart")?.count == 1 {
            if up2?._nameId == UserDefaults.standard.array(forKey: "cart")?[0] as? String {
               buyButton.isHidden = true
            }
        }
        
        if UserDefaults.standard.array(forKey: "cart")?.count == 2 {
            if up2?._nameId == UserDefaults.standard.array(forKey: "cart")?[0] as? String  || up2?._nameId == UserDefaults.standard.array(forKey: "cart")?[1] as? String {
                buyButton.isHidden = true
            }
            
        }
        
        if UserDefaults.standard.array(forKey: "currentUp2s") != nil {
            let currentUp2s = UserDefaults.standard.array(forKey: "currentUp2s")
            for currentUp2 in currentUp2s! {
                if currentUp2 as? String == up2?._nameId {
                    self.currentDeal = true
                }
            }
        }
        
        if currentDeal == true {
            buyButton.isHidden = false
            buyButton.setTitle("Redeem Up2", for: .normal)
            
        }
        
        
        descriptionTextView.layer.borderColor = UIColor.white.cgColor
        descriptionTextView.layer.borderWidth = 2
    }
    
    
    func updatePreviousUp2s() {
        userFirebase.USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // The snapshot is a current look at our customers data.
            
            print(String(describing: snapshot.value))
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let postDictionary = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        
                        if snap.key == self.email {
                            let customer = Customer(key: key, dictionary: postDictionary)
                            var oldUp2NameIds = customer._previousUp2s
                            oldUp2NameIds.append((self.up2?._nameId)!)
                            self.userFirebase.USER_REF.child(key).updateChildValues(["previousUp2s": oldUp2NameIds])
                            let myAlert = UIAlertController(title: "Up2Date", message: "Up2 Redeemed", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Ok", style: .default, handler: self.okActionTapped)
                            myAlert.addAction(okAction)
                            
                            self.present(myAlert, animated: true, completion: nil)
                        }
                    }
                }
            }
        })
    }
    
    func updateCurrentUp2s() {
        userFirebase.USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // The snapshot is a current look at our customers data.
            
            print(String(describing: snapshot.value))
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let postDictionary = snap.value as? Dictionary<String, Any> {
                        let key = snap.key
                        
                        
                        if snap.key == self.email {
                            let customer = Customer(key: key, dictionary: postDictionary)
                            var newUp2NameIds = customer._currentUp2s
                            if newUp2NameIds.contains(self.up2!._nameId) {
                                let index = newUp2NameIds.index(of: self.up2!._nameId)
                                newUp2NameIds.remove(at: index!)
                            }
                            print(newUp2NameIds)
                            self.userFirebase.USER_REF.child(key).updateChildValues(["currentUp2s": newUp2NameIds])
                            
                            UserDefaults.standard.set(newUp2NameIds, forKey: "currentUp2s")
                            
                            let myTabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "MyTabBarViewController") as! MyTabBarViewController
                            
                            self.present(myTabBarVC, animated: true, completion: nil)
                            return
                        }
                    }
                }
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        self.descriptionTextView.setContentOffset(.zero, animated: false)
        self.addressTextView.setContentOffset(.zero, animated: false)
    }
    
    func locationMap(address: String) {
        
        
        CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print(error ?? Error.self)
                return
            }
            if (placemarks?.count)! > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                
                if coordinate != nil {
                    self.latitude = String(coordinate!.latitude)
                    self.longitude = String(coordinate!.longitude)
                }
                
                self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: coordinate!.latitude, longitude: coordinate!.longitude)
                self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
                self.mapView.centerCoordinate = self.pointAnnotation.coordinate
                self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
                //Need to work on zooming in on map
                let span = MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                let region = MKCoordinateRegion(center: coordinate!, span: span)
                self.mapView.setRegion(region, animated: true)
            } else {
                print("Can't find Address")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

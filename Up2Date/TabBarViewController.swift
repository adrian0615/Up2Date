//
//  TabBarViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 7/26/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import CoreLocation

class TabBarViewController: UITabBarController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    var confirmation: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.cyan, NSFontAttributeName: UIFont(name: "MarkerFelt-Thin", size: 19.0)!], for:.selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white,
                                                          NSFontAttributeName: UIFont(name: "MarkerFelt-Thin", size: 19.0)!], for:.normal)
        
        locationManager.delegate = self
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        
        locationManager.stopUpdatingLocation()
        
        UserDefaults.standard.set(lat, forKey: "latitude")
        UserDefaults.standard.set(long, forKey: "longitude")
        
        
        
        print(long, lat)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        
        return
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

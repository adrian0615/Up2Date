//
//  AccountViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 9/22/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import MessageUI
import Stripe

class AccountViewController: UIViewController {
    
    let backEndAPI = BackEndAPI()
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBAction func supportButtonTapped(_ sender: Any) {
        let mailURL = URL(string: "up2help@up2datemobileapp.com")!
        if UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.openURL(mailURL)
        } else {
            displayMyAlertMessage2(userMessage: "Contact Support at up2help@up2datemobileapp.com")
        }
    }
    
    
    func logOutButtonTapped(_ sender: UIBarButtonItem) {
        print("Log Out Button Tapped")
       displayMyAlertMessage(userMessage: "Are you sure you want to log out?")
    }
    
    func displayMyAlertMessage(userMessage: String) {
        
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: yesActionTapped)
        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
        
        myAlert.addAction(yesAction)
        myAlert.addAction(noAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
        return
        
    }
    
    func displayMyAlertMessage2(userMessage: String) {
        
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func yesActionTapped(_ sender: UIAlertAction) {
        
        UserDefaults.standard.set(nil, forKey: "email")
        UserDefaults.standard.set(nil, forKey: "cart")
        UserDefaults.standard.set(nil, forKey: "cartNames")
        UserDefaults.standard.set(nil, forKey: "totalsString")
        UserDefaults.standard.set(false, forKey: "cartHasItems")
        UserDefaults.standard.set(nil, forKey: "CustomerId")
        UserDefaults.standard.set(nil, forKey: "last4")
        UserDefaults.standard.set(nil, forKey: "FirebaseRef")
        
        let myAlert = UIAlertController(title: "Success", message: "You Are Now Logged Out", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: okActionTapped)
        myAlert.addAction(okAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
        return
    }
    
    func okActionTapped(_ sender: UIAlertAction) {
        let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        self.present(tabBarVC, animated:
        true)
        return
    }
    
    func homeButtonTapped(_ sender: UIBarButtonItem) {
        print("Home Button Tapped")
        let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        
        self.present(tabBarVC, animated: true, completion: nil)
        return
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Account"
        
        emailLabel.text = UserDefaults.standard.string(forKey: "email") ?? ""
        

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutButtonTapped))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(homeButtonTapped))
        
        navigationController?.navigationBar.tintColor = UIColor.white
    }

}

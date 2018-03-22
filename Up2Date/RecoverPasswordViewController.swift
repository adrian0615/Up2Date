//
//  RecoverPasswordViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 12/9/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import FirebaseAuth

class RecoverPasswordViewController: UIViewController {
    
    var email: String? = nil
    var haveInternet = false
    var internetCheck = InternetCheck()
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        if (emailTextField.text?.isEmpty)! {
            
            displayMyAlertMessage(userMessage: "Please Enter Your Email and Password to Login")
            
            return
        }
        
        email = emailTextField.text!
        
        haveInternet = internetCheck.isInternetAvailable()
        
        if haveInternet == true {
            
            FIRAuth.auth()?.sendPasswordReset(withEmail: email!) { error in
                
                if error == nil {
                    print("Reset Sent")
                                        
                    let alertController = UIAlertController(title: "Reset Email Password Sent", message: "If you did not receive the email, please try again.", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: self.goToLogin)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            displayNoInternet()
        }
    }
    
    func goToLogin(_ : UIAlertAction) {
        let loginNavVC = self.storyboard!.instantiateViewController(withIdentifier: "LoginNavigationController") as! UINavigationController
        
        self.present(loginNavVC, animated: true, completion: nil)
    }
    
    func displayMyAlertMessage(userMessage: String) {
        
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        myAlert.addAction(action)
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
    func displayNoInternet() {
        
        let myAlert = UIAlertController(title: "Alert", message: "No Internet Connection.  Please Try Again Later", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
        
        return
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Reset"
        
        displayMyAlertMessage(userMessage: "Please enter your email address to receive an email with instructions for reseting your password")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

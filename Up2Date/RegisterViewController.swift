//
//  RegisterViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 8/30/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {
    
    var email: String? = nil
    var shortEmail: String? = nil
    var password: String? = nil
    var haveInternet = false
    var internetCheck = InternetCheck()
    var userFirebase = UserFirebase()
    var newCustomerRef: FIRDatabaseReference?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordTextFieldTwo: UITextField!
    
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        //If cart has anything in it go to payment view controller else go to home
        
        
        if (emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! || (passwordTextFieldTwo.text?.isEmpty)! {
            
            displayMyAlertMessage(userMessage: "All fields are required")
            
            return
        }
        
        let emailText = emailTextField.text!
        let passwordText = passwordTextField.text!
        let confirmPasswordText = passwordTextFieldTwo.text!
        
        
        if emailText.isValidEmailAddress == false && passwordText.isValidPassword == false {
            displayMyAlertMessage(userMessage: "Please enter a valid email address AND your password must contain a number, and at be at least 8 characters in length")
            return
        }
        
        if emailText.isValidEmailAddress == false && passwordText != confirmPasswordText {
            displayMyAlertMessage(userMessage: "Please enter a valid email address AND your password does not match your confirmation password")
            return
        }
        
        if emailText.isValidEmailAddress == false {
            displayMyAlertMessage(userMessage: "Please enter a valid email address")
            return
        }
        
        if passwordText.isValidPassword == false {
            displayMyAlertMessage(userMessage: "Please enter a password that contains at least one number, and at least 8 characters in length")
            return
        }
        
        if passwordText != confirmPasswordText {
            displayMyAlertMessage(userMessage: "Password and Confirmation Password do not match")
            return
        }
        
        email = emailTextField.text!
        password = passwordTextField.text!
        
        haveInternet = internetCheck.isInternetAvailable()
        
        if haveInternet == true {
            
            FIRAuth.auth()?.createUser(withEmail: email!, password: password!) { (user, error) in
                
                if error == nil {
                    print("You have successfully registered")
                    
                    let userID = FIRAuth.auth()!.currentUser!.uid
                    print(userID)
                    
                    self.createCustomer()
                    
                    UserDefaults.standard.setValue(self.email, forKey: "email")
                    //UserDefaults.standard.setValue(self.password, forKey: "password")
                    
                    //if cart has anything in it.  Go to cart.  Else go home
                    if UserDefaults.standard.bool(forKey: "cartHasItems") == true {
                        let paymentNavVC = self.storyboard!.instantiateViewController(withIdentifier: "PaymentNavigationController") as! UINavigationController
                        self.present(paymentNavVC, animated:
                            true)
                        return
                    } else {
                        let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                        self.present(tabBarVC, animated: true, completion: nil)
                        return
                    }
                    
                    
                } else {
                    
                    let alertController = UIAlertController(title: "Error", message: "\(error!.localizedDescription).  Please login if you are already registered.", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
        } else {
            displayNoInternet()
        }
        
        
    }
    
    func createCustomer() {
        shortEmail = email
        shortEmail!.removeLast(4)
        
        UserDefaults.standard.set(shortEmail!, forKey: "FirebaseRef")
        
        let newCustomer: [String: Any] = ["currentUp2s": ["up2date"], "email": email!, "previousUp2s": ["up2date"]]
        self.newCustomerRef = userFirebase.USER_REF.child(self.shortEmail!)
        self.newCustomerRef?.setValue(newCustomer)
    }
   
    
    func displayMyAlertMessage(userMessage: String) {
        
        OperationQueue.main.addOperation {
            
            let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            myAlert.addAction(action)
            
            self.present(myAlert, animated: true, completion: nil)
            
            return
        }
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Register"

        hideKeyboardWhenTappedAround()
        
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func displayNoInternet() {
        
        let myAlert = UIAlertController(title: "Alert", message: "No Internet Connection.  Please Try Again Later", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
        
        return
        
    }

    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
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

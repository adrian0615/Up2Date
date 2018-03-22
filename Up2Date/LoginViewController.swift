//
//  LoginViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 8/30/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Google
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    var email: String? = nil
    var shortEmail: String? = nil
    var password: String? = nil
    var haveInternet = false
    var internetCheck = InternetCheck()
    var userFirebase = UserFirebase()
    var newCustomerRef: FIRDatabaseReference?
    var customerExists = false
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    func getCustomerCardInfo() {
        userFirebase.USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // The snapshot is a current look at our customers data.
            
            print(String(describing: snapshot.value))
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let postDictionary = snap.value as? Dictionary<String, Any> {
                        
                        if snap.key == self.shortEmail {
                            if postDictionary["customerId"] != nil {
                                let customerId = postDictionary["customerId"] as! String
                                UserDefaults.standard.set(customerId, forKey: "CustomerId")
                            }
                            
                            if postDictionary["last4"] != nil {
                                let last4 = postDictionary["last4"] as! String
                                UserDefaults.standard.set(last4, forKey: "last4")
                            }
                            
                            return
                        }
                    }
                }
            }
        })
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        //If cart has anything in it go to payment view controller else go to home
        
        if (emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! {
            
            displayMyAlertMessage(userMessage: "Please Enter Your Email and Password to Login")
            
            return
        }
        
        email = emailTextField.text!
        password = passwordTextField.text!
        
        haveInternet = internetCheck.isInternetAvailable()
        
        if haveInternet == true {
            
            FIRAuth.auth()?.signIn(withEmail: email!, password: password!) { (user, error) in
                
                self.shortEmail = self.email
                self.shortEmail?.removeLast(4)
                
                if error == nil {
                    print("You have successfully signed in")
                    
                    let userID = FIRAuth.auth()!.currentUser!.uid
                    print(userID)
                    UserDefaults.standard.set(self.email!, forKey: "email")
                    UserDefaults.standard.set(self.shortEmail!, forKey: "FirebaseRef")
                    self.checkForCustomer()
                    
                    
                    
                    
                    
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
    
    
    func checkForCustomer() {
        userFirebase.USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // The snapshot is a current look at our customers data.
            
            print(String(describing: snapshot.value))
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let postDictionary = snap.value as? Dictionary<String, Any> {
                        
                        if snap.key == self.shortEmail {
                            self.customerExists = true
                            if postDictionary["customerId"] != nil {
                                
                                let customerId = postDictionary["customerId"] as! String
                                UserDefaults.standard.set(customerId, forKey: "CustomerId")
                            } else {
                                UserDefaults.standard.set(nil, forKey: "CustomerId")
                            }
                            
                            if postDictionary["last4"] != nil {
                                let last4 = postDictionary["last4"] as! String
                                UserDefaults.standard.set(last4, forKey: "last4")
                            } else {
                                UserDefaults.standard.set(nil, forKey: "last4")
                            }
                            
                            if postDictionary["currentUp2s"] != nil {
                                let currentUp2s = postDictionary["currentUp2s"] as! [String]
                                UserDefaults.standard.set(currentUp2s, forKey: "currentUp2s")
                            }
                            
                            if UserDefaults.standard.bool(forKey: "cartHasItems") == true {
                                let paymentNavVC = self.storyboard!.instantiateViewController(withIdentifier: "PaymentNavigationController") as! UINavigationController
                                
                                self.navigationController?.present(paymentNavVC, animated:
                                    true)
                            } else {
                                let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                                self.present(tabBarVC, animated: true, completion: nil)
                            }
                            
                            return
                        }
                    }
                }
            }
        })
        //displayMyAlertMessage2(userMessage: "Sign-In Successful")
    }
    
    func checkForGoogleCustomer() {
        userFirebase.USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // The snapshot is a current look at our customers data.
            
            print(String(describing: snapshot.value))
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let postDictionary = snap.value as? Dictionary<String, Any> {
                        
                        if snap.key == self.shortEmail {
                            self.customerExists = true
                            if postDictionary["customerId"] != nil {
                                
                                let customerId = postDictionary["customerId"] as! String
                                UserDefaults.standard.set(customerId, forKey: "CustomerId")
                            } else {
                                UserDefaults.standard.set(nil, forKey: "CustomerId")
                            }
                            
                            if postDictionary["last4"] != nil {
                                let last4 = postDictionary["last4"] as! String
                                UserDefaults.standard.set(last4, forKey: "last4")
                            } else {
                               UserDefaults.standard.set(nil, forKey: "last4")
                            }
                            
                            if postDictionary["currentUp2s"] != nil {
                              let currentUp2s = postDictionary["currentUp2s"] as! [String]
                                UserDefaults.standard.set(currentUp2s, forKey: "currentUp2s")
                            }
                            
                            if UserDefaults.standard.bool(forKey: "cartHasItems") == true {
                                let paymentNavVC = self.storyboard!.instantiateViewController(withIdentifier: "PaymentNavigationController") as! UINavigationController
                                
                                self.navigationController?.present(paymentNavVC, animated:
                                    true)
                            } else {
                                let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
                                self.present(tabBarVC, animated: true, completion: nil)
                            }
                            
                            return
                        }
                    }
                }
            }
        })
        
    }
    
//    func createCustomer(_ : UIAlertAction) {
//        if customerExists == false {
//            let newCustomer: [String: Any] = ["currentUp2s": ["up2date"], "email": UserDefaults.standard.string(forKey: "email")!, "previousUp2s": ["up2date"]]
//            self.newCustomerRef = userFirebase.USER_REF.child(self.shortEmail!)
//            self.newCustomerRef?.setValue(newCustomer)
//        }
//
//        if UserDefaults.standard.bool(forKey: "cartHasItems") == true {
//            let paymentNavVC = self.storyboard!.instantiateViewController(withIdentifier: "PaymentNavigationController") as! UINavigationController
//
//            self.navigationController?.present(paymentNavVC, animated:
//                true)
//        } else {
//            let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
//            self.present(tabBarVC, animated: true, completion: nil)
//        }
//    }
    
    
    @IBAction func googleButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    //when the signin completes
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        //if any error stop and print the error
        if error != nil{
            print(error.localizedDescription)
            return
        }
    
        
        //if success display the email on label
        
        let authentication = user.authentication
        let credentials = FIRGoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!)
        
        email = user.profile.email
        
        FIRAuth.auth()?.signIn(with: credentials) { (user, error) in
            //if any error stop and print the error
            if error != nil{
                print(error?.localizedDescription ?? "Firebase Auth Error with Google Sign-In")
                return
            }
            print("Signed In with Google in Firebase")
            UserDefaults.standard.setValue(self.email, forKey: "email")
            self.shortEmail = self.email
            self.shortEmail?.removeLast(4)
            UserDefaults.standard.set(self.shortEmail!, forKey: "FirebaseRef")
            
            self.checkForGoogleCustomer()
        }
        
        
        
    
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        let registerVC = self.storyboard!.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        
        self.navigationController?.pushViewController(registerVC, animated:
            true)
        return
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let recoverVC = self.storyboard!.instantiateViewController(withIdentifier: "RecoverPasswordViewController") as! RecoverPasswordViewController
        
        self.navigationController?.pushViewController(recoverVC, animated:
            true)
        return
    }
    
    func displayMyAlertMessage(userMessage: String) {
       
            let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            myAlert.addAction(action)
            
            self.present(myAlert, animated: true, completion: nil)
          
    }
    
//    func displayMyAlertMessage2(userMessage: String) {
//        
//        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
//        let action = UIAlertAction(title: "OK", style: .default, handler: createCustomer)
//        
//        myAlert.addAction(action)
//        
//        self.present(myAlert, animated: true, completion: nil)
//        
//    }
    
    
    
    func homeButtonTapped(_ sender: UIBarButtonItem) {
        print("Home Button Tapped")
        let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        
        self.present(tabBarVC, animated: true, completion: nil)
        return
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign-In"
        
        hideKeyboardWhenTappedAround()

        if UserDefaults.standard.string(forKey: "email") != nil {
            let accountVC = self.storyboard!.instantiateViewController(withIdentifier: "AccountNavViewController") as! UINavigationController
            self.present(accountVC, animated:
                true)
            return
        }
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(homeButtonTapped))
            
        navigationController?.navigationBar.tintColor = UIColor.white
        
        
        //Google
        //error object
        var error : NSError?
        
        //setting the error
        GGLContext.sharedInstance().configureWithError(&error)
        
        //if any error stop execution and print error
        if error != nil{
            print(error ?? "google error")
            return
        }
        
        
        //adding the delegates
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
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

}

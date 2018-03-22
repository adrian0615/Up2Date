//
//  PaymentViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 7/16/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import Foundation
import Stripe
import PassKit
import SVProgressHUD
import FirebaseDatabase


class PaymentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, STPPaymentCardTextFieldDelegate, CardIOPaymentViewControllerDelegate, PKPaymentAuthorizationViewControllerDelegate {
    
    
    var actInd: UIActivityIndicatorView? = nil
    
    var card: STPCardParams? = nil
    var customerId = UserDefaults.standard.string(forKey: "CustomerId")
    var last4 = UserDefaults.standard.string(forKey: "last4")
    var cardId: String? = nil
    var paymentSucceeded = false
    var updateCard = false
    let backEndAPI = BackEndAPI()
    var userFirebase = UserFirebase()
    var customerRef: FIRDatabaseReference?
    var email = UserDefaults.standard.string(forKey: "email")
    var firebaseEmailRef = UserDefaults.standard.string(forKey: "FirebaseRef")
    
    
    var up2NameIds: [String]? = nil
    var up2Names: [String]? = nil
    var up2s: [Up2]? = nil
    var totals: [String]? = nil
    var amount = 0
    var applePayAmount: NSDecimalNumber = 0
    var confirmation: String? = nil
    var up2Firebase = Up2Firebase()
    var haveInternet = false
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var layoutLabel: UILabel!
    @IBOutlet weak var CardTitleLabel: UILabel!
    @IBOutlet weak var CardTypeLabel: UILabel!
    @IBOutlet weak var CardInfoLabel: UILabel!
    @IBOutlet var payButton: UIButton!
    @IBOutlet var scanCardButton: UIButton!
    @IBOutlet weak var addCardButton: UIButton!
    var paymentTextField: STPPaymentCardTextField!
    
    @IBOutlet weak var newCardButton: UIButton!
    @IBOutlet weak var applePayButton: UIButton!
    
    @IBOutlet weak var deleteOneButton: UIButton!
    @IBOutlet weak var deleteTwoButton: UIButton!
    
    func paymentMade() {
        self.activityIndicatorStop()
        UserDefaults.standard.set(self.customerId!, forKey: "CustomerId")
        UserDefaults.standard.set(last4, forKey: "last4")
        SVProgressHUD.showSuccess(withStatus: "Payment Successful")
        let confirmNavVC = self.storyboard!.instantiateViewController(withIdentifier: "ConfirmationNavigationController") as! UINavigationController
        
        self.present(confirmNavVC, animated: true)
    }
    
    
    func addCustomerIDtoFirebase() {
        email!.removeLast(4)
        print(email!)
        if firebaseEmailRef == nil {
            customerRef = userFirebase.USER_REF.child(email!)
        } else {
           self.customerRef = userFirebase.USER_REF.child(firebaseEmailRef!)
        }
        let customerIdRef = customerRef?.child("customerId")
        customerIdRef?.setValue(customerId!)
        
        let last4Ref = customerRef?.child("last4")
        last4Ref?.setValue(last4!)
    }
    
    func getCustomerCardInfo() {
        userFirebase.USER_REF.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // The snapshot is a current look at our customers data.
            
            print(String(describing: snapshot.value))
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let postDictionary = snap.value as? Dictionary<String, Any> {
                        var shortEmail = self.email
                        shortEmail?.removeLast(4)
                        if snap.key == shortEmail {
                            print("-----------FOUND IT------------------------")
                            if postDictionary["customerId"] != nil {
                                self.customerId = postDictionary["customerId"] as? String
                                UserDefaults.standard.set(self.customerId, forKey: "CustomerId")
                            }
                            
                            if postDictionary["last4"] != nil {
                                self.last4 = postDictionary["last4"] as? String
                                UserDefaults.standard.set(self.last4, forKey: "last4")
                            }
                            
                            return
                        }
                    }
                }
            }
        })
    }
    
    
    
    @IBAction func addCardTapped(_ sender: Any) {
        updateCard = true
        addCardButton.isHidden = true
        addCardButton.isEnabled = false
        
        //Enter Credit Card Option
        view.addSubview(paymentTextField)
        paymentTextField.isHidden = false
        paymentTextField.isEnabled = true
        scanCardButton.isEnabled = true
        scanCardButton.isHidden = false
        
    }
    @IBAction func newCardTapped(_ sender: Any) {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear Info", style: .plain, target: self, action: #selector(clearButtonTapped))
        
        newCardButton.isHidden = true
        newCardButton.isEnabled = false
        CardTitleLabel.isHidden = true
        CardTypeLabel.isHidden = true
        CardInfoLabel.isHidden = true
        payButton.isHidden = true
        payButton.isEnabled = false
        
        //Enter Credit Card Option
        paymentTextField.isHidden = false
        paymentTextField.isEnabled = true
        scanCardButton.isEnabled = true
        scanCardButton.isHidden = false
    }
    @IBAction func deleteOneTapped(_ sender: Any) {
        
        if up2NameIds!.count > 1 && up2Names!.count > 1 && up2s!.count > 1 {
            up2NameIds = [UserDefaults.standard.array(forKey: "cart")?[1]] as? [String]
            up2Names = [UserDefaults.standard.array(forKey: "cartNames")?[1]] as? [String]
            totals = [UserDefaults.standard.array(forKey: "totalsString")?[0]] as? [String]
            up2s?.remove(at: 0)
            totalAmountLabel.text = "$1.99"
            CardInfoLabel.text = "Amount: \(totalAmountLabel.text!)"
            amount = 199
            UserDefaults.standard.set(up2NameIds, forKey: "cart")
            UserDefaults.standard.set(up2Names, forKey: "cartNames")
            UserDefaults.standard.set(totals, forKey: "totalsString")
        } else {
            up2s = nil
            up2NameIds = []
            up2Names = []
            totals = []
            UserDefaults.standard.set(nil, forKey: "cart")
            UserDefaults.standard.set(nil, forKey: "cartNames")
            UserDefaults.standard.set(nil, forKey: "totalsString")
            amount = 0
            totalAmountLabel.text = "$0.00"
            CardInfoLabel.text = "Amount: \(totalAmountLabel.text!)"
            UserDefaults.standard.set(false, forKey: "cartHasItems")
            
            let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
            self.present(tabBarVC, animated: true, completion: nil)
            
        }
        update()
    }
    
    @IBAction func deleteTwoTapped(_ sender: Any) {
        up2s?.remove(at: 1)
        up2NameIds = [UserDefaults.standard.array(forKey: "cart")?[0]] as? [String]
        up2Names = [UserDefaults.standard.array(forKey: "cartNames")?[0]] as? [String]
        totals = [UserDefaults.standard.array(forKey: "totalsString")?[0]] as? [String]
        totalAmountLabel.text = "$1.99"
        CardInfoLabel.text = "Amount: \(totalAmountLabel.text!)"
        amount = 199
        UserDefaults.standard.set(up2NameIds, forKey: "cart")
        UserDefaults.standard.set(up2Names, forKey: "cartNames")
        UserDefaults.standard.set(totals, forKey: "totalsString")
        update()
    }
    
    func showActivityIndicator(uiView: UIView) {
        
        actInd?.center = uiView.center
        actInd?.hidesWhenStopped = true
        actInd?.startAnimating()
        uiView.addSubview(actInd!)
    }
    
    func update() {
        
        if up2NameIds == nil || up2NameIds! == [] {
            deleteOneButton.isHidden = true
            deleteTwoButton.isHidden = true
        } else if up2NameIds!.count == 1 {
            deleteTwoButton.isHidden = true
        }
        
        cartTableView.reloadData()
    }
    
    func homeButtonTapped(_ action: UIBarButtonItem) {
        let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        self.present(tabBarVC, animated: true, completion: nil)
    }
    
    func clearButtonTapped(_ sender: UIBarButtonItem) {
        print("Clear Button Tapped")
        let paymentNavVC = self.storyboard!.instantiateViewController(withIdentifier: "PaymentNavigationController") as! UINavigationController
        self.present(paymentNavVC, animated:
            true)
        return
    }
    
    override func viewDidLoad() {
        // add stripe built-in text field to fill card information in the middle of the view
        super.viewDidLoad()
        
        title = "Cart"
        
        layoutLabel.isHidden = true
        
        print(last4 ?? "no last 4")
        print(customerId ?? "no custId")
        
        //Credit Card Entry Field
        let frame1 = CGRect(x: 20, y: 150, width: self.view.frame.size.width - 40, height: 40)
        paymentTextField = STPPaymentCardTextField(frame: frame1)
        paymentTextField.center = view.center
        paymentTextField.delegate = self
        scanCardButton.isEnabled = false
        scanCardButton.isHidden = true
        
        
        
        
        getCustomerCardInfo()
        
        if UserDefaults.standard.array(forKey: "cart") != nil {
            up2NameIds = UserDefaults.standard.array(forKey: "cart") as? [String]
            up2Names = UserDefaults.standard.array(forKey: "cartNames") as? [String]
            totals = UserDefaults.standard.array(forKey: "totalsString") as? [String]
            
            if up2NameIds!.count == 1 {
                totalAmountLabel?.text = "$1.99"
                amount = 199
                //applePayAmount = 1.99
            } else if up2NameIds!.count == 2  {
                totalAmountLabel?.text = "$2.99"
                amount = 299
                //applePayAmount = 2.99
                
            }
            
        }
        
        if up2NameIds == nil {
            deleteOneButton.isHidden = true
            deleteTwoButton.isHidden = true
        } else if up2NameIds!.count == 1 {
            deleteTwoButton.isHidden = true
        }
        
        if customerId != nil && last4 != nil {
            addCardButton.isHidden = true
            addCardButton.isEnabled = false
            newCardButton.isHidden = false
            newCardButton.isEnabled = true
            payButton.isHidden = false
            payButton.isEnabled = true
            CardTitleLabel.text = "Card to Be Charged:"
            CardTypeLabel.text = "Ending in \(last4!)"
            CardInfoLabel.text = "Amount: \(totalAmountLabel.text!)"
        } else {
            getCustomerCardInfo()
        }
        
        if customerId == nil || last4 == nil {
            addCardButton.isHidden = false
            addCardButton.isEnabled = true
            newCardButton.isHidden = true
            newCardButton.isEnabled = false
            payButton.isHidden = true
            payButton.isEnabled = false
            layoutLabel.isHidden = true
            CardTitleLabel.isHidden = true
            CardTypeLabel.isHidden = true
            CardInfoLabel.isHidden = true
        }
        
        
        
        getUp2()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(homeButtonTapped))
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        
        
        cartTableView.delegate = self
        cartTableView.dataSource = self
        
        hideKeyboardWhenTappedAround()
        
        if addCardButton.isHidden == false && addCardButton.isEnabled == true && last4 != nil && customerId == nil {
            restart()
        }
        
        if addCardButton.isHidden == false && addCardButton.isEnabled == true && last4 == nil && customerId != nil {
            restart()
        }
        
        
        if amount == 199 {
            displayMyAlertMessage(userMessage: "Add Another Discount for $1")
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CardIOUtilities.preload()
        
    }
    
    func restart() {
        let paymentNavVC = self.storyboard!.instantiateViewController(withIdentifier: "PaymentNavigationController") as! UINavigationController
        
        self.navigationController?.present(paymentNavVC, animated:
            true)

    }
   
    
    func displayNoInternet() {
        
        let myAlert = UIAlertController(title: "Alert", message: "No Internet Connection.  Please Try Again Later", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
        
        return
        
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
            self.update()
        })
        
    }
    
    func paymentCardTextFieldDidEndEditingCVC(_ textField: STPPaymentCardTextField) {
        paymentTextField.resignFirstResponder()
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }

    
    
    func displayMyAlertMessage(userMessage: String) {
        
        let myAlert = UIAlertController(title: "", message: userMessage, preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: yesActionTapped)
        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
        
        myAlert.addAction(yesAction)
        myAlert.addAction(noAction)
        
        self.present(myAlert, animated: true, completion: nil)
        
        return
        
    }
    
    func displayMyAlertMessage2(userMessage: String) {
        
        let myAlert = UIAlertController(title: "Failed to Complete Transaction", message: userMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        
        myAlert.addAction(okAction)
        
        
        self.present(myAlert, animated: true, completion: nil)
        
        return
        
    }
    
    
    
    func yesActionTapped(_ alert: UIAlertAction) {
        let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        self.present(tabBarVC, animated: true, completion: nil)
    }

    
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if up2s != nil && totals != nil {
            return up2s!.count
        //} else if up2Strings != nil && totals != nil {
           // return up2Strings!.count
        } else if up2Names != nil && totals != nil {
            return up2Names!.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartTableViewCell", for: indexPath) as! CartTableViewCell
        
        if up2s != nil && totals != nil {
            let up2 = up2s![indexPath.row]
            let amount = totals?[indexPath.row]
            cell.configureCell(up2: up2, amount: amount!)
        } else if (up2Names != nil) && (totals != nil) && (totals! != []) {
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
    
    @IBAction func scanCard(_ sender: Any) {
        //open cardIO controller to scan the card
        
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.modalPresentationStyle = .formSheet
        present(cardIOVC!, animated: true, completion: nil)
        
    }
    
    @IBAction func payButtonTapped(_ sender: Any) {
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        //send card information to stripe to get back a token
        
        if UserDefaults.standard.string(forKey: "CustomerId") == nil || updateCard == true {
            getStripeToken(card: card!)
        } else {
            print("CustomerId exists updatedCard == false")
            //print(customerId)
            payWithCustomerId()
            //paymentMade()
        }
        
        
        
        
        
       
    }
//    @IBAction func applePayButtonTapped(_ sender: Any) {
//        let merchantIdentifier = "merchant.com.up2date.ios.test"
//        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier)
//
//        // Configure the line items on the payment request
//        paymentRequest.paymentSummaryItems = [
//            PKPaymentSummaryItem(label: "Up2Date Mobile App", amount: applePayAmount)
//        ]
//
//        if Stripe.canSubmitPaymentRequest(paymentRequest) {
//            // Setup payment authorization view controller
//            let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
//            paymentAuthorizationViewController.delegate = self
//
//            // Present payment authorization view controller
//            present(paymentAuthorizationViewController, animated: true)
//        }
//        else {
//            // There is a problem with your Apple Pay configuration
//            print("check Apple Pay configuration")
//        }
//    }
    
    
    
    func activityIndicatorStart() {
        DispatchQueue.main.async(execute: {
        self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
            self.activityIndicator.backgroundColor = UIColor.darkGray
            self.view.addSubview(self.activityIndicator)
        
            self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
       })
    }
    
    func activityIndicatorStop() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        })
    }
    
    func payWithCustomerId() {
        self.backEndAPI.postTokenToHeroku2(customerId: customerId!, amount: self.amount, description: "Up2Date", email: UserDefaults.standard.string(forKey: "email")!) { result in
            SVProgressHUD.showSuccess(withStatus: "Payment Processing...")
            
            
            
            switch result {
            case let .success(good) :
                self.activityIndicatorStop()
                
                OperationQueue.main.addOperation {
                    self.activityIndicatorStop()
                    print(good)
                    UserDefaults.standard.set(self.customerId!, forKey: "CustomerId")
                    UserDefaults.standard.set(self.last4, forKey: "last4")
                    if let message = good["message"] as? String, let status = good["status"] as? Int {
                        if status == 500 {
                            self.displayMyAlertMessage2(userMessage: message)
                            self.self.payButton.isHidden = false
                            self.view.backgroundColor = UIColor.white
                            return
                        }
                        
                    }
                    //if the payment has gone through then get necessary info and go to ConfirmationViewController
                    self.activityIndicatorStop()
                    SVProgressHUD.showSuccess(withStatus: "Payment Successful")
                }
                let confirmNavVC = self.storyboard!.instantiateViewController(withIdentifier: "ConfirmationNavigationController") as! UINavigationController
                
                self.present(confirmNavVC, animated: true)
                
            case let .failure(error) :
                print("Failed: \(error)")
                self.payButton.isHidden = false
                self.view.backgroundColor = UIColor.white
                self.activityIndicatorStop()
                self.displayMyAlertMessage2(userMessage: String(describing: error))
            }
        }
    }
    
    
    
   
    
    func getStripeToken(card:STPCardParams) {
        // get created stripe token for current card
        STPAPIClient.shared().createToken(withCard: card) { token, error in
            if let token = token {
                print(token)
                SVProgressHUD.showSuccess(withStatus: "Payment Processing...")
                self.activityIndicatorStart()
                if UserDefaults.standard.string(forKey: "CustomerId") == nil || self.updateCard == true {
                //Try to create customer
                self.backEndAPI.postCreateCustomer(token: token, email: UserDefaults.standard.string(forKey: "email")!) { result in
                    
                    switch result {
                    case let .success(good) :
                        print(good)
                        
                        if let errors = good["error"] as? [String: Any] {
                            let message = errors["message"] as? String
                            self.displayMyAlertMessage2(userMessage: message!)
                        }
                        
                        if let sources = good["sources"] as? [String: Any] {
                            self.updateCard = false
                            let data = sources["data"] as! [[String: Any]]
                            print(data)
                            self.customerId = data[0]["customer"] as? String
                            
                            
                            if self.customerId != nil {
                                //Displays successfully obtained token on screen
                                //send charge to backend
                                print(self.customerId!)
                                self.payButton.isHidden = true
                                self.addCustomerIDtoFirebase()
                                self.payWithCustomerId()
                                
                               //self.paymentMade()
                            }
                        }
                        
                    case let .failure(error) :
                        print("Failed: \(error)")
                        self.payButton.isHidden = false
                        self.view.backgroundColor = UIColor.white
                        self.activityIndicatorStop()
                        self.displayMyAlertMessage2(userMessage: String(describing: error))
                    }
                }
                    return
                }
                
                
            } else {
                print(error!)
                self.displayMyAlertMessage2(userMessage: String(describing: error!))
            }
        }
    }

    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if textField.valid{
            payButton.isEnabled = true
            payButton.isHidden = false
            //applePayButton.isHidden = true
            //applePayButton.isEnabled = false
            card = paymentTextField.cardParams
            CardTitleLabel.isHidden = false
            CardTypeLabel.isHidden = false
            CardInfoLabel.isHidden = false
            scanCardButton.isHidden = true
            scanCardButton.isEnabled = false
            deleteOneButton.isHidden = true
            deleteTwoButton.isHidden = true
            CardTitleLabel.text = "Card to Be Charged:"
            CardTypeLabel.text = "Ending in \(card!.last4()!)  ex: \(card!.expMonth)/\(card!.expYear)"
            
            last4 = card!.last4()
            
            CardInfoLabel.text = "Amount: \(totalAmountLabel.text!)"
            paymentTextField.resignFirstResponder()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear Info", style: .plain, target: self, action: #selector(clearButtonTapped))
            
        } else {
            payButton.isEnabled = false
            payButton.isHidden = true
            //applePayButton.isHidden = false
           // applePayButton.isEnabled = true
            CardTitleLabel.isHidden = true
            CardTypeLabel.isHidden = true
            CardInfoLabel.isHidden = true
            scanCardButton.isHidden = false
            scanCardButton.isEnabled = true
            
            if up2Names!.count > 1 {
                deleteOneButton.isHidden = false
                deleteTwoButton.isHidden = false
            } else {
                deleteOneButton.isHidden = false
                
            }
        }
    }
    
    
    
    //MARK: - ApplePay Methods
    
    
    
//    func handleApplePayButtonTapped(_ sender: PKPaymentButton) {
//
//        let merchantIdentifier = "merchant.com.up2date.ios.test"
//        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier)
//
//        // Configure the line items on the payment request
//        paymentRequest.paymentSummaryItems = [
//
//            PKPaymentSummaryItem(label: "Up2Date Mobile App", amount: applePayAmount)
//        ]
//
//        if Stripe.canSubmitPaymentRequest(paymentRequest) {
//            // Setup payment authorization view controller
//            let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
//            paymentAuthorizationViewController.delegate = self
//
//            // Present payment authorization view controller
//            present(paymentAuthorizationViewController, animated: true)
//        } else {
//            // There is a problem with your Apple Pay configuration
//            print("check Apple Pay configuration")
//        }
//    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        STPAPIClient.shared().createToken(with: payment) { (token: STPToken?, error: Error?) in
            guard let token = token, error == nil else {
                SVProgressHUD.showError(withStatus: String(describing: error))
                return
            }
            
            print(token)
        
            if UserDefaults.standard.string(forKey: "CustomerId") == nil || self.updateCard == true {
                //Try to create customer
                self.backEndAPI.postCreateCustomer(token: token, email: UserDefaults.standard.string(forKey: "email")!) { result in
                    
                    switch result {
                    case let .success(good) :
                        print(good)
                        
                        if let sources = good["sources"] as? [String: Any] {
                            self.updateCard = false
                            let data = sources["data"] as! [[String: Any]]
                            print(data)
                            self.customerId = data[0]["customer"] as? String
                            
                            if self.customerId != nil {
                                UserDefaults.standard.set(self.customerId!, forKey: "CustomerId")
                                //Displays successfully obtained token on screen
                                SVProgressHUD.showSuccess(withStatus: "Payment Processing...")
                                self.payButton.isHidden = true
                                self.view.backgroundColor = UIColor.darkGray
                                self.activityIndicatorStart()
                                //send charge to backend
                                self.payWithCustomerId()
                                //self.paymentMade()
                            }
                        }
                        
                    case let .failure(error) :
                        print("Failed: \(error)")
                        self.payButton.isHidden = false
                        self.view.backgroundColor = UIColor.white
                        self.activityIndicatorStop()
                        self.displayMyAlertMessage2(userMessage: String(describing: error))
                    }
                }
                return
            }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        // Dismiss payment authorization view controller
        dismiss(animated: true, completion: {
            if (self.paymentSucceeded) {
                //if the payment has gone through then get necessary info and go to ConfirmationViewController
                
                let confirmNavVC = self.storyboard!.instantiateViewController(withIdentifier: "ConfirmationNavigationController") as! UINavigationController
                
                self.present(confirmNavVC, animated: true)
            }
        })
    }
    
    
    //MARK: - CardIO Methods
    
    //Allow user to cancel card scanning
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        print("user canceled")
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    //Callback when card is scanned correctly
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            let str = NSString(format: "Received card info.\n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv)
            print(str)
            
            last4 = String(info.redactedCardNumber.suffix(4))
            
            
            //dismiss scanning controller
            paymentViewController?.dismiss(animated: true, completion: nil)
            
            paymentTextField.isHidden = true
            paymentTextField.isEnabled = false
            scanCardButton.isEnabled = false
            scanCardButton.isHidden = true
            payButton.isEnabled = true
            payButton.isHidden = false
            newCardButton.isHidden = false
            newCardButton.isEnabled = true
            CardTitleLabel.isHidden = false
            CardTypeLabel.isHidden = false
            CardInfoLabel.isHidden = false
            CardTitleLabel.text = "Card to Be Charged:"
            CardTypeLabel.text = "\(info.redactedCardNumber!)  ex: \(info.expiryMonth)/\(info.expiryYear)"
            CardInfoLabel.text = "Amount: \(totalAmountLabel.text!)"
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear Info", style: .plain, target: self, action: #selector(clearButtonTapped))
            
            //create Stripe card
            card = STPCardParams()
            
            card?.number = info.cardNumber
            card?.expMonth = info.expiryMonth
            card?.expYear = info.expiryYear
            card?.cvc = info.cvv
            
        }
    }
    
    

}

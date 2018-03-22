//
//  SupportViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 10/3/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import MessageUI

class SupportViewController: UIViewController, MFMailComposeViewControllerDelegate {

    
    @IBAction func supportButtonTapped(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["up2help@up2datemobileapp.com"])
            mail.setMessageBody("<p>I have a question/comment:</p>", isHTML: true)
            
            present(mail, animated: true)
        } else if #available(iOS 10.0, *) {
            if let url = URL(string: "https://up2datemobileapp.com/") {
                UIApplication.shared.open(url, options: [:])
            }
        } else {
            displayMyAlertMessage(userMessage: "Contact Support at up2help@up2datemobileapp.com")
        }
        
    }
   
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func displayMyAlertMessage(userMessage: String) {
        
        let myAlert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        myAlert.addAction(action)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func homeButtonTapped(_ sender: UIBarButtonItem) {
        print("Home Button Tapped")
        let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        
        self.present(tabBarVC, animated: true, completion: nil)
        return
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Support"

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(homeButtonTapped))
        
        navigationController?.navigationBar.tintColor = UIColor.white
    }


}

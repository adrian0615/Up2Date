//
//  WebsiteViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 9/6/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import Foundation
import WebKit
import UIKit
import SystemConfiguration

class WebsiteViewController: UIViewController , UIWebViewDelegate {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webView: UIWebView!
    
    
    var websiteURL = "http://www.google.com/"
    var checkAccess: Bool = false
    var theBool: Bool = false
    var myTimer = Timer()

    
    
    func startProgressView() {
        progressView.progress = 0.0
        self.theBool = false
        self.myTimer = Timer.scheduledTimer(timeInterval: 0.01667, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
    }
    
    func finishProgressView() {
        self.theBool = true
    }
    
    func timerCallback() {
        if self.theBool {
            if self.progressView.progress >= 1 {
                self.progressView.isHidden = true
                self.myTimer.invalidate()
            } else {
                self.progressView.progress += 0.1
            }
        } else {
            self.progressView.progress += 0.05
            if self.progressView.progress >= 0.95 {
                self.progressView.progress = 0.95
            }
        }
    }
    
    func isInternetAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Website"
        
        webView.delegate = self
        
        let url = URL(string: websiteURL)!
        let request = URLRequest(url: url)
        checkAccess = self.isInternetAvailable()
        
        if checkAccess == true {
            webView.loadRequest(request)
        } else {
            displayMyAlertMessage(userMessage: "No Internet Connection.  Please Try Again Later")
        }
        
        
        
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        startProgressView()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        finishProgressView()
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
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}

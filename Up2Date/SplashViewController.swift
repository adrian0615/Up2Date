//
//  SplashViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 6/28/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit


class SplashViewController: UIViewController {
    
    
    @IBOutlet weak var logoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.logo), userInfo: nil, repeats: false)
        // Do any additional setup after loading the view.
        
    }
    
    func logo() {
        _ = Timer.scheduledTimer(timeInterval: 5.1, target: self, selector: #selector(self.someSelector), userInfo: nil, repeats: false)
    }
    
    func someSelector() {
        let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        self.present(tabBarVC, animated: true, completion: nil)
    }
    
    
    
}

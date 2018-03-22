//
//  MyTabBarViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 8/8/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit

class MyTabBarViewController: UITabBarController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        //UIColor(red: 0/255.0, green: 188/255.0, blue: 212/255.0, alpha: 1)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 0/255.0, green: 188/255.0, blue: 212/255.0, alpha: 1), NSFontAttributeName: UIFont(name: "MarkerFelt-Thin", size: 19.0)!], for:.selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white,
                                                          NSFontAttributeName: UIFont(name: "MarkerFelt-Thin", size: 19.0)!], for:.normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

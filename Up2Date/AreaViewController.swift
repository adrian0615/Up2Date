//
//  AreaViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 7/11/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit

class AreaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var areas: [String] = ["Alpharetta", "Duluth", "Johns Creek","Norcross"]
    
    
    func backButtonTapped(_ sender: UIBarButtonItem) {
        print("Back Button Tapped")
        let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        
        self.present(tabBarVC, animated: true, completion: nil)
        return
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title:
            "<Back", style: .plain, target: self, action:
            #selector(backButtonTapped))
        
        navigationController?.navigationBar.tintColor = UIColor.white
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return areas.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AreaTableViewCell", for: indexPath)
        
        cell.textLabel?.text = areas[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(areas[indexPath.row], forKey: "neighborhood")
        let tabBarVC = self.storyboard!.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        self.present(tabBarVC, animated: true, completion: nil)

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

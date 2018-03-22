//
//  RestaurantTypeTableViewController.swift
//  Up2Date
//
//  Created by Brandon Stokes on 7/26/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RestaurantTypeTableViewController: UITableViewController {
    
    var types: [String] = ["African 🥘", "American 🍔", "Asian 🍚", "Caribbean 🍲", "BBQ 🍖", "Breakfast 🍳", "Fine Dining 🥂", "Hispanic 🌯", "Indian 🍛", "Italian 🍝", "Pizza 🍕", "Seafood 🍤", "Vegetarian 🥗"]
    
    var up2Firebase = Up2Firebase()
    var up2Image: UIImage? = nil
    var restaurants: [Up2] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "SEARCH"
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return types.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTypeCell", for: indexPath)

        cell.textLabel?.text = types[indexPath.row]
        cell.textLabel?.font = UIFont(name: "MarkerFelt-Thin", size: 19.0)
        cell.textLabel?.textColor = UIColor(red: 98/255.0, green: 188/255.0, blue: 195/255.0, alpha: 1)

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

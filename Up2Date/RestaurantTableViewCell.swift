//
//  RestaurantTableViewCell.swift
//  Up2Date
//
//  Created by Brandon Stokes on 7/26/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit
import CoreLocation

class RestaurantTableViewCell: UITableViewCell {
    
    var up2: Up2? = nil
    
    @IBOutlet weak var restaurantImage: UIImageView!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       restaurantImage.image = UIImage(named: "Logo and Verbage")
        
    }
    
    func configureCell(up2: Up2) {
        self.up2 = up2
        // Set the labels and image.
        self.restaurantLabel.text = up2._name
        self.discountLabel.text = up2._discount
        self.distanceLabel.text = "\(String(String(up2.distance).prefix(4))) miles"
        self.restaurantImage.downloadedFrom(link: up2._imageURL)
        
        if let i = RestaurantTableViewController.instance {
            i.update()
        }
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  ActivityTableViewCell.swift
//  Up2Date
//
//  Created by Brandon Stokes on 7/26/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    
    var up2: Up2? = nil

    @IBOutlet weak var activityImage: UIImageView!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        activityImage.image = UIImage(named: "Logo and Verbage")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(up2: Up2) {
        self.up2 = up2
        // Set the labels and image.
        self.activityLabel.text = up2._name
        self.discountLabel.text = up2._discount
        self.distanceLabel.text = "\(String(String(up2.distance).prefix(4))) miles"
        self.activityImage.downloadedFrom(link: up2._imageURL)
        
        if let i = ActivityTableViewController.instance {
            i.update()
        }
        
    }

}


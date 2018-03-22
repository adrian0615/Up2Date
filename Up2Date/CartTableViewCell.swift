//
//  CartTableViewCell.swift
//  Up2Date
//
//  Created by Brandon Stokes on 9/13/17.
//  Copyright © 2017 Brandon Stokes. All rights reserved.
//

import UIKit

class CartTableViewCell: UITableViewCell {
    
    var up2: Up2? = nil


    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(up2: Up2, amount: String) {
        self.up2 = up2
        // Set the labels and image.
        self.nameLabel.text = up2._name
        self.amountLabel.text = amount
        
    }

}

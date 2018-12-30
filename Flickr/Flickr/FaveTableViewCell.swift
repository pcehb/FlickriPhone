//
//  FaveTableViewCell.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 18/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//


//
// The cell used in Favourites
//

import UIKit

class FaveTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

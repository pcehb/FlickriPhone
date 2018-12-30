//
//  RoundedImageView.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 20/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//

//
// This class alters the radius of a UIImageView to make the photo inside appear like a circle
//

import Foundation
import UIKit

class RoundedImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = self.frame.width/2.0
        layer.cornerRadius = radius
        clipsToBounds = true 
    }
    
}

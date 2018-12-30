//
//  ScaledHeightImageView.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 11/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//

//
// This class alters the height of a UIImageView to match the photo's height inside
//

import UIKit

class ScaledHeightImageView: UIImageView {
    
    override var intrinsicContentSize: CGSize {
        
        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width
            
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio
            
            return CGSize(width: myViewWidth, height: scaledHeight)
        }
        
        return CGSize(width: -1.0, height: -1.0)
    }
    
}

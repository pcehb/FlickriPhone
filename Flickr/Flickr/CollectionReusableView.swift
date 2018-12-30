//
//  CollectionReusableView.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 20/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//


//
// The header cell used in User pages
//
import UIKit

class CollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var name: UILabel!
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

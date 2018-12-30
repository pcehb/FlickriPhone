//
//  FlickrPhotoCell.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 07/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//


//
// The cell used in Search, Recent, Popular & User pages
//
import UIKit

class FlickrPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    let detailsViewControllerInfo = DetailsViewController()
    let detailsOrderVC = UIViewController()
    
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        isSelected = false
    }

}

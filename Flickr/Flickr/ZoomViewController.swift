//
//  ZoomViewController.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 20/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//


//
// This file controls the Zoom page.
//

import UIKit

class ZoomViewController: UIViewController, UIScrollViewDelegate {

    var zoomPhoto: UIImage?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = zoomPhoto
        
        //Max and min zoom value
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    

}

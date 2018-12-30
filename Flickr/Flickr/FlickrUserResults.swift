//
//  FlickrUserResults.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 20/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//

//
//  This file stores the user photos results.
//

import Foundation

struct FlickrUserResults {
    let pageNum : Int
    let user_id: String
    let userResults : [FlickrPhoto]
}


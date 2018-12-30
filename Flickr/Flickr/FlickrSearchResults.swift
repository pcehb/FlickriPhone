//
//  FlickrUserPhotoResults.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 13/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//


//
//  This file stores the flickr search results.
//
import Foundation

struct FlickrSearchResults {
    let searchTerm : String
    let pageNum : Int
    let searchResults : [FlickrPhoto]
}

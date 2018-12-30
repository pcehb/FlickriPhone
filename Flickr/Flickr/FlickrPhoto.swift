//
//  FlickrPhotosViewController.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 07/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//


//
//  This file stores the results from flickr API.
//

import UIKit

class FlickrPhoto : Equatable {
    var thumbnail : UIImage?
    var largeImage : UIImage?
    var userPhoto : UIImage?
    let photoID : String
    let farm : Int
    let title : String
    let server : String
    let secret : String
    let ownername: String
    let description: String
    let ownerID : String
    
  
    init (photoID:String, farm:Int, title:String, server:String, secret:String, ownername: String, description: String, ownerID: String) {
    self.photoID = photoID
    self.farm = farm
    self.title = title
    self.server = server
    self.secret = secret
    self.ownername = ownername
    self.description = description
    self.ownerID = ownerID
  }
  
    
    //URL to get image
  func flickrImageURL(_ size:String = "m") -> URL? {
    if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg") {
      return url
    }
    return nil
  }
    
    //URL to get user photo
    fileprivate func flickrGetUserPhoto(_ ownerID:String) -> URL? {
        
        let URLString = "https://flickr.com/buddyicons/\(ownerID).jpg"
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        
        return url
    }
  
    //To get large image
  func loadLargeImage(_ completion: @escaping (_ flickrPhoto:FlickrPhoto, _ error: NSError?) -> Void) {
    guard let loadURL = flickrImageURL("b") else {
      DispatchQueue.main.async {
        completion(self, nil)
      }
      return
    }
    
    let loadRequest = URLRequest(url:loadURL)
    //Requests data
    URLSession.shared.dataTask(with: loadRequest, completionHandler: { (data, response, error) in
      if let error = error {
        DispatchQueue.main.async {
          completion(self, error as NSError?)
        }
        return
      }
      
      guard let data = data else {
        DispatchQueue.main.async {
          completion(self, nil)
        }
        return
      }
      
      let returnedImage = UIImage(data: data)
      self.largeImage = returnedImage
      DispatchQueue.main.async {
        completion(self, nil)
      }
    }).resume()
  }
    
    //Gets results for user profile pic
    func getUserPhoto(_ ownerID: String,_ completion: @escaping (_ flickrPhoto:FlickrPhoto, _ error: NSError?) -> Void) {
    
        guard let loadURL = flickrGetUserPhoto(ownerID) else {
            DispatchQueue.main.async {
                completion(self, nil)
            }
            return
        }

        let loadRequest = URLRequest(url:loadURL)
        
        //Requests data
        URLSession.shared.dataTask(with: loadRequest, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(self, error as NSError?)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(self, nil)
                }
                return
            }

            let returnedImage = UIImage(data: data)
            self.userPhoto = returnedImage
            DispatchQueue.main.async {
                completion(self, nil)
            }
        }).resume()

    }

  
  func sizeToFillWidthOfSize(_ size:CGSize) -> CGSize {
    
    guard let thumbnail = thumbnail else {
      return size
    }
    
    let imageSize = thumbnail.size
    var returnSize = size
    
    let aspectRatio = imageSize.width / imageSize.height
    
    returnSize.height = returnSize.width / aspectRatio
    
    if returnSize.height > size.height {
      returnSize.height = size.height
      returnSize.width = size.height * aspectRatio
    }
    
    return returnSize
  }
  
}

func == (lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
  return lhs.photoID == rhs.photoID
}

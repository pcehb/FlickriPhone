//
//  FlickrPhotosViewController.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 07/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//


//
//  This file searches the flickr API.
//

import UIKit

let apiKey = "9146b66fde6aaeada1033f3318f2518c"

class Flickr {
    
    let processingQueue = OperationQueue()
    
    //Gets results for search page
    func searchFlickrForTerm(_ searchTerm: String, _ pageNum: Int, completion : @escaping (_ results: FlickrSearchResults?, _ error : NSError?) -> Void){
        
        guard let searchURL = flickrSearchURLForSearchTerm(searchTerm, pageNum) else {
            let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
            completion(nil, APIError)
            return
        }
        
        let searchRequest = URLRequest(url: searchURL)
        
        //Requests data
        URLSession.shared.dataTask(with: searchRequest, completionHandler: { (data, response, error) in
            
            if let _ = error {
                let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
            }
            
            do {
                
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],
                    let stat = resultsDictionary["stat"] as? String else {
                        
                        let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                        return
                }
                
                switch (stat) {
                case "ok":
                    print("Results processed OK")
                case "fail":
                    if let message = resultsDictionary["message"] {
                        
                        let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:message])
                        
                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                    }
                    
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: nil)
                    
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    
                    return
                default:
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                guard let photosContainer = resultsDictionary["photos"] as? [String: AnyObject], let photosReceived = photosContainer["photo"] as? [[String: AnyObject]] else {
                    
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                var flickrPhotos = [FlickrPhoto]()
                
                //Iterates through and assigns results
                for photoObject in photosReceived {
                    guard
                        let photoID = photoObject["id"] as? String,
                        let farm = photoObject["farm"] as? Int ,
                        let title = photoObject["title"] as? String ,
                        let server = photoObject["server"] as? String ,
                        let secret = photoObject["secret"] as? String,
                        let ownername = photoObject["ownername"] as? String,
                        let description = photoObject["description"]?["_content"] as? String,
                        let ownerID = photoObject["owner"] as? String
                        else {
                            break
                    }
                    let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, title: title, server: server, secret: secret, ownername: ownername, description: description, ownerID: ownerID)
                    guard let url = flickrPhoto.flickrImageURL(),
                        let imageData = try? Data(contentsOf: url as URL) else {
                            break
                    }
                    
                    if let image = UIImage(data: imageData) {
                        flickrPhoto.thumbnail = image
                        flickrPhotos.append(flickrPhoto)
                    }
                    
                }
                
                OperationQueue.main.addOperation({
                    completion(FlickrSearchResults(searchTerm: searchTerm, pageNum: pageNum, searchResults: flickrPhotos), nil)
                })
                
            } catch _ {
                completion(nil, nil)
                return
            }
            
            
        }) .resume()
    }
    
    //Gets results for recent page
    func getRecentFlickrPhotos(_ pageNum: Int, completion : @escaping (_ results: FlickrRecentResults?, _ error : NSError?) -> Void){
        
        guard let recentURL = flickrGetRecentPhotos(pageNum) else {
            let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
            completion(nil, APIError)
            return
        }
        
        let recentRequest = URLRequest(url: recentURL)
        
        //Requests data
        URLSession.shared.dataTask(with: recentRequest, completionHandler: { (data, response, error) in
            
            if let _ = error {
                let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
            }
            
            do {
                
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],
                    let stat = resultsDictionary["stat"] as? String else {
                        
                        let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                        return
                }
                
                switch (stat) {
                case "ok":
                    print("Results processed OK")
                case "fail":
                    if let message = resultsDictionary["message"] {
                        
                        let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:message])
                        
                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                    }
                    
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: nil)
                    
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    
                    return
                default:
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                guard let photosContainer = resultsDictionary["photos"] as? [String: AnyObject], let photosReceived = photosContainer["photo"] as? [[String: AnyObject]] else {
                    
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                var flickrPhotos = [FlickrPhoto]()
                 //Iterates through and assigns results
                for photoObject in photosReceived {
                    guard
                        let photoID = photoObject["id"] as? String,
                        let farm = photoObject["farm"] as? Int ,
                        let title = photoObject["title"] as? String ,
                        let server = photoObject["server"] as? String ,
                        let secret = photoObject["secret"] as? String,
                        let ownername = photoObject["ownername"] as? String,
                        let description = photoObject["description"]?["_content"] as? String,
                        let ownerID = photoObject["owner"] as? String
                        else {
                            break
                    }
                    let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, title: title, server: server, secret: secret, ownername: ownername, description: description, ownerID: ownerID)
                    guard let url = flickrPhoto.flickrImageURL(),
                        let imageData = try? Data(contentsOf: url as URL) else {
                            break
                    }
                    
                    if let image = UIImage(data: imageData) {
                        flickrPhoto.thumbnail = image
                        flickrPhotos.append(flickrPhoto)
                    }
                    
                }
                
                OperationQueue.main.addOperation({
                    completion(FlickrRecentResults(pageNum: pageNum, recentResults: flickrPhotos), nil)
                })
            } catch _ {
                completion(nil, nil)
                return
            }
            
            
        }) .resume()
    }
    
    //Gets results for popular page
    func getPopularFlickrPhotos(_ pageNum: Int, completion : @escaping (_ results: FlickrPopularResults?, _ error : NSError?) -> Void){
        
        guard let popularURL = flickrGetPopularPhotos(pageNum) else {
            let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
            completion(nil, APIError)
            return
        }
        
        let popularRequest = URLRequest(url: popularURL)
        
        //Requests data
        URLSession.shared.dataTask(with: popularRequest, completionHandler: { (data, response, error) in
            
            if let _ = error {
                let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
            }
            
            do {
                
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],
                    let stat = resultsDictionary["stat"] as? String else {
                        
                        let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                        return
                }
                
                switch (stat) {
                case "ok":
                    print("Results processed OK")
                case "fail":
                    if let message = resultsDictionary["message"] {
                        
                        let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:message])
                        
                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                    }
                    
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: nil)
                    
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    
                    return
                default:
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                guard let photosContainer = resultsDictionary["photos"] as? [String: AnyObject], let photosReceived = photosContainer["photo"] as? [[String: AnyObject]] else {
                    
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                var flickrPhotos = [FlickrPhoto]()
                
                //Iterates through and assigns results
                for photoObject in photosReceived {
                    guard
                        let photoID = photoObject["id"] as? String,
                        let farm = photoObject["farm"] as? Int ,
                        let title = photoObject["title"] as? String ,
                        let server = photoObject["server"] as? String ,
                        let secret = photoObject["secret"] as? String,
                        let ownername = photoObject["ownername"] as? String,
                        let description = photoObject["description"]?["_content"] as? String,
                        let ownerID = photoObject["owner"] as? String
                        else {
                            break
                    }
                    let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, title: title, server: server, secret: secret, ownername: ownername, description: description, ownerID: ownerID)
                    guard let url = flickrPhoto.flickrImageURL(),
                        let imageData = try? Data(contentsOf: url as URL) else {
                            break
                    }
                    
                    if let image = UIImage(data: imageData) {
                        flickrPhoto.thumbnail = image
                        flickrPhotos.append(flickrPhoto)
                    }
                    
                }
                
                OperationQueue.main.addOperation({
                    completion(FlickrPopularResults(pageNum: pageNum, popularResults: flickrPhotos), nil)
                })
                
            } catch _ {
                completion(nil, nil)
                return
            }
            
            
        }) .resume()
    }
    
    //Gets results for user page
    func getUserFlickrPhotos(_ pageNum: Int, _ user_id: String, completion : @escaping (_ results: FlickrUserResults?, _ error : NSError?) -> Void){
        
        guard let userURL = flickrGetUserPhotos(pageNum, user_id) else {
            let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
            completion(nil, APIError)
            return
        }
        
        let userRequest = URLRequest(url: userURL)
        
        //Requests data
        URLSession.shared.dataTask(with: userRequest, completionHandler: { (data, response, error) in
            
            if let _ = error {
                let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                OperationQueue.main.addOperation({
                    completion(nil, APIError)
                })
                return
            }
            
            guard let _ = response as? HTTPURLResponse,
                let data = data else {
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
            }
            
            do {
                
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],
                    let stat = resultsDictionary["stat"] as? String else {
                        
                        let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                        return
                }
                
                switch (stat) {
                case "ok":
                    print("Results processed OK")
                case "fail":
                    if let message = resultsDictionary["message"] {
                        
                        let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:message])
                        
                        OperationQueue.main.addOperation({
                            completion(nil, APIError)
                        })
                    }
                    
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: nil)
                    
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    
                    return
                default:
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                guard let photosContainer = resultsDictionary["photos"] as? [String: AnyObject], let photosReceived = photosContainer["photo"] as? [[String: AnyObject]] else {
                    
                    let APIError = NSError(domain: "Flickr", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Unknown API response"])
                    OperationQueue.main.addOperation({
                        completion(nil, APIError)
                    })
                    return
                }
                
                var flickrPhotos = [FlickrPhoto]()
                
                //Iterates through and assigns results
                for photoObject in photosReceived {
                    guard
                        let photoID = photoObject["id"] as? String,
                        let farm = photoObject["farm"] as? Int ,
                        let title = photoObject["title"] as? String ,
                        let server = photoObject["server"] as? String ,
                        let secret = photoObject["secret"] as? String,
                        let ownername = photoObject["ownername"] as? String,
                        let description = photoObject["description"]?["_content"] as? String,
                        let ownerID = photoObject["owner"] as? String
                        else {
                            break
                    }
                    let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, title: title, server: server, secret: secret, ownername: ownername, description: description, ownerID: ownerID)
                    guard let url = flickrPhoto.flickrImageURL(),
                        let imageData = try? Data(contentsOf: url as URL) else {
                            break
                    }
                    
                    if let image = UIImage(data: imageData) {
                        flickrPhoto.thumbnail = image
                        flickrPhotos.append(flickrPhoto)
                    }
                    
                }
                
                OperationQueue.main.addOperation({
                    completion(FlickrUserResults(pageNum: pageNum, user_id: user_id, userResults: flickrPhotos), nil)
                })
                
            } catch _ {
                completion(nil, nil)
                return
            }
            
            
        }) .resume()
    }
    
    
    //Creates URL for search, using flickr.photos.search
    fileprivate func flickrSearchURLForSearchTerm(_ searchTerm:String,_ pageNum: Int) -> URL? {
        
        guard let escapedTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) else {
            return nil
        }
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(escapedTerm)&per_page=30&page=\(pageNum)&format=json&nojsoncallback=1&extras=description,owner_name"
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        
        return url
    }
    
    //Creates URL for recents, using flickr.photos.getRecent method
    fileprivate func flickrGetRecentPhotos(_ pageNum: Int) -> URL? {
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=\(apiKey)&per_page=30&page=\(pageNum)&format=json&nojsoncallback=1&extras=description,owner_name"
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        
        return url
    }
    
    //Creates URL for popular, using flickr.interestingness.getList method
    fileprivate func flickrGetPopularPhotos(_ pageNum: Int) -> URL? {
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=\(apiKey)&per_page=30&page=\(pageNum)&format=json&nojsoncallback=1&extras=description,owner_name"
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        
        return url
    }
    
    //Creates URL for user, using flickr.people.getPublicPhotos method
    fileprivate func flickrGetUserPhotos(_ pageNum: Int, _ user_id: String) -> URL?{
        
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.people.getPublicPhotos&api_key=\(apiKey)&user_id=\(user_id)&per_page=30&page=\(pageNum)&format=json&nojsoncallback=1&extras=description,owner_name"
        
        guard let url = URL(string:URLString) else {
            return nil
        }
        
        return url
    }
    
}

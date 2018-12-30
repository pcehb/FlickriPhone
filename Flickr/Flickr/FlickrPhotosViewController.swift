//
//  FlickrPhotosViewController.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 07/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//


//
//  This file controls the Search photos page.
//

import UIKit

final class FlickrPhotosViewController: UICollectionViewController {
    
    // MARK: - Properties
    fileprivate let reuseIdentifier = "FlickrCell"
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    fileprivate var searches = [FlickrSearchResults]()
    fileprivate let flickr = Flickr()
    fileprivate let itemsPerRow: CGFloat = 3
    var largePhotoIndexPath: NSIndexPath?
    var ownerPhotoIndexPath: NSIndexPath?
    var refresher:UIRefreshControl!
    var lastSearch: String = ""
    var pageNum = 1
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBAction func unwindToSearch(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check internet connection
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }
        else{
            let alert = UIAlertController(title: "Alert", message: "No Internet Connection Available. Please connect to the internet", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        //Swipe to refresh
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.attributedTitle = NSAttributedString(string: "Feching flickr photos...")
        self.refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
        
    }
    
    //Swipe to refresh
    @objc func refreshData() {
        flickr.searchFlickrForTerm(lastSearch, pageNum) {
            results, error in
            
            if let error = error {
                print("Error searching : \(error)")
                return
            }
            
            if let results = results {
                print("Found \(results.searchResults.count) matching \(results.searchTerm)")
                self.searches.insert(results, at: 0)
                
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.collectionView?.reloadData()
            self.refresher.endRefreshing()
        }
    }
    
}

private extension FlickrPhotosViewController {
    func photoForIndexPath(_ indexPath: IndexPath) -> FlickrPhoto {
        return searches[(indexPath as NSIndexPath).section].searchResults[(indexPath as NSIndexPath).row]
    }
}

//When user submits search field, gets photos from API
extension FlickrPhotosViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        activityIndicator.startAnimating()
        
        searches.removeAll()
        self.collectionView?.reloadData()
        
        flickr.searchFlickrForTerm(textField.text!, pageNum) {
            results, error in
            
            if let error = error {
                print("Error searching : \(error)")
                return
            }
            
            if let results = results {
                self.activityIndicator.stopAnimating()
                print("Found \(results.searchResults.count) matching \(results.searchTerm)")
                self.searches.insert(results, at: 0)
                
                self.collectionView?.reloadData()
            }
        }
        
        lastSearch = textField.text!
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}


extension FlickrPhotosViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searches.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    
    //Sets image in each cell
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! FlickrPhotoCell
        let flickrPhoto = photoForIndexPath(indexPath)
        cell.backgroundColor = UIColor.white
        
        cell.imageView.image = flickrPhoto.thumbnail
        return cell
    }
    
    //If a cell is selected -> Detail page
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let flickrPhoto = photoForIndexPath(indexPath)
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController
        
        //Loads large image
        //Assigns vars in Detail page
        flickrPhoto.loadLargeImage { loadedFlickrPhoto, error in
            guard loadedFlickrPhoto.largeImage != nil && error == nil else {
                vc?.detailPhoto = flickrPhoto.thumbnail
                vc?.detailTitle = flickrPhoto.title
                vc?.detailDesc = flickrPhoto.description
                vc?.detailOwner = flickrPhoto.ownername
                vc?.detailOwnerID = flickrPhoto.ownerID
                loadUser()
                return
            }
            
            if let _ = collectionView.cellForItem(at: indexPath) as? FlickrPhotoCell,
                let _ = self.largePhotoIndexPath  {
                vc?.detailPhoto = loadedFlickrPhoto.largeImage
                vc?.detailTitle = flickrPhoto.title
                vc?.detailDesc = flickrPhoto.description
                vc?.detailOwner = flickrPhoto.ownername
                vc?.detailOwnerID = flickrPhoto.ownerID
                loadUser()
            }
        }
        
        //Get user photo
        func loadUser(){
            print("loadUserCalled")
            flickrPhoto.getUserPhoto(flickrPhoto.ownerID) { loadedOwnerFlickrPhoto, error in
                guard loadedOwnerFlickrPhoto.userPhoto != nil && error == nil else {
                    print("user not loaded")
                    vc?.ownerPhoto = UIImage(named: "user_man")
                    self.navigationController?.pushViewController(vc!, animated: true)
                    return
                }
                if let _ = collectionView.cellForItem(at: indexPath) as? FlickrPhotoCell,
                    let _ = self.ownerPhotoIndexPath  {
                    print("user loaded")
                    vc?.ownerPhoto = loadedOwnerFlickrPhoto.userPhoto
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }
            
        }
        
    }
}

extension FlickrPhotosViewController {
    override func collectionView(_ collectionView: UICollectionView,
                                 shouldSelectItemAt indexPath: IndexPath) -> Bool {
        largePhotoIndexPath = indexPath as NSIndexPath
        ownerPhotoIndexPath = indexPath as NSIndexPath
        return true
    }
    
    //When user stops scrolling, get scroll bar position
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // UICollectionView only moves in one direction, y axis
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            self.updateNextSet()
        }
    }
    
    //Gets next page of flickr data when at bottom of scroll bar
    func updateNextSet(){
        pageNum = pageNum + 1
        flickr.searchFlickrForTerm(lastSearch, pageNum) {
            results, error in
            
            if let error = error {
                print("Error searching : \(error)")
                return
            }
            
            if let results = results {
                self.searches.insert(results, at: self.searches.count)
                self.collectionView?.reloadData()
                
            }
        }
    }
}

//Set size/spacing of cells
extension FlickrPhotosViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

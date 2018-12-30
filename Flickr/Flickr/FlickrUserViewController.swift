//
//  FlickrUserViewController.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 20/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//


//
//  This file controls the User Photos page.
//
import UIKit

class FlickrUserViewController: UICollectionViewController {
    // MARK: - Properties
    fileprivate let reuseIdentifier = "UserPhotosCell"
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
    fileprivate var users = [FlickrUserResults]()
    fileprivate let flickr = Flickr()
    fileprivate let itemsPerRow: CGFloat = 3
    var largePhotoIndexPath: NSIndexPath?
    var ownerPhotoIndexPath: NSIndexPath?
    var refresher:UIRefreshControl!
    var pageNum = 1
    var user_id: String?
    var user_image: UIImage?
    var username: String?
    
    
    
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
        
        //Gets photos from API
        activityIndicator.startAnimating()
        flickr.getUserFlickrPhotos(pageNum, user_id!) {
            results, error in
            
            if let error = error {
                print("Error searching : \(error)")
                return
            }
            
            if let results = results {
                print("Found \(results.userResults.count)")
                self.activityIndicator.stopAnimating()
                self.users.insert(results, at: 0)
                self.collectionView?.reloadData()
            }
        }
        
    }
    
    //Swipe to refresh
    @objc func refreshData() {
        flickr.getUserFlickrPhotos(pageNum, user_id!) {
            results, error in
            
            if let error = error {
                print("Error searching : \(error)")
                return
            }
            
            if let results = results {
                print("Found \(results.userResults.count)")
                self.users.insert(results, at: 0)
                
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.collectionView?.reloadData()
            self.refresher.endRefreshing()
        }
    }
    
}


private extension FlickrUserViewController {
    func photoForIndexPath(_ indexPath: IndexPath) -> FlickrPhoto {
        return users[(indexPath as NSIndexPath).section].userResults[(indexPath as NSIndexPath).row]
    }
}


extension FlickrUserViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return users.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return users[section].userResults.count
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
    
    //Header with user profile pic and name
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "UserPageHeader", for: indexPath as IndexPath) as! CollectionReusableView
        
        
        headerView.imageView.image = user_image!
        headerView.name.text = username!
    
        return headerView
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

extension FlickrUserViewController {
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
        flickr.getUserFlickrPhotos(pageNum, user_id!) {
            results, error in
            
            if let error = error {
                print("Error searching : \(error)")
                return
            }
            
            if let results = results {
                self.users.insert(results, at: self.users.count)
                self.collectionView?.reloadData()
                
            }
        }
    }
    
}

//Set size/spacing of cells
extension FlickrUserViewController : UICollectionViewDelegateFlowLayout {
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


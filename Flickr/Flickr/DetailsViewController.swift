//
//  DetailsViewController.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 09/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//


//
// This file controls the Details photos page.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIScrollViewDelegate {
    
    var faves = [NSManagedObject]()
    var detailTitle: String?
    var detailPhoto: UIImage?
    var detailOwner: String?
    var detailDesc: String?
    var detailOwnerID: String?
    var ownerPhoto: UIImage?
    fileprivate let flickr = Flickr()
    
    
    @IBOutlet weak var ownerPicture: UIImageView!
    @IBOutlet weak var detailImage: ScaledHeightImageView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var usernameText: UILabel!
    @IBOutlet weak var descText: UILabel!
    
    
    
    
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
        
        detailImage?.image = detailPhoto
        titleText?.text = detailTitle
        usernameText?.text = detailOwner
        descText?.text = detailDesc
        ownerPicture?.image = ownerPhoto
        
        //Sets GestureRecognizer -> Zoom page and -> User Page
        let tap = UITapGestureRecognizer(target: self, action: #selector(DetailsViewController.imageTapped))
        detailImage.addGestureRecognizer(tap)
        detailImage.isUserInteractionEnabled = true
        
        let userTap = UITapGestureRecognizer(target: self, action: #selector(DetailsViewController.userTapped))
        ownerPicture.addGestureRecognizer(userTap)
        ownerPicture.isUserInteractionEnabled = true
        
    }
    
    
    func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindToSearch", sender: self)
    }
    
    //Saves image to camera roll
    @IBAction func save(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(detailImage.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "The image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    //Shares image
    @IBAction func share(_ sender: Any) {
        let image = detailImage.image!
        let imageShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    //Faves image
    @IBAction func fave(_ sender: Any) {
        favePhoto(title: detailTitle!, ownername: detailOwner!, desc: detailDesc!, ownerID: detailOwnerID!, photo: detailPhoto!, ownerphoto: ownerPhoto!)
        
    }
    
    func favePhoto(title:String, ownername: String, desc: String, ownerID: String, photo: UIImage, ownerphoto: UIImage){
        //Get context object
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        //Get entity
        let entity = NSEntityDescription.entity(forEntityName: "Favourites", in: context)!
        
        let photoData = photo.pngData() as NSData?
        let ownerPhotoData = ownerphoto.pngData() as NSData?
        
        //Create fave object
        let fave = NSManagedObject(entity: entity, insertInto: context)
        fave.setValue(title,forKeyPath: "title")
        fave.setValue(ownername,forKeyPath: "ownername")
        fave.setValue(desc, forKeyPath: "desc")
        fave.setValue(ownerID,forKeyPath: "ownerID")
        fave.setValue(photoData, forKey: "photo")
        fave.setValue(ownerPhotoData, forKey: "ownerPhoto")
        do{
            try context.save()
            //Update local list in memory
            faves.append(fave)
            let ac = UIAlertController(title: "Favourited!", message: "The image has been added to your favourites.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        catch let error as NSError{
            print("Error \(error)")
        }
    }
    
    // -> Zoom page
    @objc func imageTapped()
    {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ZoomViewController") as? ZoomViewController
        vc?.zoomPhoto = detailPhoto
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // -> User page
    @objc func userTapped()
    {
        let vc2 = storyboard?.instantiateViewController(withIdentifier: "FlickrUserViewController") as? FlickrUserViewController
        vc2?.user_id = detailOwnerID!
        vc2?.user_image = ownerPhoto!
        vc2?.username = detailOwner!
        self.navigationController?.pushViewController(vc2!, animated: true)
    }
    
    
}


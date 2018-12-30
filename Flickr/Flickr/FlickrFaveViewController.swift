//
//  FlickrFaveViewController.swift
//  Flickr
//
//  Created by Phoebe Heath-Brown on 18/12/2018.
//  Copyright © 2018 Phoebe Heath-Brown. All rights reserved.
//


//
//  This file controls the Favourites photos page.
//

import UIKit
import CoreData

class FlickrFaveViewController: UITableViewController{
    
    var faves = [Favourites]()
    
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
        
        //Adds edit button
        navigationItem.rightBarButtonItem = editButtonItem
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Gets data faved in Core Data entity
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Favourites")
        
        do {
            faves = try managedContext.fetch(fetchRequest) as! [Favourites]
            
            tableView.separatorStyle = .none
            
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}


extension FlickrFaveViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faves.count
    }
    
    //Sets image and texts in each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "faveCell", for: indexPath) as! FaveTableViewCell
        
        let fave = faves[indexPath.row]
        
        if let imageData = fave.value(forKey: "photo") as? NSData {
            if let image = UIImage(data: imageData as Data) {
                cell.photoImage?.image = image
            }
        }
        
        cell.titleLabel?.text = fave.value(forKeyPath: "title") as? String
        cell.usernameLabel?.text = fave.value(forKeyPath: "ownername") as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension //return height size whichever you want
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let entity = "Favourites" //Entity Name
        
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            //Delete from CoreData
            managedContext.delete(faves[indexPath.row])
            
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Error While Deleting Note: \(error.userInfo)")
            }
        }
        
        //Code to Fetch New Data From The DB and Reload Table.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        do {
            faves = try managedContext.fetch(fetchRequest) as! [Favourites]
        } catch let error as NSError {
            print("Error While Fetching Data From DB: \(error.userInfo)")
        }
        
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
}

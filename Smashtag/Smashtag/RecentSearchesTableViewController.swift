//
//  RecentSearchesTableViewController.swift
//  Smashtag
//
//  Created by Simen Gangstad on 05.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit
import CoreData

class RecentSearchesTableViewController: UITableViewController {
    
    private var recentSearches = [String]()

    private var managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        recentSearches.removeAll()
        if let array = Storage.getRecents() {
            recentSearches.append(contentsOf: array)
            tableView.reloadData()
        }
        
        recentSearches.reverse()
        
        while recentSearches.count > 100 {
            recentSearches.removeLast()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
     
        performSegue(withIdentifier: "Show Mentions", sender: recentSearches[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recent", for: indexPath)
        cell.textLabel?.text = recentSearches[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Tweets" {
            if let destinationViewController = segue.destination as? TweetTableViewController {
                destinationViewController.searchText = (sender as! UITableViewCell).textLabel?.text!
            }
        }
        else if segue.identifier == "Show Mentions" {
            if let destinationViewController = segue.destination as? MentionsTableViewController {
                destinationViewController.searchTerm = (sender as? String)
                destinationViewController.managedObjectContext = managedObjectContext
            }
        }
    }
}

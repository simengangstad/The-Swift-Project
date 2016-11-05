//
//  RecentSearchesTableViewController.swift
//  Smashtag
//
//  Created by Simen Gangstad on 05.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class RecentSearchesTableViewController: UITableViewController {
    
    private var recentSearches = [String]()

    override func viewDidLoad() {
        
        if let array = Storage.getRecents() {
            recentSearches.append(contentsOf: array)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
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
    }
}

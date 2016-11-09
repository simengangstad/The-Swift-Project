//
//  TweetersTableViewController.swift
//  Smashtag
//
//  Created by Simen Gangstad on 08.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit
import CoreData

class TweetersTableViewController: CoreDataTableViewController {

    var mention: String? { didSet { updateUI() } }
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    
    private func updateUI() {
        
        if let context = managedObjectContext, (mention?.characters.count)! > 0 {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TwitterUser")
            request.predicate = NSPredicate(format: "any tweets.text contains[c] %@", mention!)
            request.sortDescriptors = [NSSortDescriptor(key: "screenName", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        }
        else {
            fetchedResultsController = nil
        }
    }
    
    private func tweetCountWithMentionByTwitterUser(user: TwitterUser) -> Int? {
        
        var count: Int?
        
        user.managedObjectContext?.performAndWait {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TweetData")
            request.predicate = NSPredicate(format: "text contains[c] %@ and tweeter = %@", self.mention!, user)
            count = try! user.managedObjectContext?.count(for: request)
        }
        
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TwitterUserCell", for: indexPath)

        if let twitterUser = fetchedResultsController?.object(at: indexPath) as? TwitterUser {
            
            var screenName : String?
            
            twitterUser.managedObjectContext?.performAndWait {
                screenName = twitterUser.screenName
            }
            
            cell.textLabel?.text = screenName
            
            if let count = tweetCountWithMentionByTwitterUser(user: twitterUser) {
                cell.detailTextLabel?.text = (count == 1) ? "1 tweet" : "\(count) tweets"
            }
            else {
                cell.detailTextLabel?.text = ""
            }
        }

        return cell
    }
}

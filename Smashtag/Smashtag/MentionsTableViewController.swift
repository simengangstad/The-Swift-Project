//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by Simen Gangstad on 11.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit
import CoreData

class MentionsTableViewController: CoreDataTableViewController {

    var searchTerm: String? { didSet { updateUI() } }
    var managedObjectContext: NSManagedObjectContext? { didSet { updateUI() } }
    
    private func updateUI() {
        
        if let context = managedObjectContext, (searchTerm?.characters.count)! > 0 {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "MentionData")
            request.predicate = NSPredicate(format: "searchTerm.value == %@ and count > 1 ", searchTerm!)
            
            // Sort by number of mentions in given tweets (both users and hashtags)
            request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false), NSSortDescriptor(key: "value", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        }
        else {
            fetchedResultsController = nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Mention Identifier", for: indexPath)
        
        if let mention = fetchedResultsController?.object(at: indexPath) as? MentionData {
            
            var value : String?
            var count : Int16?
            
            mention.managedObjectContext?.performAndWait {
                value = mention.value
                count = mention.count
            }
            
            cell.textLabel?.text = value
            cell.detailTextLabel?.text = "\(count!) tweets"
        }
        
        return cell
    }
}

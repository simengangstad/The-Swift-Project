//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Simen Gangstad on 03.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tweeters: UIBarButtonItem!
    
    var managedObjectContext: NSManagedObjectContext? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            tweets.removeAll()
            searchForTweets()
            title = searchText
        }
    }
    
    private var twitterRequest: Twitter.Request? {
        if let query = searchText, !query.isEmpty {
            return Twitter.Request(search: query + " -filter:retweets", count: 100)
        }
        else {
            return nil
        }
    }
    
    private var lastTwitterRequest: Twitter.Request?
    
    private func searchForTweets() {
        //navigationItem.rightBarButtonItem = activityIndicatorBarButtonItem
        //activityIndicatorView.startAnimating()
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets() { [weak self] (newTweets) in
                DispatchQueue.main.async() {
                    if request == self?.lastTwitterRequest {
                        //self?.activityIndicatorView.stopAnimating()
                        //self?.navigationItem.rightBarButtonItem = self?.tweeters
                        if !newTweets.isEmpty {
                            self?.tweets.insert(newTweets, at: 0)
                            self?.updateDatabase(newTweets: newTweets)
                        }
                    }
                }
            }
        }
    }
    
    private let activityIndicatorBarButtonItem = UIBarButtonItem(customView: UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white))
    
    private var activityIndicatorView: UIActivityIndicatorView {
    
        get {
            return activityIndicatorBarButtonItem.customView as! UIActivityIndicatorView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension

        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.color = UIColor.blue
    }
    
    private func updateDatabase(newTweets: [Tweet]) {
        managedObjectContext?.perform { [weak self] in
            for twitterInfo in newTweets {
                _ = TweetData.tweetWithTwitterInfo(twitterInfo: twitterInfo, inManagedObjectContext: (self?.managedObjectContext!)!)
            }
            
            do {
                
                try self?.managedObjectContext?.save()
            }
            catch let error {
                print("Core Data Error: \(error)")
            }
        }
        
        printDatabaseStatistics()
        print("Done printing database statistics")
    }
    
    private func printDatabaseStatistics() {
        managedObjectContext?.perform {
            if let results = try? self.managedObjectContext!.fetch(TwitterUser.fetchRequest() as NSFetchRequest<TwitterUser>) {
                print("\(results.count) users")
            }
            
            let tweetCount = try? self.managedObjectContext!.count(for: TweetData.fetchRequest() as NSFetchRequest<TweetData>)
            print("\(tweetCount!) tweets")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.TweetCellIdentifier, for: indexPath)
        let tweet = tweets[indexPath.section][indexPath.row]
        
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }
        
        return cell
    }
    
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        Storage.saveToRecent(string: searchText!)
        return true
    }
    
     // MARK: - Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Detail" {
            if let tweetDetailController = segue.destination as? TweetDetailTableViewController {
                tweetDetailController.tweet = (sender as? TweetTableViewCell)?.tweet!
                tweetDetailController.navigationItem.title = (sender as? TweetTableViewCell)?.tweet!.user.name
            }
        }
        else if segue.identifier == "TweetersMentioningSearchTerm" {
            if let tweetersTVC = segue.destination as? TweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.managedObjectContext = managedObjectContext
            }
        }
     }
}

//
//  TweetDetailTableViewController.swift
//  Smashtag
//
//  Created by Simen Gangstad on 05.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit
import Twitter

class TweetDetailTableViewController: UITableViewController {
    
    enum CellIdentifier: String {
        case MediaItem = "Image"
        case Mention = "Mention"
    }
    
    struct Section {
        let name: String
        var content = [AnyObject]()
        let identifier : CellIdentifier
        let whenClicked : (_ indexPath: IndexPath) -> Void
    }
    
    var tweet: Tweet? {
        didSet {
            sections.removeAll()
            
            addAssociatedContent(content: tweet!.media,
                                 forName: "Images",
                                 withIdentifier: CellIdentifier.MediaItem,
                                 whenClicked: {[weak self] in self?.performSegue(withIdentifier: "Show Image", sender: (self?.sections[$0.section].content as! [MediaItem])[$0.row].url)})
            addAssociatedContent(content: tweet!.hashtags,
                                 forName: "Hashtags",
                                 withIdentifier: CellIdentifier.Mention,
                                 whenClicked: {[weak self] in self?.performSegue(withIdentifier: "Show Mentions", sender: (self?.sections[$0.section].content as! [Mention])[$0.row].keyword)})
            addAssociatedContent(content: tweet!.urls,
                                 forName: "Links",
                                 withIdentifier: CellIdentifier.Mention,
                                 whenClicked: { [weak self] in
                                    let url = URL(string: (self?.sections[$0.section].content[$0.row] as! Mention).keyword)
                                    UIApplication.shared.open(url!)
            })
            addAssociatedContent(content: tweet!.userMentions,
                                 forName: "Users",
                                 withIdentifier: CellIdentifier.Mention,
                                 whenClicked: {[weak self] in self?.performSegue(withIdentifier: "Show Mentions", sender: (self?.sections[$0.section].content as! [Mention])[$0.row].keyword)})
            tableView.reloadData()
        }
    }
    
    private func addAssociatedContent(content: [AnyObject], forName name: String, withIdentifier identifier: CellIdentifier, whenClicked: @escaping (_ indexPath: IndexPath) -> Void) {
        if (!content.isEmpty) {
            sections.append(Section(name: name, content: content, identifier: identifier, whenClicked: whenClicked))
        }
    }
    
    var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension*/
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].content.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sections[indexPath.section].whenClicked(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (sections[indexPath.section].identifier == .MediaItem) {
            let mediaItem = (sections[indexPath.section].content[indexPath.row] as! MediaItem)
            return CGFloat(1.0 / mediaItem.aspectRatio) * tableView.bounds.width
        }
        else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sections[indexPath.section].identifier.rawValue, for: indexPath)
        
        switch sections[indexPath.section].identifier {
        case .MediaItem:
            
            if let mediaItemCell = cell as? MediaItemTableViewCell {
                mediaItemCell.mediaItem = (sections[indexPath.section].content[indexPath.row] as? MediaItem)
                
                return mediaItemCell
            }
            
        default:
            cell.textLabel!.text = (sections[indexPath.section].content[indexPath.row] as? Mention)?.keyword
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch (segue.identifier!)  {
        case "Show Image":
            
            if let destinationViewController = segue.destination as? ImageViewController {
                destinationViewController.imageURL = (sender as! URL)
            }
        case "Show Mentions":
            if let destinationViewController = segue.destination as? TweetTableViewController {
                destinationViewController.searchText = sender as? String
            }
            
        default: break
        }
    }
}

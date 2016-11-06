//
//  TweetTableViewCell.swift
//
//
//  Created by Simen Gangstad on 03.11.2016.
//
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private var colourDictionary = [
        "#":UIColor.red,
        "@":UIColor.orange,
        "http":UIColor.blue,
        "https":UIColor.blue
    ]
    
    private func addColourToString(string: String, withRange range: NSRange, inAttributedString attributedString: NSMutableAttributedString) {
        var prefix : String?
        for (prefixString, _) in colourDictionary {
            if (string.hasPrefix(prefixString)) {
                prefix = prefixString
            }
        }
        
        if (prefix != nil) {
            attributedString.addAttribute(NSForegroundColorAttributeName, value: colourDictionary[prefix!]!, range: range)
        }
    }
    
    var lastProfileImageURL : URL?
    
    private func updateUI() {
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        if let tweet = self.tweet {
            
            let text = NSMutableAttributedString(string: tweet.text)
            for _ in tweet.media {
                text.append(NSMutableAttributedString(string: " 📷"))
            }
            
            var mentionsArray = [Mention]()
            mentionsArray.append(contentsOf: tweet.hashtags)
            mentionsArray.append(contentsOf: tweet.urls)
            mentionsArray.append(contentsOf: tweet.userMentions)
            for mention in mentionsArray {
                addColourToString(string: mention.keyword, withRange: mention.nsrange, inAttributedString: text)
            }
            
            tweetTextLabel?.attributedText = text
            tweetScreenNameLabel?.text = "\(tweet.user)"
            
            if let profileImageURL = tweet.user.profileImageURL {
                lastProfileImageURL = profileImageURL
                
                DispatchQueue.global(qos: .userInitiated).async { [weak weakSelf = self] in
                    do {
                        let imageData = try Data(contentsOf: profileImageURL)
                        
                        DispatchQueue.main.async {
                            
                            if (profileImageURL == weakSelf?.lastProfileImageURL) {
                                weakSelf?.tweetProfileImageView?.image = UIImage(data: imageData)
                            }
                            else {
                                print("Ignored data from url: \(weakSelf?.lastProfileImageURL)")
                            }
                        }
                    }
                    catch {
                        print("Image from \(weakSelf?.lastProfileImageURL) could not be fetched")
                        DispatchQueue.main.async {
                            weakSelf?.tweetProfileImageView?.image = nil
                        }
                    }
                }
            }
            
            let formatter = DateFormatter()
            if NSDate().timeIntervalSince(tweet.created) > 24*60*60 {
                formatter.dateStyle = DateFormatter.Style.short
            }
            else  {
                formatter.timeStyle = DateFormatter.Style.short
            }
            
            tweetCreatedLabel?.text = formatter.string(from: tweet.created)
        }
    }
}

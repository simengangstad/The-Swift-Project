//
//  TweetData+CoreDataClass.swift
//  Smashtag
//
//  Created by Simen Gangstad on 08.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData
import Twitter

@objc(TweetData)
public class TweetData: NSManagedObject {

    class func tweetWithTwitterInfo(twitterInfo: Tweet, inManagedObjectContext context: NSManagedObjectContext) -> TweetData? {
        
        let request: NSFetchRequest<TweetData> = TweetData.fetchRequest()
        request.predicate = NSPredicate(format: "unique = %@", twitterInfo.id)
        
        if let tweet = (try? context.fetch(request))?.first {
                        
            return tweet
        }
        else if let tweet = NSEntityDescription.insertNewObject(forEntityName: "TweetData", into: context) as? TweetData {

            tweet.unique = twitterInfo.id
            tweet.text = twitterInfo.text
            tweet.posted = twitterInfo.created as NSDate?
            tweet.tweeter = TwitterUser.twitterUserWithTwitterInfo(twitterInfo: twitterInfo.user, inManagedObjectContext: context)
                        
            return tweet
        }
        
        return nil
    }
}

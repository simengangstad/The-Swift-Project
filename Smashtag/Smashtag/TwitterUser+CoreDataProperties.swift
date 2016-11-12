//
//  TwitterUser+CoreDataProperties.swift
//  Smashtag
//
//  Created by Simen Gangstad on 12.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import Foundation
import CoreData


extension TwitterUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TwitterUser> {
        return NSFetchRequest<TwitterUser>(entityName: "TwitterUser");
    }

    @NSManaged public var name: String?
    @NSManaged public var screenName: String?
    @NSManaged public var tweets: NSSet?

}

// MARK: Generated accessors for tweets
extension TwitterUser {

    @objc(addTweetsObject:)
    @NSManaged public func addToTweets(_ value: TweetData)

    @objc(removeTweetsObject:)
    @NSManaged public func removeFromTweets(_ value: TweetData)

    @objc(addTweets:)
    @NSManaged public func addToTweets(_ values: NSSet)

    @objc(removeTweets:)
    @NSManaged public func removeFromTweets(_ values: NSSet)

}

//
//  TweetData+CoreDataProperties.swift
//  Smashtag
//
//  Created by Simen Gangstad on 12.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import Foundation
import CoreData


extension TweetData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TweetData> {
        return NSFetchRequest<TweetData>(entityName: "TweetData");
    }

    @NSManaged public var posted: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var unique: String?
    @NSManaged public var tweeter: TwitterUser?

}

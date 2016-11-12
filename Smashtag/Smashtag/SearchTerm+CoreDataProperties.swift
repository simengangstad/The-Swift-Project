//
//  SearchTerm+CoreDataProperties.swift
//  Smashtag
//
//  Created by Simen Gangstad on 12.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import Foundation
import CoreData


extension SearchTerm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchTerm> {
        return NSFetchRequest<SearchTerm>(entityName: "SearchTerm");
    }

    @NSManaged public var value: String?
    @NSManaged public var mentions: NSSet?

}

// MARK: Generated accessors for mentions
extension SearchTerm {

    @objc(addMentionsObject:)
    @NSManaged public func addToMentions(_ value: MentionData)

    @objc(removeMentionsObject:)
    @NSManaged public func removeFromMentions(_ value: MentionData)

    @objc(addMentions:)
    @NSManaged public func addToMentions(_ values: NSSet)

    @objc(removeMentions:)
    @NSManaged public func removeFromMentions(_ values: NSSet)

}

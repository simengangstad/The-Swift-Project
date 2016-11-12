//
//  MentionData+CoreDataClass.swift
//  Smashtag
//
//  Created by Simen Gangstad on 11.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import Foundation
import CoreData
import Twitter

@objc(MentionData)
public class MentionData: NSManagedObject {

    class func mentionData(withMention mention: Mention, andSearchText searchText: String, inManagedObjectContext context: NSManagedObjectContext, forNewTweet newTweet: Bool) -> MentionData? {
        let request: NSFetchRequest<MentionData> = MentionData.fetchRequest()
        request.predicate = NSPredicate(format: "value = %@ and searchTerm.value = %@", mention.keyword, searchText)
        
        if let mention = (try? context.fetch(request))?.first {
            if (newTweet) {
                mention.count += 1
            }
            return mention
        }
        else if let mentionData = NSEntityDescription.insertNewObject(forEntityName: "MentionData", into: context) as? MentionData {
            mentionData.count = 1
            mentionData.value = mention.keyword
            mentionData.searchTerm = SearchTerm.searchTerm(withSearchText: searchText, inManagedObjectContext: context)
            return mentionData
        }
        
        return nil
    }
}

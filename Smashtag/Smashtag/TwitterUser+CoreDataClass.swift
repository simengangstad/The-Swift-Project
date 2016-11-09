//
//  TwitterUser+CoreDataClass.swift
//  Smashtag
//
//  Created by Simen Gangstad on 08.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData
import Twitter

@objc(TwitterUser)
public class TwitterUser: NSManagedObject {

    class func twitterUserWithTwitterInfo(twitterInfo: Twitter.User, inManagedObjectContext context: NSManagedObjectContext) -> TwitterUser? {
        
        let request: NSFetchRequest<TwitterUser> = TwitterUser.fetchRequest()
        request.predicate = NSPredicate(format: "(screenName = %@)", argumentArray: [twitterInfo.screenName])

        if let twitterUser = (try? context.fetch(request))?.first {
            return twitterUser
        }
        else if let twitterUser = NSEntityDescription.insertNewObject(forEntityName: "TwitterUser", into: context) as? TwitterUser {

            twitterUser.screenName = twitterInfo.screenName
            twitterUser.name = twitterInfo.name
    
            return twitterUser
        }
        
        return nil
    }
}

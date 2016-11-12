//
//  MentionData+CoreDataProperties.swift
//  Smashtag
//
//  Created by Simen Gangstad on 12.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import Foundation
import CoreData


extension MentionData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MentionData> {
        return NSFetchRequest<MentionData>(entityName: "MentionData");
    }

    @NSManaged public var count: Int16
    @NSManaged public var value: String?
    @NSManaged public var searchTerm: SearchTerm?

}

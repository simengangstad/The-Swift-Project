//
//  SearchTerm+CoreDataClass.swift
//  Smashtag
//
//  Created by Simen Gangstad on 11.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import Foundation
import CoreData

@objc(SearchTerm)
public class SearchTerm: NSManagedObject {

    class func searchTerm(withSearchText searchText: String, inManagedObjectContext context: NSManagedObjectContext) -> SearchTerm? {
        
        let request: NSFetchRequest<SearchTerm> = SearchTerm.fetchRequest()
        request.predicate = NSPredicate(format: "value = %@", searchText)
        
        if let searchTerm = (try? context.fetch(request))?.first {
            return searchTerm
        }
        else if let searchTerm = NSEntityDescription.insertNewObject(forEntityName: "SearchTerm", into: context) as? SearchTerm {
            searchTerm.value = searchText
            return searchTerm
        }
        
        return nil
    }
}

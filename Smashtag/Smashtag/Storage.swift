//
//  Storage.swift
//  Smashtag
//
//  Created by Simen Gangstad on 05.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class Storage {
    private static let userDefaults = UserDefaults.standard
    private static let recentKey = "recent_searches"
    
    static func saveToRecent(string: String) {
    
        var array = getRecents()
        
        if array == nil {
            array = [String]()
        }
        
        array!.append(string)
        
        Storage.userDefaults.set(array, forKey: recentKey)
    }
    
    static func getRecents() -> [String]? {
        return Storage.userDefaults.array(forKey: recentKey) as? [String]
    }
}

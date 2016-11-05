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
        if var array = getRecents() {
            array.append(string)
            Storage.userDefaults.set(array, forKey: recentKey)
            if !Storage.userDefaults.synchronize() {
                print("Couldn't save to user defaults")
            }
        }
    }
    
    static func getRecents() -> [String]? {
        return Storage.userDefaults.array(forKey: recentKey) as? [String]
    }
}

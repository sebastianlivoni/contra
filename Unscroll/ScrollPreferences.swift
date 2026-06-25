//
//  ScrollPreferences.swift
//  Unscroll
//
//  Created by Sebastian on 25/06/2026.
//

import Foundation

struct ScrollPreferences {
    static var isNaturalScrollingEnabled: Bool {
        // The global key used by macOS for natural scrolling
        let key = "com.apple.swipescrolldirection"
        
        // Check if the key exists in the standard/global defaults search list
        return UserDefaults.standard.bool(forKey: key)
    }
    
    static var scrollingDirectionString: String {
        return isNaturalScrollingEnabled ? "Natural" : "Traditional (Normal)"
    }
}

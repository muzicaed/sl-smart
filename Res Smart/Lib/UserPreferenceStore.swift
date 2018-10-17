//
//  UserPreferenceStore.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-03-06.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

open class UserPreferenceStore {
    
    fileprivate let LastRealTimeTripType = "USER-LastRealTimeTripType"
    fileprivate let defaults = UserDefaults.standard
    fileprivate var lastRealTimeTripTypeCache: String?
    
    // Singelton pattern
    static let sharedInstance = UserPreferenceStore()
    
    /**
     * Returns user's last real time trip type.
     */
    func getLastRealTimeTripType() -> String? {
        if lastRealTimeTripTypeCache == nil {
            lastRealTimeTripTypeCache = defaults.string(forKey: LastRealTimeTripType)
        }
        
        return lastRealTimeTripTypeCache
    }
    
    /**
     * Set user's last real time trip type.
     */
    func setLastRealTimeTripType(_ lastRealTimeTripType: String) {
        lastRealTimeTripTypeCache = lastRealTimeTripType
        defaults.set(lastRealTimeTripTypeCache, forKey: LastRealTimeTripType)
    }
}

//
//  ScorePostStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class ScorePostStore {
    
    fileprivate let ScoreList = "ScoreList"
    fileprivate let defaults = UserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
    fileprivate var cachedScorePosts = [ScorePost]()
    public var lastReloaded = Date()
    
    // Singelton pattern
    public static let sharedInstance = ScorePostStore()
    
    /**
     * Retrive "ScoreList" from data store
     */
    public func retrieveScorePosts() -> [ScorePost] {
        if cachedScorePosts.count == 0 || Date().timeIntervalSince(lastReloaded) > 60 {
            if let unarchivedObject = defaults.object(forKey: ScoreList) as? Data {
                if let scorePosts = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [ScorePost] {
                    cachedScorePosts = scorePosts
                    self.lastReloaded = Date()
                }
            }
        }
        return cachedScorePosts.map { ($0.copy() as! ScorePost) }
    }
    
    /**
     * Store score lists to "ScoreList" in data store
     */
    public func writeScorePosts(_ scorePosts: [ScorePost]) {
        var filteredPosts = [ScorePost]()
        for post in scorePosts {
            if post.score > 0 {
                filteredPosts.append(post.copy() as! ScorePost)
            }
        }
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: filteredPosts)
        defaults.set(archivedObject, forKey: ScoreList)
        cachedScorePosts = filteredPosts
    }
}

//
//  ScorePostStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class ScorePostStore {
  
  private let ScoreList = "ScoreList"
  private let defaults = NSUserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
  private var cachedScorePosts = [ScorePost]()
  public var lastReloaded = NSDate()
  
  // Singelton pattern
  public static let sharedInstance = ScorePostStore()  
  
  /**
   * Retrive "ScoreList" from data store
   */
  public func retrieveScorePosts() -> [ScorePost] {
    if cachedScorePosts.count == 0 || NSDate().timeIntervalSinceDate(lastReloaded) > 60 {
      if let unarchivedObject = defaults.objectForKey(ScoreList) as? NSData {
        if let scorePosts = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [ScorePost] {
          cachedScorePosts = scorePosts
          self.lastReloaded = NSDate()
        }
      }
    }
    return cachedScorePosts.map { ($0.copy() as! ScorePost) }
  }
  
  /**
   * Store score lists to "ScoreList" in data store
   */
  public func writeScorePosts(scorePosts: [ScorePost]) {
    var filteredPosts = [ScorePost]()
    for post in scorePosts {
      if post.score > 0 {
        filteredPosts.append(post.copy() as! ScorePost)
      }
    }
    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(filteredPosts)
    defaults.setObject(archivedObject, forKey: ScoreList)
    cachedScorePosts = filteredPosts
  }
}
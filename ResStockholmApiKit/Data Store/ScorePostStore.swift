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
  
  // Singelton pattern
  public static let sharedInstance = ScorePostStore()
  
  /**
   * Preloads routine trip data.
   */
  public func preload() {
    cachedScorePosts = retrieveScorePosts()
  }
  
  /**
   * Retrive "ScoreList" from data store
   */
  public func retrieveScorePosts() -> [ScorePost] {
    if cachedScorePosts.count == 0 {
      if let unarchivedObject = defaults.objectForKey(ScoreList) as? NSData {
        if let scorePosts = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [ScorePost] {
          cachedScorePosts = scorePosts
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
    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(filteredPosts as NSArray)
    defaults.setObject(archivedObject, forKey: ScoreList)
    cachedScorePosts = filteredPosts
    defaults.synchronize()
  }
}
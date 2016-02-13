//
//  DataMigration.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-02-01.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit

class DataMigration {
  
  private static let dataKey = "RES-SMART-CURRENT-MIGRATION-STEP"
  private static let defaults = NSUserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
  
  static func migrateData() {
    let step = defaults.integerForKey(dataKey)
    if step < 1 {
      migration1()
    }
    
    defaults.synchronize()
  }
  
  /**
   * Migration 1
   */
  static private func migration1() {
    // Clear all score posts. Data structure changes to score post.
    ScorePostStore.sharedInstance.writeScorePosts([ScorePost]())
    defaults.setInteger(1, forKey: dataKey)
  }
}
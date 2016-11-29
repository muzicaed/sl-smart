//
//  ExtensionDelegate.swift
//  SL Smart WatchKit Extension
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
  
  let notificationCenter = NotificationCenter.default
  let session = WCSession.default()
  
  override init() {
    super.init()
    session.delegate = self
    session.activate()
  }
  
  
  func applicationDidFinishLaunching() {}
  
  func applicationDidBecomeActive() {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillResignActive() {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
  }
  
  // MARK: WCSessionDelegate
  
  func sessionWatchStateDidChange(_ session: WCSession) {
    func sessionReachabilityDidChange(_ session: WCSession) {
      if session.isReachable {
        notificationCenter.post(name: Notification.Name(rawValue: "SessionBecameReachable"), object: nil)
        return
      }
      notificationCenter.post(name: Notification.Name(rawValue: "SessionNoLongerReachable"), object: nil)
    }
  }
  
  func sessionReachabilityDidChange(_ session: WCSession) {
    if session.isReachable {
      notificationCenter.post(name: Notification.Name(rawValue: "SessionBecameReachable"), object: nil)
      return
    }
    notificationCenter.post(name: Notification.Name(rawValue: "SessionNoLongerReachable"), object: nil)
  }
}

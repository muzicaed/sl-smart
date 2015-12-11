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
  
  let notificationCenter = NSNotificationCenter.defaultCenter()
  let session = WCSession.defaultSession()
  
  override init() {
    print("ExtensionDelegate init()")
    super.init()
    session.delegate = self
    session.activateSession()
  }
  
  
  func applicationDidFinishLaunching() {
    print("ExtensionDelegate applicationDidFinishLaunching")
  }
  
  func applicationDidBecomeActive() {
    print("ExtensionDelegate applicationDidBecomeActive")
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillResignActive() {
    print("ExtensionDelegate applicationWillResignActive")
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
  }
  
  // MARK: WCSessionDelegate
  
  func sessionWatchStateDidChange(session: WCSession) {
    func sessionReachabilityDidChange(session: WCSession) {
      print("ExtensionDelegate sessionReachabilityDidChange")
      print("reachable: \(session.reachable)")
      if session.reachable {
        notificationCenter.postNotificationName("SessionBecameReachable", object: nil)
        return
      }
      notificationCenter.postNotificationName("SessionNoLongerReachable", object: nil)
    }
  }
  
  func sessionReachabilityDidChange(session: WCSession) {
    print("ExtensionDelegate sessionReachabilityDidChange")
    print("reachable: \(session.reachable)")
    if session.reachable {
      notificationCenter.postNotificationName("SessionBecameReachable", object: nil)
      return
    }
    notificationCenter.postNotificationName("SessionNoLongerReachable", object: nil)
  }
}

//
//  AppDelegate.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import UIKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
  
  var window: UIWindow?
  
  // MARK: UIApplicationDelegate
  
  func application(
    application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
      setupAppleWatchConnection()
      setupApp()
      return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  // MARK: WCSessionDelegate
  
  func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
    
    print("Received message: \(message["action"] as! String)")
    
    let action = message["action"] as! String
    dispatch_async(dispatch_get_main_queue()) {
      switch action {
      case "RequestRoutineTrips":
        WatchService.requestRoutineTrips() { response in
          replyHandler(response)
        }
      case "SearchTrips":
        let originId = message["oid"] as! Int
        let destId = message["did"] as! Int
        WatchService.searchTrips(originId, destinationId: destId) { response in
          replyHandler(response)
        }
      default:
        fatalError("Unknown WCSession message.")
      }
    }
  }
  
  //MARK: Private
  
  /**
  * Prepares the app.
  */
  private func setupApp() {
    StyleHelper.sharedInstance.setupCustomStyle()
    window?.tintColor = StyleHelper.sharedInstance.tintColor
    DataStore.sharedInstance.preload()
    MyLocationHelper.sharedInstance.requestLocationUpdate(nil)
  }
  
  /**
   * Prepares AppleWatch session.
   */
  private func setupAppleWatchConnection() {
    if (WCSession.isSupported()) {
      let defaultSession = WCSession.defaultSession()
      defaultSession.delegate = self
      defaultSession.activateSession()
    }
  }
}



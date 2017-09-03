//
//  AppDelegate.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import UIKit
import WatchConnectivity
import ResStockholmApiKit
import UserNotifications

//TODO: Move WCSessionDelegate out to a helper object
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
  
  var window: UIWindow?
  let notificationCenter = NotificationCenter.default
  
  // MARK: UIApplicationDelegate
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    self.window?.backgroundColor = UIColor(red: 244/255, green: 255/255, blue: 249/255, alpha: 1.0)
    DataMigration.migrateData()
    setupAppleWatchConnection()
    setupApp()
    
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    let defaults = UserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
    defaults.synchronize()
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {    
    checkTrafficSituation()
    
    let root = window?.rootViewController! as! CustomTabVC
    root.updateTabs()
    
    DispatchQueue.global(qos: .default).async {
      // Load stops in background
      let _ = StopsStore.sharedInstance.getStops()
    }
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  // MARK: WCSessionDelegate
  
  func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
    
    let message = NSKeyedUnarchiver.unarchiveObject(with: messageData)! as! Dictionary<String, AnyObject>
    let action = message["action"] as! String
    DispatchQueue.main.async {
      switch action {
      case "RequestRoutineTrips":
        WatchService.requestRoutineTrips() { response in
          let data = NSKeyedArchiver.archivedData(withRootObject: response)
          replyHandler(data)
        }
      case "SearchTrips":
        let routineTripId = message["id"] as! String
        WatchService.searchTrips(routineTripId) { response in
          let data = NSKeyedArchiver.archivedData(withRootObject: response)
          replyHandler(data)
        }
      case "SearchLastTrip":
        WatchService.lastTripSearch() { response in
          let data = NSKeyedArchiver.archivedData(withRootObject: response)
          replyHandler(data)
        }
      default:
        fatalError("Unknown WCSession message.")
      }
    }
  }
  
  /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
  @available(iOS 9.3, *)
  public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
  }
  
  /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
  @available(iOS 9.3, *)
  public func sessionDidBecomeInactive(_ session: WCSession) {
  }
  
  @available(iOS 9.3, *)
  public func sessionDidDeactivate(_ session: WCSession) {}
  
  
  //MARK: Private
  
  /**
   * Prepares the app.
   */
  fileprivate func setupApp() {
    StyleHelper.sharedInstance.setupCustomStyle()
    window?.tintColor = StyleHelper.sharedInstance.tintColor
    RoutineTripsStore.sharedInstance.preload()
  }
  
  /**
   * Prepares AppleWatch session.
   */
  fileprivate func setupAppleWatchConnection() {
    if (WCSession.isSupported()) {
      let defaultSession = WCSession.default
      defaultSession.delegate = self
      defaultSession.activate()
    }
  }
  
  /**
   * Checks current traffic situation.
   */
  fileprivate func checkTrafficSituation() {
    NetworkActivity.displayActivityIndicator(true)
    TrafficSituationService.fetchInformation() {data, error in
      NetworkActivity.displayActivityIndicator(false)
      if error != nil {
        return
      }
      
      var count = 0
      for group in data {
        for situation in group.situations {
          if situation.statusIcon != "EventGood" && situation.statusIcon != "EventPlanned" {
            count += 1
          }
        }
      }
      self.notificationCenter.post(name: Notification.Name(rawValue: "TrafficSituations"), object: count)
    }
  }
}


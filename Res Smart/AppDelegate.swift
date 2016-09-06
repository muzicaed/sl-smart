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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
  
  var window: UIWindow?
  let notificationCenter = NSNotificationCenter.defaultCenter()
  
  // MARK: UIApplicationDelegate
  
  func application(
    application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    DataMigration.migrateData()
    setupAppleWatchConnection()
    setupApp()
    setupLocalNotifications()
    
    // TODO: Remove test code
    StopsStore.sharedInstance.getStops()
    
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    let defaults = NSUserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
    defaults.synchronize()
    
    let notification = UILocalNotification()
    notification.fireDate = NSDate(timeIntervalSinceNow: (60*60*24*7))
    notification.alertBody = "Du har väll inte glömt mig? 😄"
    UIApplication.sharedApplication().scheduledLocalNotifications = [notification]
  }
  
  func applicationWillEnterForeground(application: UIApplication) {}
  
  func applicationDidBecomeActive(application: UIApplication) {
    SubscriptionStore.sharedInstance.setupTrial()
    SubscriptionManager.sharedInstance.validateSubscription()
    checkTrafficSituation()
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  // MARK: WCSessionDelegate
  
  func session(session: WCSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void) {
    
    let message = NSKeyedUnarchiver.unarchiveObjectWithData(messageData)! as! Dictionary<String, AnyObject>
    let action = message["action"] as! String
    dispatch_async(dispatch_get_main_queue()) {
      switch action {
      case "RequestRoutineTrips":
        WatchService.requestRoutineTrips() { response in
          let data = NSKeyedArchiver.archivedDataWithRootObject(response)
          replyHandler(data)
        }
      case "SearchTrips":
        let routineTripId = message["id"] as! String
        WatchService.searchTrips(routineTripId) { response in
          let data = NSKeyedArchiver.archivedDataWithRootObject(response)
          replyHandler(data)
        }
      case "SearchLastTrip":
        WatchService.lastTripSearch() { response in
          let data = NSKeyedArchiver.archivedDataWithRootObject(response)
          replyHandler(data)
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
    RoutineTripsStore.sharedInstance.preload()
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
  
  
  /**
   * Checks current traffic situation.
   */
  private func checkTrafficSituation() {
    NetworkActivity.displayActivityIndicator(true)
    TrafficSituationService.fetchInformation() {data, error in
      NetworkActivity.displayActivityIndicator(false)
      dispatch_async(dispatch_get_main_queue()) {
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
        self.notificationCenter.postNotificationName("TrafficSituations", object: count)
      }
    }
  }
  
  /**
   * Register for local notifications.
   */
  private func setupLocalNotifications() {
    let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert], categories: nil)
    UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
  }
}



//
//  AppDelegate.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import UIKit
import ResStockholmApiKit
import UserNotifications

//TODO: Move WCSessionDelegate out to a helper object
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let notificationCenter = NotificationCenter.default
    let watchManager = WatchManager()
    
    // MARK: UIApplicationDelegate
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window?.backgroundColor = UIColor(red: 244/255, green: 255/255, blue: 249/255, alpha: 1.0)
        DataMigration.migrateData()
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


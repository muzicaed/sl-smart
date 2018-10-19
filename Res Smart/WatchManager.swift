//
//  WatchManager.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2018-10-19.
//  Copyright © 2018 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit
import WatchConnectivity

class WatchManager: NSObject, WCSessionDelegate {
    
    fileprivate var defaultSession = WCSession.default
    
    override init() {
        super.init()
        print("WatchManager init()")
        if (WCSession.isSupported()) {
            defaultSession.delegate = self
            defaultSession.activate()
        }
    }
    
    // MARK: WCSessionDelegate
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        let message = NSKeyedUnarchiver.unarchiveObject(with: messageData)! as! Dictionary<String, AnyObject>
        let action = message["action"] as! String
        
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
    
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    }
    
    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {}
}

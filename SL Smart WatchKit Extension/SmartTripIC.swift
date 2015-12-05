//
//  SmartTripIC.swift
//  SL Smart WatchKit Extension
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class SmartTripIC: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var departureTimeLabel: WKInterfaceLabel!
    @IBOutlet var originLabel: WKInterfaceLabel!
    @IBOutlet var destinationLabel: WKInterfaceLabel!
    @IBOutlet var travelTypeIconWrapper: WKInterfaceGroup!
    
    var session : WCSession?
    
    /**
     * On load.
     */
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        print("awakeWithContext")
    }
    
    /**
     * About to show on screen.
     */
    override func willActivate() {
        super.willActivate()
        print("willActivate")
        setupPhoneConnection()
        if let sess = session {
            print("Send message.")
            sess.sendMessage(["action": "requestRoutineTrips"],
                replyHandler: requestRoutineTripsHandler,
                errorHandler: messageErrorHandler)
        }
    }
    
    /**
     * Did disapear from screen.
     */
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    /**
     * Handle reply for a "requestRoutineTrips" message.
     */
    func requestRoutineTripsHandler(reply: [String: AnyObject]) {
        //let bestTrip = reply["best"] as! Dictionary<String, AnyObject>

        print("Recived Response")
        print("\(reply["best"])")
    }
    
    /**
     * Handles any session send messages errors.
     */
    func messageErrorHandler(error: NSError) {
        fatalError("Message error: \(error)")
    }
    
    // MARK private
    
    private func setupPhoneConnection() {
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            if let defaultSession = session {
                print("Created WCSession.")
                defaultSession.delegate = self;
                defaultSession.activateSession()
            } else {
                print("No WCSession.")
            }
        }
    }
}

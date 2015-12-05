//
//  GlanceController.swift
//  SL Smart WatchKit Extension
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class GlanceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var loadingLabel: WKInterfaceLabel!
    @IBOutlet var contentGroup: WKInterfaceGroup!
    @IBOutlet var departureLabel: WKInterfaceLabel!
    @IBOutlet var originLabel: WKInterfaceLabel!
    @IBOutlet var destinationLabel: WKInterfaceLabel!
    
    var session : WCSession?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    
    /**
     * About to show on screen.
     */
    override func willActivate() {
        super.willActivate()
        loadingLabel.setHidden(false)
        contentGroup.setHidden(true)
        setupPhoneConnection()
        if let sess = session {
            print("Send message.")
            sess.sendMessage(["action": "requestRoutineTrips"],
                replyHandler: requestRoutineTripsHandler,
                errorHandler: messageErrorHandler)
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    /**
     * Handle reply for a "requestRoutineTrips" message.
     */
    func requestRoutineTripsHandler(reply: [String: AnyObject]) {
        let routineTripData = reply["best"] as! Dictionary<String, AnyObject>
        print("\(routineTripData)")
        titleLabel.setText(routineTripData["tit"] as? String)
        originLabel.setText(routineTripData["ori"] as? String)
        destinationLabel.setText(routineTripData["des"] as? String)
        departureLabel.setText(routineTripData["dep"] as? String)
        
        loadingLabel.setHidden(true)
        contentGroup.setHidden(false)
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
                defaultSession.delegate = self;
                defaultSession.activateSession()
            } else {
                print("No WCSession.")
            }
        }
    }
}

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
    
    @IBOutlet var containerGroup: WKInterfaceGroup!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var departureTimeLabel: WKInterfaceLabel!
    @IBOutlet var originLabel: WKInterfaceLabel!
    @IBOutlet var destinationLabel: WKInterfaceLabel!
    @IBOutlet var travelTypeIconWrapper: WKInterfaceGroup!
    @IBOutlet var loadingLabel: WKInterfaceLabel!
    
    var session : WCSession?
    
    /**
     * On load.
     */
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        print("awakeWithContext")
        setupPhoneConnection()
    }
    
    /**
     * About to show on screen.
     */
    override func willActivate() {
        super.willActivate()
    }
    
    override func didAppear() {
        super.willActivate()
        containerGroup.setHidden(true)
        self.loadingLabel.setHidden(false)
        if let sess = session {
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
        let routineTripData = reply["best"] as! Dictionary<String, AnyObject>
        print("\(reply["bestTripData"])")
        titleLabel.setText(routineTripData["tit"] as? String)
        originLabel.setText(routineTripData["ori"] as? String)
        destinationLabel.setText(routineTripData["des"] as? String)
        departureTimeLabel.setText(routineTripData["dep"] as? String)

        self.animateWithDuration(0.4, animations: {
            self.loadingLabel.setHidden(true)
            self.containerGroup.setHidden(false)
            
        })
    }
    
    /**
     * Handles any session send messages errors.
     */
    func messageErrorHandler(error: NSError) {
        fatalError("Message error: \(error)")
    }
    
    // MARK private
    
    /**
     * Sets up a WKSession with the partner iPhone
     */
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

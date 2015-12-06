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
    
    @IBOutlet var subTitleLabel: WKInterfaceLabel!
    @IBOutlet var contentGroup: WKInterfaceGroup!
    @IBOutlet var departureLabel: WKInterfaceLabel!
    @IBOutlet var originLabel: WKInterfaceLabel!
    @IBOutlet var destinationLabel: WKInterfaceLabel!
    
    var session : WCSession?

    /**
     * About to show on screen.
     */
    override func willActivate() {
        super.willActivate()
        print("awakeWithContext")
        setupPhoneConnection()
        reloadRoutineTripData()
    }

    /**
     * Handle reply for a "requestRoutineTrips" message.
     */
    func requestRoutineTripsHandler(reply: [String: AnyObject]) {
        let routineTripData = reply["best"] as! Dictionary<String, AnyObject>
        print("\(routineTripData)")
        originLabel.setText(routineTripData["ori"] as? String)
        destinationLabel.setText(routineTripData["des"] as? String)
        departureLabel.setText(routineTripData["dep"] as? String)
        
        subTitleLabel.setText(routineTripData["tit"] as? String)
        subTitleLabel.setTextColor(UIColor.whiteColor())
        contentGroup.setHidden(false)
    }
    
    /**
     * Handles any session send messages errors.
     */
    func messageErrorHandler(error: NSError) {
        // TODO: Debug only. Replace with generic error message before publish.
        print("\(error)")
        displayError(error.localizedDescription)
    }
    
    // MARK private
    
    /**
    * Ask partner iPhone for new Routine Trip data
    */
    private func reloadRoutineTripData() {
        if ((session?.reachable) != nil) {
            setLoadingUIState()
            if let sess = session {
                sess.sendMessage(["action": "requestRoutineTrips"],
                    replyHandler: requestRoutineTripsHandler,
                    errorHandler: messageErrorHandler)
            }
        } else {
            displayError("Kan inte hitta din iPhone")
        }
    }
    
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
                displayError("Kan inte hitta din iPhone")
            }
        }
    }
    
    /**
     * Displays an error alert
     */
    private func displayError(title: String) {
        subTitleLabel.setText(title)
        subTitleLabel.setTextColor(UIColor.redColor())
    }
    
    /**
     * Updates UI to show "Loading..."
     */
    private func setLoadingUIState() {
        contentGroup.setHidden(true)
        subTitleLabel.setText("Söker resa...")
        subTitleLabel.setTextColor(UIColor.lightGrayColor())
    }
}

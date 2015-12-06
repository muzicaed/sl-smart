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
     * About to show on screen.
     */
    override func willActivate() {
        super.willActivate()
        print("willActivate")
        setupPhoneConnection()
        reloadRoutineTripData()
    }
    
    /**
     * Handle reply for a "requestRoutineTrips" message.
     */
    func requestRoutineTripsHandler(reply: [String: AnyObject]) {
        let routineTripData = reply["best"] as! Dictionary<String, AnyObject>
        print("Got reply")
        print("\(routineTripData)")
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
        // TODO: Debug only. Replace with generic error message before publish.
        displayErrorAlert("Fel", message: error.localizedDescription)
    }
    
    // MARK private
    
    /**
    * Ask partner iPhone for new Routine Trip data
    */
    private func reloadRoutineTripData() {
        if ((session?.reachable) != nil) {
            containerGroup.setHidden(true)
            loadingLabel.setHidden(false)
            if let sess = session {
                sess.sendMessage(["action": "requestRoutineTrips"],
                    replyHandler: requestRoutineTripsHandler,
                    errorHandler: messageErrorHandler)
            }
        } else {
            displayErrorAlert("Kan inte hitta din iPhone",
                message: "Det går inte att kommunicera med din iPhone. Kontrollera att den är laddad och finns i närheten.")
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
                displayErrorAlert("Kan inte hitta din iPhone",
                    message: "Det går inte att kommunicera med din iPhone. Kontrollera att den är laddad och finns i närheten.")
            }
        }
    }
    
    /**
     * Displays an error alert
     */
    private func displayErrorAlert(title: String, message: String) {
        let okAction = WKAlertAction(title: "Försök igen", style: .Default, handler: {})
        presentAlertControllerWithTitle(title,
            message: message, preferredStyle: .Alert, actions: [okAction])
    }
}

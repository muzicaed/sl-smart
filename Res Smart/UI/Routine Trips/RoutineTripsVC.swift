//
//  RoutineTripsVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-08-19.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit
import CoreLocation

class RoutineTripsVC: UITableViewController {
  
  /**
   * View is done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    /*
     setupNotificationListeners()
     setupRefreshController()
     IJProgressView.shared.showProgressView(navigationController!.view)
     self.collectionView?.alpha = 0.0
     */
  }
  
  /**
   * View is about to display.
   */
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    /*
     refreshScreen()
     */
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    /*
     stopRefreshTimmer()
     IJProgressView.shared.hideProgressView()
     */
  }
  
  // MARK: Private methods
  
  /**
   * Refresh screen and reload data.
   */
  fileprivate func refreshScreen() {
    //stopLoading()
    navigationItem.rightBarButtonItem?.isEnabled = true
    if CLLocationManager.authorizationStatus() == .denied || !CLLocationManager.locationServicesEnabled() {
      showLocationServicesNotAllowed()
      MyLocationHelper.sharedInstance.isStarted = false
      tableView?.reloadData()
      return
    }
    
    //startRefreshTimmer()
    RoutineTripsHelper.loadTripData(false)
  }
  
  /**
   * Show no location servie popup
   */
  fileprivate func showLocationServicesNotAllowed() {
    let invalidLocationAlert = UIAlertController(
      title: "Platstjänster ej aktiverad",
      message: "Kontrollera att platstjänster är aktiverade och att de tillåts för Res Smart.\n\n(Inställningar -> Integritetsskydd -> Platstjänster)",
      preferredStyle: UIAlertControllerStyle.alert)
    invalidLocationAlert.addAction(
      UIAlertAction(title: "Okej", style: .default, handler: nil))
    
    present(invalidLocationAlert, animated: true, completion: nil)
  }
}

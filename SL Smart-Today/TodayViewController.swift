//
//  TodayViewController.swift
//  SL Smart-Today
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var departureDescLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var arrivalDescLabel: UILabel!
  @IBOutlet weak var iconContainerView: UIView!
  @IBOutlet weak var travelTimeLabel: UILabel!
  
  //var bestRoutineTrip: RoutineTrip?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.preferredContentSize = CGSizeMake(0, 140)
    self.reloadData()
  }
  
  func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
    print("widgetPerformUpdateWithCompletionHandler")
    reloadData()
    completionHandler(NCUpdateResult.NewData)
  }
  
  // MARK: Private
  
  /**
  * Reloads the data
  */
  private func reloadData() {
    /*
    RoutineService.findRoutineTrip({ routineTrips in
      if routineTrips.count > 0 {
        self.bestRoutineTrip = routineTrips.first!
        dispatch_async(dispatch_get_main_queue(), {
          self.updateUI()
        })
      }
    })
*/
  }
  
  
  /**
   * Updates the UI based on data
   */
  private func updateUI() {
    if let routine = bestRoutineTrip {
      let trip = routine.trips.first!
      titleLabel.text = routine.title
      departureTimeLabel.text = DateUtils.dateAsTimeString(
        trip.tripSegments.first!.departureDateTime)
      arrivalTimeLabel.text = DateUtils.dateAsTimeString(
        trip.tripSegments.last!.arrivalDateTime)
    }
    
  }
}

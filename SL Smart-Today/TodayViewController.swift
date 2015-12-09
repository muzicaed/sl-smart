//
//  TodayViewController.swift
//  SL Smart-Today
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import UIKit
import NotificationCenter
import ResStockholmApiKit

class TodayViewController: UIViewController, NCWidgetProviding {
  
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  @IBOutlet weak var mainStackView: UIStackView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var departureDescLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var arrivalDescLabel: UILabel!
  @IBOutlet weak var iconContainerView: UIView!
  @IBOutlet weak var travelTimeLabel: UILabel!
  
  var bestRoutineTrip: RoutineTrip?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.preferredContentSize = CGSizeMake(0, 160)
  }
  
  func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
    print("widgetPerformUpdateWithCompletionHandler")
    reloadData(completionHandler)
  }
  
  // MARK: Private
  
  /**
  * Reloads the data
  */
  private func reloadData(completionHandler: ((NCUpdateResult) -> Void)) {
    RoutineService.findRoutineTrip({ routineTrips in
      if routineTrips.count > 0 {
        self.bestRoutineTrip = routineTrips.first!
        dispatch_async(dispatch_get_main_queue(), {
          self.updateUI()
          completionHandler(NCUpdateResult.NewData)
        })
      }
    })
  }
  
  
  /**
   * Updates the UI based on data
   */
  private func updateUI() {
    if let routine = bestRoutineTrip {
      let trip = routine.trips.first!
      let firstSegment = trip.tripSegments.first!
      let lastSegment = trip.tripSegments.last!
      
      titleLabel.text = routine.title
      departureTimeLabel.text = DateUtils.dateAsTimeString(firstSegment.departureDateTime)
      arrivalTimeLabel.text = DateUtils.dateAsTimeString(lastSegment.arrivalDateTime)
      departureDescLabel.text = " \(routine.origin!.cleanName)"
      arrivalDescLabel.text = " \(routine.destination!.cleanName)"
      travelTimeLabel.text = "Restid: \(trip.durationMin) min"
      
      createTripSegmentIcons(trip)
      UIView.animateWithDuration(0.5, animations: {
        self.mainStackView.alpha = 1.0
        self.spinner.alpha = 0.0
      })
    }
  }
  
  /**
   * Creates trip type icon per segment.
   */
  private func createTripSegmentIcons(trip: Trip) {
    var count = 0
    for (_, segment) in trip.tripSegments.enumerate() {
      if segment.type != .Walk || (segment.type == .Walk && segment.distance! > 30) {
        if count > 5 { return }
        let data = TripHelper.friendlyLineData(segment)
        
        let iconView = UIImageView(image: TripIcons.icons[data.icon]!)
        iconView.frame.size = CGSizeMake(15, 15)
        iconView.center = CGPointMake(30 / 2, 13)
        
        let label = UILabel()
        label.text = data.short
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(8)
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        label.frame.size.width = 28
        label.center = CGPointMake((30 / 2), 27)
        label.adjustsFontSizeToFitWidth = true
        
        let wrapperView = UIView(
          frame:CGRect(
            origin: CGPointMake(0, 0),
            size: CGSizeMake(30, 30)))
        wrapperView.frame.origin = CGPointMake((30 * CGFloat(count)), 0)
        
        wrapperView.addSubview(iconView)
        wrapperView.addSubview(label)
        wrapperView.clipsToBounds = false
        iconContainerView.addSubview(wrapperView)
        count++
      }
    }
  }
}

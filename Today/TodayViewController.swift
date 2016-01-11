//
//  TodayViewController.swift
//  Today
//
//  Created by Mikael Hellman on 2016-01-08.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import UIKit
import NotificationCenter
import ResStockholmApiKit

class TodayViewController: UIViewController, NCWidgetProviding {
  
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var departureStationLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var arrivalStationLabel: UILabel!
  @IBOutlet weak var travelTimeLabel: UILabel!
  @IBOutlet weak var iconWrapperView: UIView!
  @IBOutlet weak var inAboutLabel: UILabel!
  
  /**
   * View loaded for the first time.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    print("View did load")
    let gesture = UITapGestureRecognizer(target: self, action: Selector("onTap"))
    view.addGestureRecognizer(gesture)
  }
  
  /**
   * Update data request.
   * OS Controlled.
   */
  func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
    print("Completion handler")
    loadTripData() {
      completionHandler(NCUpdateResult.NewData)
    }
  }
  
  /**
   * User tap widget
   */
  func onTap() {
    print("Tap")
    extensionContext?.openURL(NSURL(string: "ressmart://")!, completionHandler: nil)    
  }
  
  // MARK: Private
  
  /**
   * Loads trip data and updates UI
   */
  private func loadTripData(callback: (() -> Void)?) {
    RoutineService.findRoutineTrip({ routineTrips in
      if let bestRoutineTrip = routineTrips.first {
        if let trip = bestRoutineTrip.trips.first {
          dispatch_async(dispatch_get_main_queue()) {
            self.titleLabel.text = bestRoutineTrip.title
            self.departureStationLabel.text = trip.tripSegments.first?.origin.name
            self.departureTimeLabel.text = DateUtils.dateAsTimeString(trip.tripSegments.first!.departureDateTime)
            self.arrivalStationLabel.text = trip.tripSegments.last?.destination.name
            self.arrivalTimeLabel.text = DateUtils.dateAsTimeString(trip.tripSegments.last!.arrivalDateTime)
            self.travelTimeLabel.text = DateUtils.createTripDurationString(trip.durationMin)
            
            self.inAboutLabel.text = "  " + DateUtils.createAboutTimeText(
              trip.tripSegments.first!.departureDateTime,
              isWalk: (trip.tripSegments.first!.type == TripType.Walk))
            
            self.createTripSegmentIcons(trip)
            callback?()
          }
        }
      }
      else {
        self.titleLabel.text = "Hittade inga rutiner."
      }
    })
  }
  
  /**
   * Creates trip type icon per segment.
   */
  private func createTripSegmentIcons(trip: Trip) {
    iconWrapperView.subviews.forEach({ $0.removeFromSuperview() })
    var count = 0
    for (_, segment) in trip.tripSegments.enumerate() {
      if segment.type != .Walk || (segment.type == .Walk && segment.distance! > 30) {
        if count > 5 { return }
        let data = TripHelper.friendlyLineData(segment)
        
        let iconView = UIImageView(image: TripIcons.icons[data.icon]!)
        iconView.frame.size = CGSizeMake(15, 15)
        iconView.center = CGPointMake(23 / 2, 9)
        
        let label = UILabel()
        label.text = data.short
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(7)
        label.textColor = UIColor.lightGrayColor()
        label.sizeToFit()
        label.frame.size.width = 25
        label.center = CGPointMake((23 / 2), 22)
        label.lineBreakMode = .ByTruncatingTail
        
        let wrapperView = UIView(
          frame:CGRect(
            origin: CGPointMake((23 * CGFloat(count)), 12),
            size: CGSizeMake(23, 30)))
        
        wrapperView.addSubview(iconView)
        wrapperView.addSubview(label)
        wrapperView.clipsToBounds = false
        iconWrapperView.addSubview(wrapperView)
        count++
      }
    }
  }
  
  /**
   * Set custom insets
   */
  func widgetMarginInsetsForProposedMarginInsets(var defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    defaultMarginInsets.top = 10
    defaultMarginInsets.bottom = 30
    return defaultMarginInsets
  }
}

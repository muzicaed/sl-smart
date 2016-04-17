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
  @IBOutlet weak var nextLabel: UILabel!
  
  var bestRoutine: RoutineTrip?
  var refreshTimmer: NSTimer?
  
  /**
   * View loaded for the first time.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    MyLocationHelper.sharedInstance.requestLocationUpdate(nil)
    self.preferredContentSize = CGSizeMake(320, 160)
    let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
    view.addGestureRecognizer(gesture)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidDisappear(animated)
    loadTripData(nil)
  }
  
  /**
   * View did disappear
   */
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    stopRefreshTimmer()
  }
  
  /**
   * Update data request.
   * OS Controlled.
   */
  func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
    completionHandler(NCUpdateResult.NoData)
  }
  
  /**
   * User tap widget
   */
  func onTap() {
    extensionContext?.openURL(NSURL(string: "ressmart://")!, completionHandler: nil)
  }
  
  /**
   * Starts the refresh timmer
   */
  func startRefreshTimmer() {
    stopRefreshTimmer()
    refreshTimmer = NSTimer.scheduledTimerWithTimeInterval(
      10.0, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
  }
  
  /**
   * Stop the refresh timmer
   */
  func stopRefreshTimmer() {
    refreshTimmer?.invalidate()
    refreshTimmer = nil
  }
  
  // MARK: Private
  
  /**
   * Loads trip data and updates UI
   */
  private func loadTripData(callback: (() -> Void)?) {
    startRefreshTimmer()
    RoutineService.findRoutineTrip({ routineTrips in
      self.bestRoutine = routineTrips.first
      dispatch_async(dispatch_get_main_queue()) {
        if self.bestRoutine != nil {
          self.updateUI()
        }
        else {
          self.titleLabel.text = "Hittade inga rutiner."
        }
      }
      callback?()
      return
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
        count += 1
      }
    }
  }
  
  /**
   * Update widget UI
   */
  func updateUI() {
    if let bestRoutineTrip = self.bestRoutine {
      if let trip = bestRoutineTrip.trips.first {
        self.titleLabel.text = bestRoutineTrip.title
        self.departureStationLabel.text = trip.tripSegments.first?.origin.name
        self.departureTimeLabel.text = DateUtils.dateAsTimeString(
          trip.tripSegments.first!.departureDateTime)
        self.arrivalStationLabel.text = trip.tripSegments.last?.destination.name
        self.arrivalTimeLabel.text = DateUtils.dateAsTimeString(
          trip.tripSegments.last!.arrivalDateTime)
        self.travelTimeLabel.text = DateUtils.createTripDurationString(trip.durationMin)
        
        self.inAboutLabel.text = DateUtils.createAboutTimeText(
          trip.tripSegments.first!.departureDateTime,
          isWalk: (trip.tripSegments.first!.type == TripType.Walk))
        
        self.createTripSegmentIcons(trip)
        
        
        var second: Trip? = nil
        if bestRoutineTrip.trips.count > 1 {
          second = bestRoutineTrip.trips[1]
        }
        
        if let second = second?.tripSegments.first, first = trip.tripSegments.first {
          let depTimeInterval = first.departureDateTime.timeIntervalSinceNow
          if depTimeInterval < (60 * 11) {
            let diffMin = Int(ceil(((second.departureDateTime.timeIntervalSince1970 - NSDate().timeIntervalSince1970) / 60)) + 0.5)
            if diffMin <= 60 {
              nextLabel.text = String(format: NSLocalizedString("Nästa: %d min", comment: ""), diffMin)
              nextLabel.hidden = false
            }
          }
        }
      }
    }
  }
  
  /**
   * Set custom insets
   */
  func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    var newDefaultMarginInsets = defaultMarginInsets
    newDefaultMarginInsets.top = 10
    newDefaultMarginInsets.bottom = 30
    return newDefaultMarginInsets
  }
}

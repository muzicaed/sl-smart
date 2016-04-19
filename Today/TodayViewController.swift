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
  
  /**
   * View did disappear
   */
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    stopRefreshTimmer()
  }
  
  /**
   * View did appear
   */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    loadTripData()
    startRefreshTimmer()
  }
  
  /**
   * Update data request.
   * OS Controlled.
   */
  func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
    updateUI()
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
    NSRunLoop.mainRunLoop().addTimer(refreshTimmer!, forMode: NSRunLoopCommonModes)
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
  func loadTripData() {
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
        if count > 6 { return }
        let data = TripHelper.friendlyLineData(segment)
        
        let iconView = UIImageView(image: TripIcons.icons[data.icon]!)
        iconView.frame.size = CGSizeMake(18, 18)
        iconView.center = CGPointMake(18 / 2, 3)
        
        let label = UILabel()
        label.text = "\u{200A}\(data.short)\u{200A}\u{200C}"
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.boldSystemFontOfSize(8)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = data.color
        label.frame.size.width = 18
        label.frame.size.height = 12
        label.center = CGPointMake((18 / 2), 18)
        
        let wrapperView = UIView(
          frame:CGRect(
            origin: CGPointMake(0, 0),
            size: CGSizeMake(18, 36)))
        wrapperView.frame.origin = CGPointMake((23 * CGFloat(count)), 10)
        wrapperView.clipsToBounds = false
        
        wrapperView.addSubview(iconView)
        wrapperView.addSubview(label)
        
        if segment.rtuMessages != nil {
          var warnIconView = UIImageView(image: TripIcons.icons["INFO-ICON"]!)
          if segment.isWarning {
            warnIconView = UIImageView(image: TripIcons.icons["WARNING-ICON"]!)
          }
          warnIconView.frame.size = CGSizeMake(10, 10)
          warnIconView.center = CGPointMake((18 / 2) + 8, -2)
          warnIconView.alpha = 0.9
          wrapperView.insertSubview(warnIconView, aboveSubview: iconView)
        }
        
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
    newDefaultMarginInsets.bottom = 10
    return newDefaultMarginInsets
  }
}

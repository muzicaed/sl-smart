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
  @IBOutlet weak var inAboutLabel: UILabel!
  @IBOutlet weak var nextLabel: UILabel!
  
  var bestRoutine: RoutineTrip?
  var refreshTimmer: Timer?
  
  /**
   * View loaded for the first time.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    MyLocationHelper.sharedInstance.requestLocationUpdate(nil)
    if #available(iOSApplicationExtension 10.0, *) {
      self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
    } else {
      self.preferredContentSize = CGSize(width: 320, height: 160)
    }
    let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
    view.addGestureRecognizer(gesture)
    loadTripData() {}
  }
  
  /**
   * View did disappear
   */
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopRefreshTimmer()
  }
  
  /**
   * View did appear
   */
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    startRefreshTimmer()
    updateUI()
  }
  
  /**
   * Update data request.
   * OS Controlled.
   */
  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    loadTripData(){
      self.updateUI()
      completionHandler(.newData)
    }
  }
  
  /**
   * User tap widget
   */
  @objc func onTap() {
    extensionContext?.open(URL(string: "ressmart://")!, completionHandler: nil)
  }
  
  /**
   * Starts the refresh timmer
   */
  func startRefreshTimmer() {
    stopRefreshTimmer()
    refreshTimmer = Timer.scheduledTimer(
      timeInterval: 10.0, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
    RunLoop.main.add(refreshTimmer!, forMode: RunLoopMode.commonModes)
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
  func loadTripData(callback: @escaping () -> ()) {
    RoutineService.findRoutineTrip({ routineTrips in
      self.bestRoutine = routineTrips.first
      DispatchQueue.main.async {
        if self.bestRoutine != nil {
          callback()
        }
        else {
          self.titleLabel.text = "Could not find any routines.".localized
        }
      }
      return
    })
  }
  
  /**
   * Update widget UI
   */
  @objc func updateUI() {
    if let bestRoutineTrip = self.bestRoutine {
      if let trip = bestRoutineTrip.trips.first {
        self.titleLabel.text = bestRoutineTrip.title
        if let first = trip.tripSegments.first, let last = trip.tripSegments.last {
          self.departureStationLabel.text = first.origin.name
          self.arrivalStationLabel.text = last.destination.name
          self.departureTimeLabel.text = DateUtils.dateAsTimeString(first.departureDateTime)        
          self.arrivalTimeLabel.text = DateUtils.dateAsTimeString(last.arrivalDateTime)          
          self.inAboutLabel.text = DateUtils.createAboutTimeText(segments: trip.tripSegments)
        }
        
        var second: Trip? = nil
        if bestRoutineTrip.trips.count > 1 {
          second = bestRoutineTrip.trips[1]
        }
        
        if let second = second?.tripSegments.first, let first = trip.tripSegments.first {
          let depTimeInterval = first.departureDateTime.timeIntervalSinceNow
          if depTimeInterval < (60 * 11) {
            let diffMin = Int(ceil(((second.departureDateTime.timeIntervalSince1970 - Date().timeIntervalSince1970) / 60)) + 0.5)
            if diffMin <= 60 {
              nextLabel.text = String(format: NSLocalizedString("Next: %d min", comment: ""), diffMin)
              nextLabel.isHidden = false
            }
          }
        }
      }
    }
  }
  
  /**
   * Set custom insets
   */
  func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
    var newDefaultMarginInsets = defaultMarginInsets
    newDefaultMarginInsets.top = 10
    newDefaultMarginInsets.bottom = 10
    return newDefaultMarginInsets
  }
}

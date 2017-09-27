//
//  RoutineTripsVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit
import CoreLocation

class RoutineTripsVC: UITableViewController, LocationSearchResponder {
  
  let showTripListSegue = "ShowTripList"
  let fromHereToThereSegue = "FromHereToThere"
  let manageRoutineTripsSegue = "ManageRoutineTrips"
  
  var bestRoutineTrip: RoutineTrip?
  var otherRoutineTrips = [RoutineTrip]()
  var selectedRoutineTrip: RoutineTrip?
  var isLoading = true
  var isShowInfo = false
  var lastUpdated = Date(timeIntervalSince1970: TimeInterval(0.0))
  
  var hereToThereCriterion: TripSearchCriterion?
  var refreshTimmer: Timer?
  
  /**
   * View is done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    prepareTableView()
    setupNotificationListeners()
  }
  
  /**
   * View is about to display.
   */
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    IJProgressView.shared.hideProgressView()
    refreshScreen()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    stopRefreshTimmer()
  }
  
  /**
   * Triggered when returning from background.
   */
  @objc func didBecomeActive() {
    if CLLocationManager.authorizationStatus() == .denied || !CLLocationManager.locationServicesEnabled() {
      showLocationServicesNotAllowed()
      MyLocationHelper.sharedInstance.isStarted = false
      return
    }
    if !isLoading {
      loadTripData(force: true)
      startRefreshTimmer()
    }
  }
  
  /**
   * Backgrounded.
   */
  @objc func didBecomeInactive() {
    tableView?.backgroundView?.isHidden = true
    stopRefreshTimmer()
  }
  
  /**
   * Starts the refresh timmer
   */
  func startRefreshTimmer() {
    stopRefreshTimmer()
    refreshTimmer = Timer.scheduledTimer(
      timeInterval: 5.0, target: self, selector: #selector(refreshUI), userInfo: nil, repeats: true)
  }
  
  @objc func refreshUI() {
    loadTripData(force: false)
  }
  
  /**
   * Stop the refresh timmer
   */
  func stopRefreshTimmer() {
    refreshTimmer?.invalidate()
    refreshTimmer = nil
  }
  
  /**
   * Refresh screen and reload data.
   */
  fileprivate func refreshScreen() {
    navigationItem.rightBarButtonItem?.isEnabled = true
    if CLLocationManager.authorizationStatus() == .denied || !CLLocationManager.locationServicesEnabled() {
      showLocationServicesNotAllowed()
      MyLocationHelper.sharedInstance.isStarted = false
      tableView?.reloadData()
      return
    }
    
    startRefreshTimmer()
    loadTripData(force: false)
  }
  
  /**
   * Prepares for segue
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == showTripListSegue {
      if let crit = hereToThereCriterion {
        let vc = segue.destination as! TripListVC
        vc.criterions = crit.copy() as? TripSearchCriterion
        SearchCriterionStore.sharedInstance.writeLastSearchCriterions(crit)
        
      } else if let routineTrip = selectedRoutineTrip {
        if let crit = routineTrip.criterions.copy() as? TripSearchCriterion {
          crit.searchForArrival = (crit.time != nil) ? true : false
          let timeDateTuple = createDateTimeTuple(routineTrip.criterions)
          crit.date = timeDateTuple.date
          crit.time = timeDateTuple.time
          
          let vc = segue.destination as! TripListVC
          vc.criterions = crit
          vc.routineTrip = selectedRoutineTrip
          vc.title = routineTrip.title
          if selectedRoutineTrip!.isSmartSuggestion {
            vc.title = "Smart vana"
          }
        }
      }
      
    } else if segue.identifier == manageRoutineTripsSegue {
      // Force a reload when returning to this VC
      loadTripData(force: true)
      
    } else if segue.identifier == fromHereToThereSegue {
      let vc = segue.destination as! SearchLocationVC
      vc.title = "Choose destination".localized
      vc.delegate = self
      vc.searchOnlyForStations = false
      vc.allowCurrentPosition = false
    }
  }
  
  // MARK: UITableViewController
  
  /**
   * Number of section
   */
  override func numberOfSections(in tableView: UITableView) -> Int {
    if isLoading {
      return 0
    } else if isShowInfo {
      return 2
    }
    return 4
  }
  
  /**
   * Number of rows
   */
  override func tableView(
    _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isLoading {
      return 0
    } else if section == 0 || section == 1 || section == 3 {
      return 1
    }
    return otherRoutineTrips.count
  }
  
  /**
   * Cell for index
   */
  override func tableView(
    _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if isShowInfo {
      if indexPath.section == 0 {
        return tableView.dequeueReusableCell(
          withIdentifier: "RoutinesInfoCell", for: indexPath)
      }
      return tableView.dequeueReusableCell(
        withIdentifier: "DisableRoutinesCell", for: indexPath)
    }
    
    if indexPath.section == 0 {
      if let routineTrip = bestRoutineTrip {
        if routineTrip.trips.count > 0 {
          return createRoutineTripCell(routineTrip, indexPath: indexPath)
        } else {
          return createNoTripsCell(routineTrip, indexPath: indexPath)
        }
      }
    } else if indexPath.section == 1 {
      return createHereToThereCell(indexPath)
    } else if indexPath.section == 2 {
      return createOtherRoutineTripCell(otherRoutineTrips[indexPath.row], indexPath: indexPath)
    } else if indexPath.section == 3 {
      return tableView.dequeueReusableCell(
        withIdentifier: "DisableRoutinesCell", for: indexPath)
    }
    return UITableViewCell()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if isShowInfo && indexPath.section == 1 {
      showDisableRoutinesAlert()
      return
    }
    
    if !isShowInfo && !isLoading {
      if indexPath.section == 1 {
        performSegue(withIdentifier: fromHereToThereSegue, sender: self)
        return
      }

      var scoreMod: Float = 0.0
      if indexPath.section == 0 {
        hereToThereCriterion = nil
        selectedRoutineTrip = bestRoutineTrip
        scoreMod = ScorePostHelper.BestTapCountScore
      } else if indexPath.section == 2 {
        selectedRoutineTrip = otherRoutineTrips[indexPath.row]
        scoreMod = ScorePostHelper.OtherTapCountScore
        ScorePostHelper.changeScoreForRoutineTrip(
          bestRoutineTrip!.criterions.origin!.siteId!,
          destinationId: bestRoutineTrip!.criterions.dest!.siteId!,
          score: ScorePostHelper.NotBestTripScore)
      } else if indexPath.section == 3 {
        showDisableRoutinesAlert()
      }
      
      if selectedRoutineTrip != nil {
        ScorePostHelper.changeScoreForRoutineTrip(
          selectedRoutineTrip!.criterions.origin!.siteId!,
          destinationId: selectedRoutineTrip!.criterions.dest!.siteId!,
          score: scoreMod)
        performSegue(withIdentifier: showTripListSegue, sender: self)
      }
    }
  }
  
  /**
   * Green highlight on selected row.
   */
  override func tableView(
    _ tableView: UITableView, willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath) {
    
    let bgColorView = UIView()
    bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
    cell.selectedBackgroundView = bgColorView
  }
  
  // MARK: LocationSearchResponder
  
  @IBAction func unwindToStationSearchParent(_ segue: UIStoryboardSegue) {}
  
  /**
   * User selected location (for From here to there feature)
   */
  func selectedLocationFromSearch(_ location: Location) {
    if let currentLocation = MyLocationHelper.sharedInstance.getCurrentLocation() {
      let crit = TripSearchCriterion(origin: currentLocation, dest: location)
      let date = Date(timeIntervalSinceNow: (60 * 2) * -1)
      crit.date = DateUtils.dateAsDateString(date)
      crit.time = DateUtils.dateAsTimeString(date)
      hereToThereCriterion = crit
      
      RoutineService.addHabitRoutine(crit)
      performSegue(withIdentifier: self.showTripListSegue, sender: self)
    }
  }
  
  // MARK: Private methods
  
  /**
   * On trip search done.
   */
  fileprivate func startLoading() {
    NetworkActivity.displayActivityIndicator(true)
    IJProgressView.shared.showProgressView(navigationController!.view)
    isShowInfo = false
    isLoading = true
    bestRoutineTrip = nil
    selectedRoutineTrip = nil
  }
  
  /**
   * On trip search done.
   */
  fileprivate func stopLoading() {
    DispatchQueue.main.async() {
      self.isLoading = false
      IJProgressView.shared.hideProgressView()
      self.tableView?.reloadData()
    }
  }
  
  /**
   * Checks if data should be reloaded.
   */
  fileprivate func shouldReload() -> Bool {
    if let routine = bestRoutineTrip, let trip = routine.trips.first {
      if let segment = trip.tripSegments.first {
        if Date().timeIntervalSince(segment.departureDateTime) > 30 {
          return true
        }
      }
    }
    return (Date().timeIntervalSince(lastUpdated) > 30)
  }
  
  /**
   * Setup table view properties and layout.
   */
  fileprivate func prepareTableView() {
    view.backgroundColor = StyleHelper.sharedInstance.background
  }
  
  /**
   * Create best trip cell
   */
  fileprivate func createRoutineTripCell(_ trip: RoutineTrip, indexPath: IndexPath) -> RoutineTripCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "RoutineTripCell", for: indexPath) as! RoutineTripCell
    cell.setupData(trip)
    if trip.trips.first != nil && !trip.trips.first!.isValid {
      let validTuple = trip.trips.first!.checkInvalidSegments()
      let warningText = (validTuple.isCancelled) ? "Cancelled".localized : "Short transfer".localized
      cell.setCancelled(warningText)
    }
    return cell
  }
  
  /**
   * Create other trip cell
   */
  fileprivate func createOtherRoutineTripCell(_ trip: RoutineTrip, indexPath: IndexPath) -> OtherRoutineTripCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "OtherRoutineCell", for: indexPath) as! OtherRoutineTripCell
    cell.setupData(trip, indexPath.row)
    return cell
  }
  
  /**
   * Create "From here to there" cell
   */
  fileprivate func createHereToThereCell(_ indexPath: IndexPath) -> HereToThereCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "HereToThereCell", for: indexPath) as! HereToThereCell
    
    if let currentLocation = MyLocationHelper.sharedInstance.getCurrentLocation() {
      cell.setFromLocationText(currentLocation)
    }
    
    return cell
  }
  
  /**
   * Create other trip cell
   */
  fileprivate func createNoTripsCell(_ trip: RoutineTrip, indexPath: IndexPath) -> NoTripsCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "NoTripsCell", for: indexPath) as! NoTripsCell
    cell.setupData(trip)
    return cell
  }
  
  /**
   * Loading the trip data, and starting background
   * collection of time table data.
   * Will show big spinner when loading.
   */
  fileprivate func loadTripData(force: Bool) {
    if RoutineTripsStore.sharedInstance.isRoutineTripsEmpty() {
      isShowInfo = true
      otherRoutineTrips = [RoutineTrip]()
      bestRoutineTrip = nil
      selectedRoutineTrip = nil
      stopLoading()
    } else if shouldReload() || force {
      startLoading()
      RoutineService.findRoutineTrip({ routineTrips in
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
          if routineTrips.count > 0 {
            self.bestRoutineTrip = routineTrips.first!
            self.otherRoutineTrips = Array(routineTrips[1..<routineTrips.count])
            self.lastUpdated = Date()
          }
          NetworkActivity.displayActivityIndicator(false)
          self.stopLoading()
        }
      })
    } else {
      tableView?.reloadData()
    }
  }
  
  /**
   * Setup notification listeners.
   */
  fileprivate func setupNotificationListeners() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(didBecomeActive),
      name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(didBecomeInactive),
      name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
  }
  
  /**
   * Create date & time tuple.
   * Takes routine arrival time in to consideration.
   */
  fileprivate func createDateTimeTuple(_ criterions: TripSearchCriterion) -> (date: String, time: String) {
    if let time = criterions.time {
      let now = Date()
      let date = DateUtils.convertDateString("\(DateUtils.dateAsDateString(now)) \(time)")
      if date.timeIntervalSinceNow > (60 * 60) * -1 {
        return (DateUtils.dateAsDateString(now), time)
      } else {
        let tomorrow = now.addingTimeInterval(60 * 60 * 24 * 1)
        return (DateUtils.dateAsDateString(tomorrow), time)
      }
    }
    
    return (DateUtils.dateAsDateString(Date()), DateUtils.dateAsTimeString(Date()))
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
  
  /**
   * Show alert on disable routines button
   */
  fileprivate func showDisableRoutinesAlert() {
    let disableRoutinesAlert = UIAlertController(
      title: "Disable routines?".localized,
      message: "You can enable routines again from the app settings.\nAre you sure you want to disable routines?".localized,
      preferredStyle: UIAlertControllerStyle.alert)
    disableRoutinesAlert.addAction(UIAlertAction(title: "Yes".localized, style: .default, handler: { (_) in
      UserDefaults.standard.set(false, forKey: "res_smart_premium_preference")
      UserDefaults.standard.synchronize()
      self.tableView.reloadData()
      NotificationCenter.default.post(name: Notification.Name(rawValue: "UpdateTabs"), object: nil)
      
    }))
    disableRoutinesAlert.addAction(
      UIAlertAction(title: "No".localized, style: .cancel, handler: { (_) in
        self.tableView.reloadData()
      }))
    
    present(disableRoutinesAlert, animated: true, completion: nil)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

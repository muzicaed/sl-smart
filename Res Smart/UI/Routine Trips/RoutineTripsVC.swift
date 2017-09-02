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
    refreshScreen()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    stopRefreshTimmer()
    IJProgressView.shared.hideProgressView()
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
    
    loadTripData(true)
    startRefreshTimmer()
    tableView?.reloadData()
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
    loadTripData(false)
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
    stopLoading()
    navigationItem.rightBarButtonItem?.isEnabled = true
    if CLLocationManager.authorizationStatus() == .denied || !CLLocationManager.locationServicesEnabled() {
      showLocationServicesNotAllowed()
      MyLocationHelper.sharedInstance.isStarted = false
      tableView?.reloadData()
      return
    }
    
    startRefreshTimmer()
    loadTripData(false)
  }
  
  /**
   * Prepares for segue
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    print("SEGUE" + segue.identifier!)
    if segue.identifier == showTripListSegue {
      if let crit = hereToThereCriterion {
        let vc = segue.destination as! TripListVC
        vc.criterions = crit.copy() as? TripSearchCriterion
        SearchCriterionStore.sharedInstance.writeLastSearchCriterions(crit)
        
      } else if let routineTrip = selectedRoutineTrip {
        print("SEGUE")
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
      stopRefreshTimmer()
      lastUpdated = Date(timeIntervalSince1970: TimeInterval(0.0))
      
    } else if segue.identifier == fromHereToThereSegue {
      let vc = segue.destination as! SearchLocationVC
      vc.title = "Välj destination"
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
      return 1
    }
    return 3
  }
  
  /**
   * Number of rows
   */
  override func tableView(
    _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if isLoading {
      return 0
    }
    
    if section == 0 || section == 1 {
      return 1
    }
    
    return otherRoutineTrips.count
  }
  
  /**
   * Cell for index
   */
  override func tableView(
    _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      if isShowInfo {
        //return createInfoTripCell(indexPath)
      }
      
      if indexPath.row == 0 {
        if let routineTrip = bestRoutineTrip {
          return createRoutineTripCell(routineTrip, indexPath: indexPath)
        } else {
          //return createHereToThereCell(indexPath)
          return UITableViewCell()
        }
      } else if indexPath.row == 1 {
        //return createHereToThereCell(indexPath)
        return UITableViewCell()
      } else if indexPath.row == 2 {
        //return createTrialCell(indexPath)
        return UITableViewCell()
      }
      fatalError("Could not create cell.")
    }
    return UITableViewCell()
    //return createRoutineTripCell(otherRoutineTrips[indexPath.row], type: simpleCellIdentifier, indexPath: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if !isShowInfo && !isLoading {
      if indexPath.section == 1 {
        performSegue(withIdentifier: fromHereToThereSegue, sender: self)
        return
      }
      print("did select")
      var scoreMod: Float = 0.0
      if indexPath.section == 0 {
        print("selected")
        hereToThereCriterion = nil
        selectedRoutineTrip = bestRoutineTrip
        scoreMod = ScorePostHelper.BestTapCountScore
      } else if indexPath.section == 3 {
        selectedRoutineTrip = otherRoutineTrips[indexPath.row]
        scoreMod = ScorePostHelper.OtherTapCountScore
        ScorePostHelper.changeScoreForRoutineTrip(
          bestRoutineTrip!.criterions.origin!.siteId!,
          destinationId: bestRoutineTrip!.criterions.dest!.siteId!,
          score: ScorePostHelper.NotBestTripScore)
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
    return (Date().timeIntervalSince(lastUpdated) > 120)
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
    return cell
  }
  
  /**
   * Loading the trip data, and starting background
   * collection of time table data.
   * Will show big spinner when loading.
   */
  fileprivate func loadTripData(_ force: Bool) {
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
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

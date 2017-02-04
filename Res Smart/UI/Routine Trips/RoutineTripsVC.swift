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

class RoutineTripsVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, LocationSearchResponder {
  
  let routineCellIdentifier = "RoutineTripCell"
  let simpleCellIdentifier = "SimpleRoutineTripCell"
  let loadingCellIdentifier = "LoadingCell"
  let headerCellIdentifier = "HeaderView"
  let infoCellIdentifier = "InfoCell"
  let trialCellIdentifier = "TrialCell"
  let subscriptionInfoCellIdentifier = "SubscriptionInfoCell"
  let hereToThereCellIdentifier = "HereToThereCell"
  
  let showTripListSegue = "ShowTripList"
  let fromHereToThereSegue = "FromHereToThere"
  let manageRoutineTripsSegue = "ManageRoutineTrips"
  
  var bestRoutineTrip: RoutineTrip?
  var otherRoutineTrips = [RoutineTrip]()
  var selectedRoutineTrip: RoutineTrip?
  var isSubscribed = false
  var isLoading = true
  var isShowInfo = false
  var lastUpdated = Date(timeIntervalSince1970: TimeInterval(0.0))
  let refreshController = UIRefreshControl()
  
  var hereToThereCriterion: TripSearchCriterion?
  var refreshTimmer: Timer?
  var tableActivityIndicator = UIActivityIndicatorView(
    activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
  
  /**
   * View is done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
    setupNotificationListeners()
    setupRefreshController()
    setupTableActivityIndicator()
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
  
  /**
   * Triggered when returning from background.
   */
  func didBecomeActive() {
    if CLLocationManager.authorizationStatus() == .denied || !CLLocationManager.locationServicesEnabled() {
      showLocationServicesNotAllowed()
      MyLocationHelper.sharedInstance.isStarted = false
      return
    }
    isSubscribed = SubscriptionStore.sharedInstance.isSubscribed()
    if isSubscribed {
      loadTripData(true)
      startRefreshTimmer()
    }
    collectionView?.reloadData()
  }
  
  /**
   * Backgrounded.
   */
  func didBecomeInactive() {
    collectionView?.backgroundView?.isHidden = true
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
  
  func refreshUI() {
    if isSubscribed {
      loadTripData(false)
    }
  }
  
  /**
   * Stop the refresh timmer
   */
  func stopRefreshTimmer() {
    refreshTimmer?.invalidate()
    refreshTimmer = nil
  }
  
  /**
   * On user drags down to refresh
   */
  func onRefreshController() {
    if isSubscribed || !isLoading {
      loadTripData(true)
    } else {
      refreshController.endRefreshing()
    }
  }
  
  /**
   * On user taps subscribe button
   */
  @IBAction func onSubscribeTap(_ sender: UIButton) {
    performSegue(withIdentifier: "ShowSubscribe", sender: self)
  }
  
  @IBAction func onConvertToFreeTap(_ sender: UIButton) {
    showConvertToFreeAlert()
  }
  
  /**
   * On user taps restore button
   */
  @IBAction func onRestoreSubscription(_ sender: UIButton) {
    showRestoreSubscriptionAlert()
  }
  
  /**
   * On user taps abort trial button
   */
  @IBAction func onAbortTrial(_ sender: UIButton) {
    showAbortTrialAlert()
  }
  
  /**
   * Unwind (back) to this view.
   */
  @IBAction func unwindToRoutineTripsVC(_ segue: UIStoryboardSegue) {}
  
  
  // MARK: UICollectionViewController
  
  /**
   * Section count
   */
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    if !isSubscribed {
      return 1
    }
    return 2
  }
  
  /**
   * Item count for section
   */
  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    if isLoading {
      return 0
    }
    
    if section == 0 {
      if isShowInfo || !isSubscribed {
        return 1
      }
      var bestCount = (bestRoutineTrip == nil ? 0 : 1)
      if MyLocationHelper.sharedInstance.getCurrentLocation() != nil {
        bestCount += 1
      }
      if SubscriptionStore.sharedInstance.isTrial() {
        bestCount += 1
      }
      return bestCount
    }
    
    return otherRoutineTrips.count
  }
  
  /**
   * Create cells for each data post.
   */
  override func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if indexPath.section == 0 {
      if !isSubscribed {
        if indexPath.row == 1 {
          return createTrialCell(indexPath)
        }
        return createSubscriptionInfoCell(indexPath)
      } else if isShowInfo {
        if indexPath.row == 1 {
          return createTrialCell(indexPath)
        }
        return createInfoTripCell(indexPath)
      }
      
      if indexPath.row == 0 {
        if let routineTrip = bestRoutineTrip {
          return createRoutineTripCell(routineTrip, type: routineCellIdentifier, indexPath: indexPath)
        } else {
          return createHereToThereCell(indexPath)
        }
      } else if indexPath.row == 1 {
        return createHereToThereCell(indexPath)
      } else if indexPath.row == 2 {
        return createTrialCell(indexPath)
      }
      fatalError("Could not create cell.")
    }
    return createRoutineTripCell(otherRoutineTrips[indexPath.row], type: simpleCellIdentifier, indexPath: indexPath)
  }
  
  /**
   * View for supplementary (header/footer)
   */
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    let reusableView = collectionView.dequeueReusableSupplementaryView(
      ofKind: UICollectionElementKindSectionHeader,
      withReuseIdentifier: headerCellIdentifier,
      for: indexPath) as! RoutineTripHeader
    
    return reusableView
  }
  
  /**
   * Size for items.
   */
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
    let screenSize = UIScreen.main.bounds.size
    if indexPath.section == 0 {
      if !isSubscribed {
        return CGSize(width: screenSize.width, height: 640)
      } else if isShowInfo {
        return CGSize(width: screenSize.width, height: 250)
      } else if bestRoutineTrip != nil {
        if indexPath.row == 0 {
          return CGSize(width: screenSize.width, height: 175)
        } else if indexPath.row == 2 {
          return CGSize(width: screenSize.width, height: 35)
        }
        return CGSize(width: screenSize.width, height: 60)
      }
    }
    
    return CGSize(width: screenSize.width, height: 90)
  }
  
  /**
   * Size for headers.
   */
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      referenceSizeForHeaderInSection section: Int) -> CGSize {
    if section == 0  {
      return CGSize(width: 0, height: 0)
    } else if section == 1 && otherRoutineTrips.count == 0 {
      return CGSize(width: 0, height: 0)
    }
    
    return CGSize(width: self.collectionView!.frame.size.width, height: 40)
  }
  
  /**
   * User taps an item.
   */
  override func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
    if !isShowInfo && !isLoading && isSubscribed {
      if indexPath.section == 0 && (indexPath.row == 1 || bestRoutineTrip == nil) {
        performSegue(withIdentifier: fromHereToThereSegue, sender: self)
        return
      }
      
      var scoreMod: Float = 0.0
      if indexPath.section == 0 && indexPath.row == 0 {
        hereToThereCriterion = nil
        selectedRoutineTrip = bestRoutineTrip
        scoreMod = ScorePostHelper.BestTapCountScore
      }else if indexPath.section != 0 {
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
  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
    if isSubscribed && !isShowInfo && !isLoading {
      if (indexPath.section == 0 && indexPath.row != 2) || indexPath.section != 0 {
        let bgColorView = UIView()
        bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
        cell.selectedBackgroundView = bgColorView
      }
    }
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
   * Setup collection view properties and layout.
   */
  fileprivate func setupCollectionView() {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    
    collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    collectionView?.collectionViewLayout = flowLayout
    collectionView?.delegate = self
    
    view.backgroundColor = StyleHelper.sharedInstance.background
  }
  
  /**
   * Setup the "pull down to reload" controller.
   */
  fileprivate func setupRefreshController() {
    refreshController.addTarget(
      self, action: #selector(onRefreshController),
      for: UIControlEvents.valueChanged)
    refreshController.tintColor = UIColor.lightGray
    collectionView?.addSubview(refreshController)
    collectionView?.alwaysBounceVertical = true
  }
  
  /**
   * Setup table's background spinner.
   */
  fileprivate func setupTableActivityIndicator() {
    tableActivityIndicator.startAnimating()
    tableActivityIndicator.color = UIColor.lightGray
    collectionView?.backgroundView = tableActivityIndicator
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
   * Refresh screen and reload data.
   */
  fileprivate func refreshScreen() {
    print("View did appear")
    stopLoading()
    isSubscribed = SubscriptionStore.sharedInstance.isSubscribed()
    if isSubscribed {
      print("is subscribed")
      navigationItem.rightBarButtonItem?.isEnabled = true
      if CLLocationManager.authorizationStatus() == .denied || !CLLocationManager.locationServicesEnabled() {
        showLocationServicesNotAllowed()
        MyLocationHelper.sharedInstance.isStarted = false
        collectionView?.reloadData()
        return
      }
      print("reload")
      startRefreshTimmer()
      loadTripData(false)
      return
    }
    navigationItem.rightBarButtonItem?.isEnabled = false
  }
  
  /**
   * Loading the trip data, and starting background
   * collection of time table data.
   * Will show big spinner when loading.
   */
  fileprivate func loadTripData(_ force: Bool) {
    if isSubscribed {
      if RoutineTripsStore.sharedInstance.isRoutineTripsEmpty(){
        isShowInfo = true
        otherRoutineTrips = [RoutineTrip]()
        bestRoutineTrip = nil
        selectedRoutineTrip = nil
        stopLoading()
      } else if shouldReload() || force {
        startLoading()
        RoutineService.findRoutineTrip({ routineTrips in
          DispatchQueue.main.async {
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
        collectionView?.reloadData()
      }
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
   * On trip search done.
   */
  fileprivate func startLoading() {
    NetworkActivity.displayActivityIndicator(true)
    isShowInfo = false
    isLoading = true
    bestRoutineTrip = nil
    selectedRoutineTrip = nil
    collectionView?.backgroundView = tableActivityIndicator
    tableActivityIndicator.startAnimating()
  }
  
  /**
   * On trip search done.
   */
  fileprivate func stopLoading() {
    isLoading = false
    refreshController.endRefreshing()
    collectionView?.backgroundView = nil
    collectionView?.reloadData()
  }
  
  /**
   * Create best trip cell
   */
  fileprivate func createRoutineTripCell(_ trip: RoutineTrip, type: String, indexPath: IndexPath) -> RoutineTripCell {
    let cell = collectionView!.dequeueReusableCell(
      withReuseIdentifier: type, for: indexPath) as! RoutineTripCell
    
    let isBest = (type == routineCellIdentifier) ? true : false
    cell.setupData(trip, isBest: isBest)
    return cell
  }
  
  /**
   * Create info trip cell
   */
  fileprivate func createInfoTripCell(_ indexPath: IndexPath) -> UICollectionViewCell {
    return collectionView!.dequeueReusableCell(
      withReuseIdentifier: infoCellIdentifier, for: indexPath)
  }
  
  /**
   * Create subscription info trip cell
   */
  fileprivate func createSubscriptionInfoCell(_ indexPath: IndexPath) -> UICollectionViewCell {
    return collectionView!.dequeueReusableCell(
      withReuseIdentifier: subscriptionInfoCellIdentifier, for: indexPath)
  }
  
  /**
   * Create "From here to there" cell
   */
  fileprivate func createHereToThereCell(_ indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView!.dequeueReusableCell(
      withReuseIdentifier: hereToThereCellIdentifier, for: indexPath) as! HereToThereCell
    
    if let currentLocation = MyLocationHelper.sharedInstance.getCurrentLocation() {
      cell.setFromLocationText(currentLocation)
    }
    
    return cell
  }
  
  /**
   * Create trial cell
   */
  fileprivate func createTrialCell(_ indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView!.dequeueReusableCell(
      withReuseIdentifier: trialCellIdentifier, for: indexPath)
    return cell
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
   * Show convert to free app alert
   */
  fileprivate func showConvertToFreeAlert() {
    let convertAlert = UIAlertController(
      title: "Använd Res Smart gratis?",
      message: "Du kan aktivera premium igen från Inställningar -> Res Smart\n\nÄr du säker på att du vill stänga av premium och använda Res Smart gratis?",
      preferredStyle: UIAlertControllerStyle.alert)
    convertAlert.addAction(
      UIAlertAction(title: "Ja", style: .default, handler: { _ in
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PremiumDisabled"), object: nil)
      }))
    convertAlert.addAction(
      UIAlertAction(title: "Nej, avbryt", style: .cancel, handler: nil))
    
    present(convertAlert, animated: true, completion: nil)
  }
  
  /**
   * Show restore subscription alert
   */
  fileprivate func showRestoreSubscriptionAlert() {
    let restoreAlert = UIAlertController(
      title: NSLocalizedString("Söker prenumeration", comment: ""),
      message: NSLocalizedString("Om en aktiv prenumeration finns kommer denna automatiskt att aktiveras för denna enhet.\n\nDu kan själv kontrollera dina prenumerationer på din iPhone under Inställningar -> App Store och iTunes Store -> Tryck på ditt Apple-ID -> Visa Apple-ID", comment: ""),
      preferredStyle: UIAlertControllerStyle.alert)
    restoreAlert.addAction(
      UIAlertAction(title: NSLocalizedString("Okej", comment: ""), style: .default, handler: { _ in
        self.startLoading()
        self.isSubscribed = true
        self.collectionView?.reloadData()
        SubscriptionManager.sharedInstance.restoreSubscription()
        let dispatchTime = DispatchTime.now() + Double(Int64(10.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
          self.isSubscribed = false
          self.stopLoading()
          NetworkActivity.displayActivityIndicator(false)
          self.viewWillAppear(true)
        })
      }))
    
    present(restoreAlert, animated: true, completion: nil)
  }
  
  /**
   * Show restore abort trial alert
   */
  fileprivate func showAbortTrialAlert() {
    let abortTrialAlert = UIAlertController(
      title: NSLocalizedString("Avsluta provperiod?", comment: ""),
      message: NSLocalizedString("Du får prova alla premium-funktioner i 14 dagar, är du säker på att du vill avsluta prodverioden?", comment: ""),
      preferredStyle: UIAlertControllerStyle.alert)
    abortTrialAlert.addAction(
      UIAlertAction(title: NSLocalizedString("Ja, avsluta", comment: ""), style: .default, handler: { _ in
        DispatchQueue.main.async {
          SubscriptionStore.sharedInstance.abortTrial()
          self.collectionView?.reloadData()
          self.viewWillAppear(true)
        }        
      }))
    abortTrialAlert.addAction(
      UIAlertAction(title: "Nej, avbryt", style: .cancel, handler: nil))
    
    present(abortTrialAlert, animated: true, completion: nil)
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
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

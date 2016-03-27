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
import SafariServices

class RoutineTripsVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, LocationSearchResponder {
  
  let cellIdentifier = "RoutineTripCell"
  let simpleCellIdentifier = "SimpleRoutineTripCell"
  let loadingCellIdentifier = "LoadingCell"
  let headerCellIdentifier = "HeaderView"
  let infoCellIdentifier = "InfoCell"
  let subscriptionInfoCellIdentifier = "SubscriptionInfoCell"
  let hereToThereCellIdentifier = "HereToThereCell"
  
  let showTripListSegue = "ShowTripList"
  let fromHereToThereSegue = "FromHereToThere"
  let manageRoutineTripsSegue = "ManageRoutineTrips"
  
  var bestRoutineTrip: RoutineTrip?
  var otherRoutineTrips = [RoutineTrip]()
  var selectedRoutineTrip: RoutineTrip?
  var isSubscribing = false
  var isLoading = true
  var isShowInfo = false
  var lastUpdated = NSDate(timeIntervalSince1970: NSTimeInterval(0.0))
  let refreshController = UIRefreshControl()
  
  var hereToThereCriterion: TripSearchCriterion?
  var refreshTimmer: NSTimer?
  var tableActivityIndicator = UIActivityIndicatorView(
    activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
  
  /**
   * View is done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNotificationListeners()
    setupCollectionView()
    setupRefreshController()
    setupTableActivityIndicator()
  }
  
  /**
   * View is about to display.
   */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    stopLoading()
    isSubscribing = SubscriptionStore.sharedInstance.isSubscribed()
    if isSubscribing {
      navigationItem.rightBarButtonItem?.enabled = true
      if CLLocationManager.authorizationStatus() == .Denied || !CLLocationManager.locationServicesEnabled() {
        showLocationServicesNotAllowed()
        MyLocationHelper.sharedInstance.isStarted = false
        collectionView?.reloadData()
        return
      }
      startRefreshTimmer()
      loadTripData(false)
      return
    }
    navigationItem.rightBarButtonItem?.enabled = false
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    stopRefreshTimmer()
  }
  
  /**
   * Prepares for segue
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == showTripListSegue {
      if let crit = hereToThereCriterion {
        let vc = segue.destinationViewController as! TripListVC
        vc.criterions = crit.copy() as? TripSearchCriterion
        SearchCriterionStore.sharedInstance.writeLastSearchCriterions(crit)
        
      } else if let routineTrip = selectedRoutineTrip {
        if let crit = routineTrip.criterions.copy() as? TripSearchCriterion {
          crit.date = DateUtils.dateAsDateString(NSDate())
          crit.time = DateUtils.dateAsTimeString(NSDate())
          
          let vc = segue.destinationViewController as! TripListVC
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
      lastUpdated = NSDate(timeIntervalSince1970: NSTimeInterval(0.0))
      
    } else if segue.identifier == fromHereToThereSegue {
      let vc = segue.destinationViewController as! SearchLocationVC
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
    if CLLocationManager.authorizationStatus() == .Denied || !CLLocationManager.locationServicesEnabled() {
      showLocationServicesNotAllowed()
      MyLocationHelper.sharedInstance.isStarted = false
      return
    }
    isSubscribing = SubscriptionStore.sharedInstance.isSubscribed()
    if isSubscribing {
      loadTripData(true)
      startRefreshTimmer()
    }
    collectionView?.reloadData()
  }
  
  /**
   * Backgrounded.
   */
  func didBecomeInactive() {
    collectionView?.backgroundView?.hidden = true
    stopRefreshTimmer()
  }
  
  /**
   * Starts the refresh timmer
   */
  func startRefreshTimmer() {
    stopRefreshTimmer()
    refreshTimmer = NSTimer.scheduledTimerWithTimeInterval(
      5.0, target: self, selector: Selector("refreshUI"), userInfo: nil, repeats: true)
  }
  
  func refreshUI() {
    if isSubscribing {
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
    if isSubscribing {
      loadTripData(true)
    } else {
      refreshController.endRefreshing()
    }
  }
  
  /**
   * On user taps help
   */
  @IBAction func onHelpTap(sender: AnyObject) {
    if let url = NSURL(string: "http://www.ressmartapp.se/faq.php") {
      let svc = SFSafariViewController(URL: url)
      
      svc.navigationController?.navigationBar.barTintColor = StyleHelper.sharedInstance.mainGreen
      self.presentViewController(svc, animated: true, completion: nil)
    }
  }
  
  /**
   * On user taps subscribe button
   */
  @IBAction func onSubscribeTap(sender: UIButton) {
    performSegueWithIdentifier("ShowSubscribe", sender: self)
  }
  
  /**
   * On user taps restore button
   */
  @IBAction func onRestoreSubscription(sender: UIButton) {
    showRestoreSubscriptionAlert()
  }
  
  /**
   * Unwind (back) to this view.
   */
  @IBAction func unwindToRoutineTripsVC(segue: UIStoryboardSegue) {}
  
  
  // MARK: UICollectionViewController
  
  /**
  * Section count
  */
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    if !isSubscribing {
      return 1
    }
    return 2
  }
  
  /**
   * Item count for section
   */
  override func collectionView(collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
      if isLoading {
        return 0
      }
      
      if section == 0 {
        if isShowInfo || !isSubscribing {
          return 1
        }
        var bestCount = (bestRoutineTrip == nil ? 0 : 1)
        if MyLocationHelper.sharedInstance.getCurrentLocation() != nil {
          bestCount++
        }
        return bestCount
      }
      
      return otherRoutineTrips.count
  }
  
  /**
   * Create cells for each data post.
   */
  override func collectionView(collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      if indexPath.section == 0 {
        if !isSubscribing {
          return createSubscriptionInfoCell(indexPath)
        } else if isShowInfo {
          return createInfoTripCell(indexPath)
        }
        
        if indexPath.row == 0 {
          if let routineTrip = bestRoutineTrip {
            return createRoutineTripCell(routineTrip, type: cellIdentifier, indexPath: indexPath)
          } else {
            return createHereToThereCell(indexPath)
          }
        } else if indexPath.row == 1 {
          return createHereToThereCell(indexPath)
        }
        fatalError("Could not create cell.")
      }
      return createRoutineTripCell(otherRoutineTrips[indexPath.row], type: simpleCellIdentifier, indexPath: indexPath)
  }
  
  /**
   * View for supplementary (header/footer)
   */
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    
    let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(
      UICollectionElementKindSectionHeader,
      withReuseIdentifier: headerCellIdentifier,
      forIndexPath: indexPath) as! RoutineTripHeader
    
    return reusableView
  }
  
  /**
   * Size for items.
   */
  func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      
      let screenSize = UIScreen.mainScreen().bounds.size
      if indexPath.section == 0 {
        if !isSubscribing {
          return CGSizeMake(screenSize.width - 20, 330)
        } else if isShowInfo {
          return CGSizeMake(screenSize.width - 20, 275)
        } else if bestRoutineTrip!.criterions.isAdvanced {
          if indexPath.row == 0 {
            return CGSizeMake(screenSize.width - 20, 165)
          }
          return CGSizeMake(screenSize.width - 20, 65)
        }
        if indexPath.row == 0 && bestRoutineTrip != nil {
          return CGSizeMake(screenSize.width - 20, 145)
        }
        return CGSizeMake(screenSize.width - 20, 60)
      }
      
      if otherRoutineTrips[indexPath.row].criterions.isAdvanced {
        return CGSizeMake(screenSize.width - 20, 115)
      }
      return CGSizeMake(screenSize.width - 20, 95)
  }
  
  /**
   * Size for headers.
   */
  func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSection section: Int) -> CGSize {
      
      if section == 0  {
        return CGSizeMake(0, 0)
      } else if section == 1 && otherRoutineTrips.count == 0 {
        return CGSizeMake(0, 0)
      }
      
      return CGSizeMake(self.collectionView!.frame.size.width, 50)
  }
  
  /**
   * User taps an item.
   */
  override func collectionView(
    collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
      
      if !isShowInfo && !isLoading && isSubscribing {
        if indexPath.section == 0 && (indexPath.row == 1 || bestRoutineTrip == nil) {
          performSegueWithIdentifier(fromHereToThereSegue, sender: self)
          return
        }
        
        hereToThereCriterion = nil
        selectedRoutineTrip = bestRoutineTrip
        var scoreMod = ScorePostHelper.BestTapCountScore
        
        if indexPath.section != 0 {
          selectedRoutineTrip = otherRoutineTrips[indexPath.row]
          scoreMod = ScorePostHelper.OtherTapCountScore
          ScorePostHelper.changeScoreForRoutineTrip(
            bestRoutineTrip!.criterions.origin!.siteId!,
            destinationId: bestRoutineTrip!.criterions.dest!.siteId!,
            score: ScorePostHelper.NotBestTripScore)
        }
        
        ScorePostHelper.changeScoreForRoutineTrip(
          selectedRoutineTrip!.criterions.origin!.siteId!,
          destinationId: selectedRoutineTrip!.criterions.dest!.siteId!,
          score: scoreMod)
        performSegueWithIdentifier(showTripListSegue, sender: self)
      }
  }
  
  /**
   * Green highlight on selected row.
   */
  override func collectionView(collectionView: UICollectionView,
    willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
      if isSubscribing && !isShowInfo && !isLoading {
        let bgColorView = UIView()
        bgColorView.backgroundColor = StyleHelper.sharedInstance.mainGreenLight
        cell.selectedBackgroundView = bgColorView
      }
  }
  
  // MARK: LocationSearchResponder
  
  @IBAction func unwindToStationSearchParent(segue: UIStoryboardSegue) {}
  
  /**
   * User selected location (for From here to there feature)
   */
  func selectedLocationFromSearch(location: Location) {
    if let currentLocation = MyLocationHelper.sharedInstance.getCurrentLocation() {
      let crit = TripSearchCriterion(origin: currentLocation, dest: location)
      let date = NSDate(timeIntervalSinceNow: (60 * 2) * -1)
      crit.date = DateUtils.dateAsDateString(date)
      crit.time = DateUtils.dateAsTimeString(date)
      hereToThereCriterion = crit
      
      RoutineService.addHabitRoutine(crit)
      performSegueWithIdentifier(self.showTripListSegue, sender: self)
    }
  }
  
  // MARK: Private methods
  
  /**
  * Setup collection view properties and layout.
  */
  private func setupCollectionView() {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    
    collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    collectionView?.collectionViewLayout = flowLayout
    collectionView?.delegate = self
    
    view.backgroundColor = StyleHelper.sharedInstance.background
    
    let wrapper = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let imageView = UIImageView(
      image: UIImage(named: "TrainSplash")?.imageWithRenderingMode(.AlwaysTemplate))
    imageView.tintColor = UIColor.whiteColor()
    imageView.frame.size = CGSizeMake(30, 30)
    imageView.frame.origin.y = 5
    imageView.frame.origin.x = 6
    
    wrapper.addSubview(imageView)
    self.navigationItem.titleView = wrapper
  }
  
  /**
   * Setup the "pull down to reload" controller.
   */
  private func setupRefreshController() {
    refreshController.addTarget(self,
      action: Selector("onRefreshController"), forControlEvents: UIControlEvents.ValueChanged)
    refreshController.tintColor = UIColor.lightGrayColor()
    collectionView?.addSubview(refreshController)
    collectionView?.alwaysBounceVertical = true
  }
  
  /**
   * Setup table's background spinner.
   */
  private func setupTableActivityIndicator() {
    tableActivityIndicator.startAnimating()
    tableActivityIndicator.color = UIColor.lightGrayColor()
    collectionView?.backgroundView = tableActivityIndicator
  }
  
  /**
   * Setup notification listeners.
   */
  private func setupNotificationListeners() {
    NSNotificationCenter.defaultCenter().addObserver(
      self, selector: Selector("didBecomeActive"),
      name: UIApplicationDidBecomeActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(
      self, selector: "didBecomeInactive",
      name: UIApplicationWillResignActiveNotification, object: nil)
  }
  
  /**
   * Loading the trip data, and starting background
   * collection of time table data.
   * Will show big spinner when loading.
   */
  private func loadTripData(force: Bool) {
    if isSubscribing {
      if RoutineTripsStore.sharedInstance.isRoutineTripsEmpty(){
        isShowInfo = true
        otherRoutineTrips = [RoutineTrip]()
        bestRoutineTrip = nil
        selectedRoutineTrip = nil
        stopLoading()
      } else if shouldReload() || force {
        startLoading()
        RoutineService.findRoutineTrip({ routineTrips in
          dispatch_async(dispatch_get_main_queue()) {
            self.stopLoading()
            NetworkActivity.displayActivityIndicator(false)
            if routineTrips.count > 0 {
              self.bestRoutineTrip = routineTrips.first!
              self.otherRoutineTrips = Array(routineTrips[1..<routineTrips.count])
              self.lastUpdated = NSDate()
            }
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
  private func shouldReload() -> Bool {
    if let routine = bestRoutineTrip, let trip = routine.trips.first {
      let departureDate = trip.tripSegments.first!.departureDateTime
      if NSDate().timeIntervalSinceDate(departureDate) > 30 {
        return true
      }
    }
    return (NSDate().timeIntervalSinceDate(lastUpdated) > 120)
  }
  
  /**
   * On trip search done.
   */
  private func startLoading() {
    NetworkActivity.displayActivityIndicator(true)
    isShowInfo = false
    isLoading = true
    otherRoutineTrips = [RoutineTrip]()
    bestRoutineTrip = nil
    selectedRoutineTrip = nil
    collectionView?.reloadData()
    refreshController.endRefreshing()
    collectionView?.backgroundView = tableActivityIndicator
    tableActivityIndicator.startAnimating()
  }
  
  /**
   * On trip search done.
   */
  private func stopLoading() {
    isLoading = false
    refreshController.endRefreshing()
    collectionView?.backgroundView = nil
    collectionView?.reloadData()
  }
  
  /**
   * Create best trip cell
   */
  private func createRoutineTripCell(trip: RoutineTrip, type: String, indexPath: NSIndexPath) -> RoutineTripCell {
    let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(
      type, forIndexPath: indexPath) as! RoutineTripCell
    
    let isBest = (type == cellIdentifier) ? true : false
    cell.setupData(trip, isBest: isBest)
    return cell
  }
  
  /**
   * Create info trip cell
   */
  private func createInfoTripCell(indexPath: NSIndexPath) -> UICollectionViewCell {
    return collectionView!.dequeueReusableCellWithReuseIdentifier(
      infoCellIdentifier, forIndexPath: indexPath)
  }
  
  /**
   * Create subscription info trip cell
   */
  private func createSubscriptionInfoCell(indexPath: NSIndexPath) -> UICollectionViewCell {
    return collectionView!.dequeueReusableCellWithReuseIdentifier(
      subscriptionInfoCellIdentifier, forIndexPath: indexPath)
  }
  
  /**
   * Create "From here to there" cell
   */
  private func createHereToThereCell(indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(
      hereToThereCellIdentifier, forIndexPath: indexPath) as! HereToThereCell
    
    if let currentLocation = MyLocationHelper.sharedInstance.getCurrentLocation() {
      cell.hereToThereLabel.text = String(format: NSLocalizedString("Från %@", comment: ""), currentLocation.name)
    }
    
    return cell
  }
  
  /**
   * Show no location servie popup
   */
  private func showLocationServicesNotAllowed() {
    let invalidLocationAlert = UIAlertController(
      title: "Platstjänster ej aktiverad",
      message: "Kontrollera att platstjänster är aktiverade och att de tillåts för Res Smart.\n\n(Inställningar -> Integritetsskydd -> Platstjänster)",
      preferredStyle: UIAlertControllerStyle.Alert)
    invalidLocationAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.Default, handler: nil))
    
    presentViewController(invalidLocationAlert, animated: true, completion: nil)
  }
  
  /**
   * Show restore subscription alert
   */
  private func showRestoreSubscriptionAlert() {
    let restoreAlert = UIAlertController(
      title: NSLocalizedString("Söker prenumeration", comment: ""),
      message: NSLocalizedString("Om en aktiv prenumeration finns kommer denna automatiskt att aktiveras för denna enhet.\n\nDu kan själv kontrollera dina prenumerationer på din iPhone under Inställningar -> App Store och iTunes Store -> Tryck på ditt Apple-ID -> Visa Apple-ID", comment: ""),
      preferredStyle: UIAlertControllerStyle.Alert)
    restoreAlert.addAction(
      UIAlertAction(title: NSLocalizedString("Okej", comment: ""), style: UIAlertActionStyle.Default, handler: { _ in
        self.startLoading()
        self.isSubscribing = true
        self.collectionView?.reloadData()
        SubscriptionManager.sharedInstance.restoreSubscription()
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(10.0 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
          self.isSubscribing = false
          self.stopLoading()
          NetworkActivity.displayActivityIndicator(false)
          self.viewWillAppear(true)
        })
      }))
    
    presentViewController(restoreAlert, animated: true, completion: nil)
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

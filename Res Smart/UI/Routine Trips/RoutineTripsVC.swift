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

class RoutineTripsVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  let cellIdentifier = "RoutineTripCell"
  let simpleCellIdentifier = "SimpleRoutineTripCell"
  let loadingCellIdentifier = "LoadingCell"
  let headerCellIdentifier = "HeaderView"
  let showTripListSegue = "ShowTripList"
  let infoCellIdentifier = "InfoCell"
  let subscriptionInfoCellIdentifier = "SubscriptionInfoCell"
  let hereToThereCellIdentifier = "HereToThere"
  
  var bestRoutineTrip: RoutineTrip?
  var otherRoutineTrips = [RoutineTrip]()
  var selectedRoutineTrip: RoutineTrip?
  var isSubscribing = false
  var isLoading = true
  var isShowInfo = false
  var lastUpdated = NSDate(timeIntervalSince1970: NSTimeInterval(0.0))
  var refreshButton: UIBarButtonItem?
  
  /**
   * View is done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNotificationListeners()
    setupCollectionView()
    refreshButton = navigationItem.leftBarButtonItem
  }
  
  /**
   * View is about to display.
   */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    isSubscribing = SubscriptionStore.sharedInstance.isSubscribed()
    if isSubscribing {
      navigationItem.rightBarButtonItem?.enabled = true
      if CLLocationManager.authorizationStatus() == .Denied || !CLLocationManager.locationServicesEnabled() {
        showLocationServicesNotAllowed()
        MyLocationHelper.sharedInstance.isStarted = false
        return
      }
      loadTripData(false)
      return
    }
    navigationItem.rightBarButtonItem?.enabled = false
    refreshButton?.enabled = false
    collectionView?.reloadData()
  }
  
  /**
   * Prepares for segue
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == showTripListSegue {
      if let routineTrip = selectedRoutineTrip {
        if let crit = routineTrip.criterions.copy() as? TripSearchCriterion {
          let date = NSDate(timeIntervalSinceNow: (60 * 2) * -1)
          crit.date = DateUtils.dateAsDateString(date)
          crit.time = DateUtils.dateAsTimeString(date)
          
          let vc = segue.destinationViewController as! TripListVC
          vc.criterions = crit
          vc.title = routineTrip.title
        }
      }
      
    } else if segue.identifier == "ManageRoutineTrips" {
      // Force a reload when returning to this VC
      lastUpdated = NSDate(timeIntervalSince1970: NSTimeInterval(0.0))
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
    loadTripData(true)
  }
  
  /**
   * On user taps refresh
   */
  @IBAction func onRefreshTap(sender: AnyObject) {
    loadTripData(true)
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
    return 2
  }
  
  /**
   * Item count for section
   */
  override func collectionView(collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
      if section == 0 {
        if isLoading || isShowInfo || !isSubscribing {
          return 1
        }
        let bestCount = (bestRoutineTrip == nil ? 1 : 2)
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
        } else if isLoading {
          return createLoadingTripCell(indexPath)
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
        } else if isLoading {
          return CGSizeMake(screenSize.width - 20, collectionView.bounds.height - 49 - 64 - 20)
        } else if isShowInfo {
          return CGSizeMake(screenSize.width - 20, 275)
        } else if bestRoutineTrip!.criterions.isAdvanced {
          if indexPath.row == 0 {
            return CGSizeMake(screenSize.width - 20, 160)
          }
          return CGSizeMake(screenSize.width - 20, 40)
        }
        if indexPath.row == 0 && bestRoutineTrip != nil {
          return CGSizeMake(screenSize.width - 20, 145)
        }
        return CGSizeMake(screenSize.width - 20, 40)
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
      if !isShowInfo && !isLoading {
        
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
      let bgColorView = UIView()
      bgColorView.backgroundColor = StyleHelper.sharedInstance.mainGreenLight
      cell.selectedBackgroundView = bgColorView
  }
  
  // MARK: Private methods
  
  /**
  * Setup collection view properties and layout.
  */
  private func setupCollectionView() {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
    
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
   * Setup notification listeners.
   */
  private func setupNotificationListeners() {
    NSNotificationCenter.defaultCenter().addObserver(
      self, selector: Selector("didBecomeActive"),
      name: UIApplicationDidBecomeActiveNotification, object: nil)
  }
  
  /**
   * Loading the trip data, and starting background
   * collection of time table data.
   * Will show big spinner when loading.
   */
  private func loadTripData(force: Bool) {
    if RoutineTripsStore.sharedInstance.isRoutineTripsEmpty() {
      isShowInfo = true
      isLoading = false
      self.refreshButton?.enabled = false
      self.collectionView?.reloadSections(NSIndexSet(indexesInRange: NSRange.init(location: 0, length: 1)))
    } else if shouldReload() || force {
      otherRoutineTrips = [RoutineTrip]()
      bestRoutineTrip = nil
      selectedRoutineTrip = nil
      isShowInfo = false
      self.isLoading = true
      refreshButton?.enabled = false
      collectionView?.reloadData()
      RoutineService.findRoutineTrip({ routineTrips in
        if routineTrips.count > 0 {
          self.bestRoutineTrip = routineTrips.first!
          self.otherRoutineTrips = Array(routineTrips[1..<routineTrips.count])
          dispatch_async(dispatch_get_main_queue()) {
            self.lastUpdated = NSDate()
            self.tripSearchDone()
            self.collectionView?.reloadSections(NSIndexSet(index: 1))
          }
        }
      })
    } else {
      self.collectionView?.reloadData()
    }
  }
  
  /**
   * Checks if data should be reloaded.
   */
  private func shouldReload() -> Bool {
    return (NSDate().timeIntervalSinceDate(lastUpdated) > 60)
  }
  
  /**
   * On trip search done.
   */
  private func tripSearchDone() {
    self.isLoading = false
    self.refreshButton?.enabled = true
    self.navigationItem.leftBarButtonItem = self.refreshButton
    self.collectionView?.reloadData()
  }
  
  /**
   * Create best trip cell
   */
  private func createRoutineTripCell(trip: RoutineTrip, type: String, indexPath: NSIndexPath) -> RoutineTripCell {
    let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(type,
      forIndexPath: indexPath) as! RoutineTripCell
    
    let isBest = (type == cellIdentifier) ? true : false
    cell.setupData(trip, isBest: isBest)
    return cell
  }
  
  /**
   * Create loading trip cell
   */
  private func createLoadingTripCell(indexPath: NSIndexPath) -> UICollectionViewCell {
    return collectionView!.dequeueReusableCellWithReuseIdentifier(loadingCellIdentifier,
      forIndexPath: indexPath)
  }
  
  /**
   * Create info trip cell
   */
  private func createInfoTripCell(indexPath: NSIndexPath) -> UICollectionViewCell {
    return collectionView!.dequeueReusableCellWithReuseIdentifier(infoCellIdentifier,
      forIndexPath: indexPath)
  }
  
  /**
   * Create subscription info trip cell
   */
  private func createSubscriptionInfoCell(indexPath: NSIndexPath) -> UICollectionViewCell {
    return collectionView!.dequeueReusableCellWithReuseIdentifier(subscriptionInfoCellIdentifier,
      forIndexPath: indexPath)
  }
  
  /**
   * Create "From here to there" cell
   */
  private func createHereToThereCell(indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(hereToThereCellIdentifier,
      forIndexPath: indexPath)
    cell.layer.masksToBounds = false
    cell.layer.shadowOffset = CGSizeMake(1, 1)
    cell.layer.shadowRadius = 2.0
    cell.layer.shadowColor = UIColor.blackColor().CGColor
    cell.layer.shadowOpacity = 0.15
    cell.layer.cornerRadius = 4.0
    cell.clipsToBounds = false
    
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
      title: "Försöker återuppta prenumeration",
      message: "Om en aktiv prenumeration finns kommer denna automatiskt att aktiveras för denna enhet.\n\nDu kan själv kontrollera dina prenumerationer på din iPhone under Inställningar -> App Store och iTunes Store -> Tryck på ditt Apple-ID -> Visa Apple-ID",
      preferredStyle: UIAlertControllerStyle.Alert)
    restoreAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.Default, handler: { _ in
        self.isLoading = true
        self.isSubscribing = true
        self.collectionView?.reloadData()
        SubscriptionManager.sharedInstance.restoreSubscription()
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(10.0 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
          self.isSubscribing = false
          self.isLoading = false
          self.viewWillAppear(true)
        })
      }))
    
    presentViewController(restoreAlert, animated: true, completion: nil)
  }
}
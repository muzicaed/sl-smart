//
//  RoutineTripsVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class RoutineTripsVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  let cellIdentifier = "RoutineTripCell"
  let simpleCellIdentifier = "SimpleRoutineTripCell"
  let loadingCellIdentifier = "LoadingCell"
  let headerCellIdentifier = "HeaderView"
  let showTripListSegue = "ShowTripList"
  let infoCellIdentifier = "InfoCell"
  
  var bestRoutineTrip: RoutineTrip?
  var otherRoutineTrips = [RoutineTrip]()
  var selectedRoutineTrip: RoutineTrip?
  var isShowMore = false
  var isLoading = true
  var isShowInfo = false
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
    hardLoadTripData()
  }
  
  /**
   * Title tap
   */
  func onMoreTap() {
    if !self.isLoading {
      isShowMore = !isShowMore
      self.collectionView?.reloadSections(NSIndexSet(index: 1))
    }
  }
  
  /**
   * Prepares for segue
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let routineTrip = selectedRoutineTrip {
      if segue.identifier == showTripListSegue {
        let vc = segue.destinationViewController as! TripListVC
        let criterions = TripSearchCriterion(
          origin: routineTrip.origin!, destination: routineTrip.destination!)
        
        let date = NSDate(timeIntervalSinceNow: (60 * 5) * -1)
        criterions.date = DateUtils.dateAsDateString(date)
        criterions.time = DateUtils.dateAsTimeString(date)
        
        vc.criterions = criterions
        vc.title = routineTrip.title
      }
    }
  }
  
  /**
   * Triggered when is about to go into backgorund.
   */
  func didBecomeActive() {
    hardLoadTripData()
  }
  
  /**
   * On user taps refresh
   */
  @IBAction func onRefreshTap(sender: AnyObject) {
    hardLoadTripData()
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
        if isLoading || isShowInfo {
          return 1
        }
        let bestCount = (bestRoutineTrip == nil ? 0 : 1)
        return bestCount
      }
      
      if isShowMore {
        return otherRoutineTrips.count
      }
      
      return 0
  }
  
  /**
   * Create cells for each data post.
   */
  override func collectionView(collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      if indexPath.section == 0 {
        if isLoading {
          return createLoadingTripCell(indexPath)
        } else if isShowInfo {
          return createInfoTripCell(indexPath)
        }
        
        if let routineTrip = bestRoutineTrip {
          return createRoutineTripCell(routineTrip, type: cellIdentifier, indexPath: indexPath)
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
    
    if indexPath.section == 0 {
      return reusableView
    }
    
    reusableView.gestureRecognizers = [
      UITapGestureRecognizer(target: self, action: Selector("onMoreTap"))
    ]
    
    if isShowMore {
      reusableView.titleLabel.text = "Fler rutiner"
      reusableView.arrowLabel.text = "▲"
    } else {
      reusableView.titleLabel.text = "Visa fler rutiner"
      reusableView.arrowLabel.text = "▼"
    }
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
        if isLoading {
          return CGSizeMake(screenSize.width - 10, collectionView.bounds.height - 49 - 64 - 20)
        } else if isShowInfo {
          return CGSizeMake(screenSize.width - 10, 345)
        }
        return CGSizeMake(screenSize.width - 10, 125)
      }
      
      return CGSizeMake(screenSize.width - 10, 90)
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
        if indexPath.section == 0 {
          selectedRoutineTrip = bestRoutineTrip
        } else {
          selectedRoutineTrip = otherRoutineTrips[indexPath.row]
        }
        
        ScorePostHelper.addScoreForSelectedRoutineTrip(
          selectedRoutineTrip!.origin!.siteId,
          destinationId: selectedRoutineTrip!.destination!.siteId)
        performSegueWithIdentifier(showTripListSegue, sender: self)
      }
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
    
    StandardGradient.addLayer(view)
    
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
  private func hardLoadTripData() {
    if DataStore.sharedInstance.isRoutineTripsEmpty() {
      isShowInfo = true
      isLoading = false
      self.refreshButton?.enabled = false
    } else {
      otherRoutineTrips = [RoutineTrip]()
      bestRoutineTrip = nil
      selectedRoutineTrip = nil
      isShowMore = false
      isShowInfo = false
      self.isLoading = true
      refreshButton?.enabled = false
      collectionView?.reloadData()
      RoutineService.findRoutineTrip({ routineTrips in
        if routineTrips.count > 0 {
          self.bestRoutineTrip = routineTrips.first!
          self.otherRoutineTrips = Array(routineTrips[1..<routineTrips.count])
          dispatch_async(dispatch_get_main_queue(), {
            self.tripSearchDone()
            self.collectionView?.reloadSections(NSIndexSet(index: 1))
          })
        }
      })
    }
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
    cell.setupData(trip)
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
  
  deinit {
    print("Deinit: RoutineTripsVC")
  }
}
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
  var bestRoutineTrip: RoutineTrip?
  var otherRoutineTrips = [RoutineTrip]()
  var isShowMore = false
  var isLoading = true
  
  /**
   * View is done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
  }
  
  /**
   * View is about to display.
   */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    isShowMore = false
    isLoading = true
    bestRoutineTrip = nil
    otherRoutineTrips = [RoutineTrip]()
    collectionView?.reloadData()
    loadTripData()
  }
  
  /**
   * Unwind (back) to this view.
   */
  @IBAction func unwindToRoutineTripsVC(segue: UIStoryboardSegue) {}
  
  
  // MARK: UICollectionViewDataSource
  
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
        if isLoading {
          return 1
        }
        let bestCount = (bestRoutineTrip == nil ? 0 : 1)
        return bestCount
      }
      
      if isShowMore {
        return min(otherRoutineTrips.count, 4)
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
        }
        return createBestTripCell(bestRoutineTrip!, indexPath: indexPath)
      }
      return createSimpleTripCell(bestRoutineTrip!, indexPath: indexPath)
  }
  
  /**
   * View for supplementary (header/footer)
   */
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    
    let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(
      UICollectionElementKindSectionHeader,
      withReuseIdentifier: "HeaderView",
      forIndexPath: indexPath) as! RoutineTripHeader
    
    if indexPath.section == 0 {
      return reusableView
    }
    
    reusableView.gestureRecognizers = [
      UITapGestureRecognizer(target: self, action: Selector("onMoreTap"))
    ]
    
    if isShowMore {
      reusableView.titleLabel.text = "Andra resor härifrån"
      reusableView.arrowLabel.text = "▲"
    } else {
      reusableView.titleLabel.text = "Visa andra resor härifrån"
      reusableView.arrowLabel.text = "▼"
    }
    return reusableView
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
   * Size for items.
   */
  func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      
      let screenSize = UIScreen.mainScreen().bounds.size
      if indexPath.section == 0 {
        return CGSizeMake(screenSize.width - 20, 110)
      }
      
      return CGSizeMake(screenSize.width - 20, 90)
  }
  
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
    
    view.backgroundColor = UIColor(patternImage: UIImage(named: "GreenBackground")!)
  }
  
  /**
   * Loading the trip data, and starting background
   * collection of time table data.
   */
  private func loadTripData() {
    RoutineService.sharedInstance.findRoutineTrip({ routineTrips in
      if routineTrips.count > 0 {
        self.bestRoutineTrip = routineTrips[0]
        self.otherRoutineTrips = Array(routineTrips[1..<routineTrips.count])
        SearchTripService.sharedInstance.simpleSingleTripSearch(
          self.bestRoutineTrip!.origin!,
          destination: self.bestRoutineTrip!.destination!,
          callback: { trip in
            dispatch_async(dispatch_get_main_queue(), {
              self.bestRoutineTrip!.trip = trip
              self.isLoading = false
              self.collectionView?.reloadData()
              self.collectionView?.reloadSections(NSIndexSet(index: 1))
            })
        })
      }
      // TODO: No trips display help box...
      return
    })
  }
  
  /**
   * Create best trip cell
   */
  private func createBestTripCell(trip: RoutineTrip, indexPath: NSIndexPath) -> RoutineTripCell {
    let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(cellIdentifier,
      forIndexPath: indexPath) as! RoutineTripCell
    cell.setupData(trip)
    return cell
  }
  
  /**
   * Create simple trip cell
   */
  private func createSimpleTripCell(trip: RoutineTrip, indexPath: NSIndexPath) -> RoutineTripCell {
    let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(simpleCellIdentifier,
      forIndexPath: indexPath) as! RoutineTripCell
    cell.setupData(otherRoutineTrips[indexPath.row])
    return cell
  }
  
  /**
   * Create loading trip cell
   */
  private func createLoadingTripCell(indexPath: NSIndexPath) -> UICollectionViewCell {
    return collectionView!.dequeueReusableCellWithReuseIdentifier(loadingCellIdentifier,
      forIndexPath: indexPath)
  }
}
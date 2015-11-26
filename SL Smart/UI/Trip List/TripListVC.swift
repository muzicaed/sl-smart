//
//  TripListVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class TripListVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  let cellIdentifier = "TripCell"
  let loadingCellIdentifier = "LoadingCell"
  
  var criterions: TripSearchCriterion?
  var trips = [Trip]()
  var isLoading = true
  
  /**
   * View is done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView?.delegate = self    
    StandardGradient.addLayer(view)
    if trips.count == 0 {
      loadTripData()
    } else {
      isLoading = false
      self.collectionView?.reloadData()
    }
  }
  
  /**
   * Unwind (back) to this view.
   */
  @IBAction func unwindToTripListVC(segue: UIStoryboardSegue) {}
  
  
  // MARK: UICollectionViewController
  
  /**
  * Item count for section
  */
  override func collectionView(collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
      if isLoading || trips.count == 0 {
        return 1
      }
      
      return trips.count
  }
  
  /**
   * Create cells for each data post.
   */
  override func collectionView(collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      if isLoading {
        return createLoadingTripCell(indexPath)
      }
      return createTripCell(trips[indexPath.row], indexPath: indexPath)
  }
  
  /**
   * Size for items.
   */
  func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      let screenSize = UIScreen.mainScreen().bounds.size
      if isLoading {
        return CGSizeMake(screenSize.width - 10, collectionView.bounds.height - 49 - 64 - 20)
      }
      return CGSizeMake(screenSize.width, 90)
  }
  
  // MARK: Private methods
  
  /**
  * Loading the trip data, and starting background
  * collection of time table data.
  */
  private func loadTripData() {
    if let criterions = self.criterions {
      SearchTripService.sharedInstance.tripSearch(criterions,
        callback: { trips in
          dispatch_async(dispatch_get_main_queue(), {
            self.trips = trips
            self.isLoading = false
            self.collectionView?.reloadData()
          })
      })
      return
    }
    fatalError("Criterions not set in TripListVC")
  }
  
  /**
   * Create trip cell
   */
  private func createTripCell(trip: Trip, indexPath: NSIndexPath) -> TripCell {
    let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(cellIdentifier,
      forIndexPath: indexPath) as! TripCell
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
}
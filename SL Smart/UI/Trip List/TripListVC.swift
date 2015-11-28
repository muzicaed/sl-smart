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
  let noTripsFoundCell = "FoundNoTripsCell"
  let headerIdentifier = "DateHeader"
  let footerIdentifier = "LoadMoreFooter"
  
  
  var footer: TripFooter?
  var criterions: TripSearchCriterion?
  var trips = [Trip]()
  var isLoading = true
  var isLoadingMore = false
  var originalDate = NSDate()
  
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
   * Number of sections
   */
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
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
      } else if trips.count == 0 {
        return createNoTripsFoundCell(indexPath)
      }
      return createTripCell(trips[indexPath.row], indexPath: indexPath)
  }
  
  /**
   * Size for headers.
   */
  func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSection section: Int) -> CGSize {
      
      if isLoading  {
        return CGSizeMake(0, 0)
      }
      
      let screenSize = UIScreen.mainScreen().bounds.size
      return CGSizeMake(screenSize.width - 10, 35)
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
      return CGSizeMake(screenSize.width - 10, 90)
  }
  
  /**
   * View for supplementary (header/footer)
   */
  override func collectionView(collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
      
    if kind == UICollectionElementKindSectionHeader {
      let header = collectionView.dequeueReusableSupplementaryViewOfKind(
        UICollectionElementKindSectionHeader,
        withReuseIdentifier: headerIdentifier,
        forIndexPath: indexPath)
      
      return header
    }
    
    footer = collectionView.dequeueReusableSupplementaryViewOfKind(
      UICollectionElementKindSectionFooter,
      withReuseIdentifier: footerIdentifier,
      forIndexPath: indexPath) as? TripFooter
    
    return footer!
  }
  
  // MARK: UIScrollViewDelegate
  
  /**
  * On scroll
  * Will check if we scrolled to bottom
  */
  override func scrollViewDidScroll(scrollView: UIScrollView) {    
    if scrollView.contentSize.height > 60 {
      let bottomEdge = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.height
      var overflow = scrollView.contentOffset.y - bottomEdge
      if scrollView.contentSize.height < scrollView.bounds.height {
        overflow =  scrollView.contentInset.top + scrollView.contentOffset.y
      }

      if overflow > 0 && !isLoadingMore  {
        footer?.displaySpinner(overflow / 45)
        if overflow >= 45 {
          if self.trips.count > 0 {
            isLoadingMore = true
            footer?.displaySpinner(1.0)
            let trip = self.trips.last!
            criterions?.time = Utils.dateAsTimeString(
              trip.tripSegments.last!.departureDateTime.dateByAddingTimeInterval(60))
            loadTripData()
          }
        }
      }
    }
  }
  
  // MARK: Private methods
  
  /**
  * Loading the trip data, and starting background
  * collection of time table data.
  */
  private func loadTripData() {
    if let criterions = self.criterions {
      SearchTripService.tripSearch(criterions,
        callback: { trips in
          dispatch_async(dispatch_get_main_queue(), {
            self.trips.appendContentsOf(trips)
            self.isLoading = false
            self.isLoadingMore = false
            self.footer?.displayLabel()
            self.collectionView?.reloadData()
            
            self.updateDateCriterions()
          })
      })
      return
    }
    fatalError("Criterions not set in TripListVC")
  }
  
  /**
   * Checks if a day passed in the search result, and update
   * the search criterions in that case.
   */
  private func updateDateCriterions() {
    let cal = NSCalendar.currentCalendar()
    let departDate = trips.last!.tripSegments.last!.departureDateTime
    let departDay = cal.ordinalityOfUnit(.Day, inUnit: .Year, forDate: departDate)
    let criterionDate = Utils.convertDateString("\(criterions!.date!) \(criterions!.time!)")
    let criterionDay = cal.ordinalityOfUnit(.Day, inUnit: .Year, forDate: criterionDate)

    if departDay != criterionDay {
      criterions?.date = Utils.dateAsDateString(departDate)
    }
  }
  
  /**
   * Create trip cell
   */
  private func createTripCell(trip: Trip, indexPath: NSIndexPath) -> TripCell {
    let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(cellIdentifier,
      forIndexPath: indexPath) as! TripCell
    cell.setupData(trip, originalDate: originalDate)
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
   * Create "No trips found" trip cell
   */
  private func createNoTripsFoundCell(indexPath: NSIndexPath) -> UICollectionViewCell {
    return collectionView!.dequeueReusableCellWithReuseIdentifier(noTripsFoundCell,
      forIndexPath: indexPath)
  }
  
  deinit {
    print("Deinit: TipListVC")
  }
}
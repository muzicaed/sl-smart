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
  let pastCellIdentifier = "PassedTripCell"
  let loadingCellIdentifier = "LoadingCell"
  let noTripsFoundCell = "FoundNoTripsCell"
  let headerIdentifier = "DateHeader"
  let footerIdentifier = "LoadMoreFooter"
  let showDetailsSegue = "ShowDetails"
  
  var footer: TripFooter?
  var criterions: TripSearchCriterion?
  var keys = [String]()
  var trips = Dictionary<String, [Trip]>()
  var selectedTrip: Trip?
  var isLoading = true
  var isLoadingMore = false
  
  /**
   * View is done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    StandardGradient.addLayer(view)    
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
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == showDetailsSegue {
      let vc = segue.destinationViewController as! TripDetailsVC
      vc.trip = selectedTrip!
    }
  }
  
  
  /**
   * On footer tap
   */
  func footerTap() {
    if trips.count > 0 && !isLoadingMore {
      isLoadingMore = true
      footer?.displaySpinner(1.0)
      let trip = trips[keys.last!]!.last!
      criterions?.time = DateUtils.dateAsTimeString(
        trip.tripSegments.last!.departureDateTime.dateByAddingTimeInterval(60))
      loadTripData()
    }
  }
  
  // MARK: UICollectionViewController
  
  /**
  * Number of sections
  */
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    if isLoading || trips.count == 0 {
      return 1
    }
    return keys.count
  }
  
  /**
   * Item count for section
   */
  override func collectionView(collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
      if isLoading || trips.count == 0 {
        return 1
      }
      
      return trips[keys[section]]!.count
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
      
      return createTripCell(indexPath)
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
   * Size for footers.
   */
  func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForFooterInSection section: Int) -> CGSize {
      
      if isLoading  {
        return CGSizeMake(0, 0)
      }
      
      let screenSize = UIScreen.mainScreen().bounds.size
      return (section == keys.count - 1) ? CGSizeMake(screenSize.width - 10, 50) : CGSizeMake(0, 0)
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
   * User tapped a item.
   */
  override func collectionView(collectionView: UICollectionView,
    didSelectItemAtIndexPath indexPath: NSIndexPath) {
      let key = keys[indexPath.section]
      selectedTrip = trips[key]![indexPath.row]
      performSegueWithIdentifier(showDetailsSegue, sender: self)
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
          forIndexPath: indexPath) as! TripHeader
        
        let date = DateUtils.convertDateString("\(keys[indexPath.section]) 00:00")
        header.titleLabel.text = DateUtils.friendlyDate(date)
        return header
      }
      
      footer = collectionView.dequeueReusableSupplementaryViewOfKind(
        UICollectionElementKindSectionFooter,
        withReuseIdentifier: footerIdentifier,
        forIndexPath: indexPath) as? TripFooter
      
      let tapGesture = UITapGestureRecognizer(target: self, action: Selector("footerTap"))
      tapGesture.delaysTouchesBegan = true
      tapGesture.numberOfTapsRequired = 1
      footer?.addGestureRecognizer(tapGesture)
      
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
        footer?.displaySpinner(overflow / 60)
        if overflow >= 60 {
          if trips.count > 0 {
            isLoadingMore = true
            footer?.displaySpinner(1.0)
            
            let trip = trips[keys.last!]!.last!
            criterions?.time = DateUtils.dateAsTimeString(
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
        callback: { resTuple in
          dispatch_async(dispatch_get_main_queue(), {
            if let error = resTuple.error {
              print("\(error)")
              self.showNetworkErrorAlert()
              return
            }
            self.appendToDictionary(resTuple.data)
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
   * Appends search result to dictionary
   */
  private func appendToDictionary(tripsArr: [Trip]) {
    for trip in tripsArr {
      let destDateString = DateUtils.dateAsDateString(trip.tripSegments.last!.departureDateTime)
      if !keys.contains(destDateString) {
        keys.append(destDateString)
        trips[destDateString] = [Trip]()
      }
      trips[destDateString]!.append(trip)
    }
  }
  
  /**
   * Checks if a day passed in the search result, and update
   * the search criterions in that case.
   */
  private func updateDateCriterions() {
    let cal = NSCalendar.currentCalendar()
    let trip = trips[keys.last!]!.last!
    
    let departDate = trip.tripSegments.last!.departureDateTime
    let departDay = cal.ordinalityOfUnit(.Day, inUnit: .Year, forDate: departDate)
    let criterionDate = DateUtils.convertDateString("\(criterions!.date!) \(criterions!.time!)")
    let criterionDay = cal.ordinalityOfUnit(.Day, inUnit: .Year, forDate: criterionDate)
    
    if departDay != criterionDay {
      criterions?.date = DateUtils.dateAsDateString(departDate)
    }
  }
  
  /**
   * Create trip cell
   */
  private func createTripCell(indexPath: NSIndexPath) -> TripCell {
    let key = keys[indexPath.section]
    let trip = trips[key]![indexPath.row]
    
    if checkInPast(trip) {
      let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(pastCellIdentifier,
        forIndexPath: indexPath) as! TripCell
      cell.setupData(trip)
      return cell
    }
    
    let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(cellIdentifier,
      forIndexPath: indexPath) as! TripCell
    cell.setupData(trip)
    return cell
  }
  
  /**
   * Check if trip is in past.
   */
  private func checkInPast(trip: Trip) -> Bool{
    let date = trip.tripSegments.first!.departureDateTime
    return (NSDate().timeIntervalSince1970 > date.timeIntervalSince1970)
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
  
  /**
  * Show a network error alert
  */
  private func showNetworkErrorAlert() {
    let networkErrorAlert = UIAlertController(
      title: "Tjänsten är otillgänglig",
      message: "Det gick inte att kontakta söktjänsten.",
      preferredStyle: UIAlertControllerStyle.Alert)
    networkErrorAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.Default, handler: nil))
    
    presentViewController(networkErrorAlert, animated: true, completion: nil)
  }
  
  deinit {
    print("Deinit: TipListVC")
  }
}
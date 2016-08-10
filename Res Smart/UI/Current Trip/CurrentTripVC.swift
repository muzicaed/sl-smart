//
//  CurrentTripVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-08-09.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit
import CoreLocation

class CurrentTripVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  var currentTrip: Trip?
  var isStopsLoaded = false
  var stopsLoadCount = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
    loadStops()
  }
  
  /**
   * Close and terminate current trip.
   */
  @IBAction func closeCurrentTrip(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: UICollectionViewController
  
  /**
   * Create cells for each data post.
   */
  override func collectionView(collectionView: UICollectionView,
                               cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    if indexPath.row == 0 {
      return createRoutineTripCell(indexPath)
    } else if indexPath.row == 1 {
      return createChangeCell(indexPath)
    }
    return UICollectionViewCell()
  }
  
  /**
   * Item count for section
   */
  override func collectionView(collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return 2
  }
  
  /**
   * Size for items.
   */
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let screenSize = UIScreen.mainScreen().bounds.size
    if indexPath.row == 0 {
      return CGSizeMake(screenSize.width - 20, 150)
    } else if indexPath.row == 1 {
      return CGSizeMake(screenSize.width - 20, 120)
    }
    return CGSizeMake(0,0)
  }
  
  // MARK: Private
  
  /**
   * Create trip cell
   */
  private func createRoutineTripCell(indexPath: NSIndexPath) -> CurrentTripCell {
    let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(
      "CurrentTripCell", forIndexPath: indexPath) as! CurrentTripCell
    if let trip = currentTrip {
      cell.setupData(trip)
    }
    return cell
  }
  
  /**
   * Create change cell
   */
  private func createChangeCell(indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(
      "ChangeCell", forIndexPath: indexPath) as! ChangeCell
    if isStopsLoaded && currentTrip != nil {
      cell.setupData(currentTrip!.tripSegments.first!, isOrigin: true)
    }
    return cell
  }
  
  /**
   * Load stop data
   */
  private func loadStops() {
    
    for segment in currentTrip!.tripSegments {
      segment.routeLineLocations = [CLLocation]()
      self.stopsLoadCount += 1
      if let ref = segment.journyRef {
        NetworkActivity.displayActivityIndicator(true)
        JournyDetailsService.fetchJournyDetails(ref) { stops, error in
          NetworkActivity.displayActivityIndicator(false)
          segment.stops = JournyDetailsService.filterStops(stops, segment: segment)
          if self.stopsLoadCount == self.currentTrip!.tripSegments.count {
            dispatch_async(dispatch_get_main_queue()) {
              self.isStopsLoaded = true
              self.collectionView?.reloadData()
            }
          }
        }
      }
    }
  }
  
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
}
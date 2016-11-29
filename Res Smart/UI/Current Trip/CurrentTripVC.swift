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
  @IBAction func closeCurrentTrip(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: UICollectionViewController
  
  /**
   * Create cells for each data post.
   */
  override func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
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
  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return 2
  }
  
  /**
   * Size for items.
   */
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let screenSize = UIScreen.main.bounds.size
    if indexPath.row == 0 {
      return CGSize(width: screenSize.width - 20, height: 150)
    } else if indexPath.row == 1 {
      return CGSize(width: screenSize.width - 20, height: 120)
    }
    return CGSize(width: 0,height: 0)
  }
  
  // MARK: Private
  
  /**
   * Create trip cell
   */
  fileprivate func createRoutineTripCell(_ indexPath: IndexPath) -> CurrentTripCell {
    let cell = collectionView!.dequeueReusableCell(
      withReuseIdentifier: "CurrentTripCell", for: indexPath) as! CurrentTripCell
    if let trip = currentTrip {
      cell.setupData(trip)
    }
    return cell
  }
  
  /**
   * Create change cell
   */
  fileprivate func createChangeCell(_ indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView!.dequeueReusableCell(
      withReuseIdentifier: "ChangeCell", for: indexPath) as! ChangeCell
    if isStopsLoaded && currentTrip != nil {
      //cell.setupData(currentTrip!.tripSegments[2], isOrigin: false)
    }
    return cell
  }
  
  /**
   * Load stop data
   */
  fileprivate func loadStops() {
    /*
    for segment in currentTrip!.tripSegments {
      if let ref = segment.journyRef {
        NetworkActivity.displayActivityIndicator(true)
        JournyDetailsService.fetchJournyDetails(ref) { stops, error in
          NetworkActivity.displayActivityIndicator(false)
          self.stopsLoadCount += 1
          segment.stops = JournyDetailsService.filterStops(stops, segment: segment)
          if self.stopsLoadCount == self.coundNonWalkSegments(self.currentTrip!.tripSegments) {
            dispatch_async(dispatch_get_main_queue()) {
              self.isStopsLoaded = true
              self.collectionView?.reloadData()
            }
          }
        }
      }
    }
     */
  }
  
  /**
   * Counts segments that are not walk segments. 
   */
  fileprivate func coundNonWalkSegments(_ segments: [TripSegment]) -> Int {
    return segments.filter{ $0.type != .Walk }.count
  }
  
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
    
    let wrapper = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let imageView = UIImageView(
      image: UIImage(named: "TrainSplash")?.withRenderingMode(.alwaysTemplate))
    imageView.tintColor = UIColor.white
    imageView.frame.size = CGSize(width: 30, height: 30)
    imageView.frame.origin.y = 5
    imageView.frame.origin.x = 6
    
    wrapper.addSubview(imageView)
    self.navigationItem.titleView = wrapper
  }
}

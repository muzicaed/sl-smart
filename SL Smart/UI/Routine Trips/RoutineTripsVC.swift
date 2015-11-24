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
  var bestTrip: RoutineTrip?
  var otherTrips = [RoutineTrip]()
  
  /**
   * View is done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
    loadTripData()
  }
  
  /**
   * View is about to display.
   */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    collectionView?.reloadData()
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
        let bestCount = (bestTrip == nil ? 0 : 1)
        return bestCount
      }
      
      return min(otherTrips.count, 4)
  }
  
  /**
   * Create cells for each data post.
   */
  override func collectionView(collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      
      if indexPath.section == 0 {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier,
          forIndexPath: indexPath) as! RoutineTripCell
        cell.setupData(bestTrip!)
        return cell
      }
      
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(simpleCellIdentifier,
        forIndexPath: indexPath) as! RoutineTripCell
      cell.setupData(otherTrips[indexPath.row])
      
      return cell
  }
  
  /**
   * View for supplementary (header/footer)
   */
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    
    let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(
      UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath) as! RoutineTripHeader
    
    if indexPath.section == 0 {
      reusableView.titleLabel.text = "Trolig resa"
      return reusableView
    }
    
    reusableView.titleLabel.text = "Andra resor härifrån"
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
        return CGSizeMake(screenSize.width - 20, 125)
      }
      
      return CGSizeMake(screenSize.width - 20, 90)
  }
  
  // MARK: Private methods
  
  /**
  * Setup collection view properties and layout.
  */
  private func setupCollectionView() {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
    flowLayout.headerReferenceSize = CGSizeMake(self.collectionView!.frame.size.width, 50)
    
    
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
    bestTrip = RoutineService.sharedInstance.findBestRoutineTrip()
    otherTrips = RoutineService.sharedInstance.getOtherTrips()
    print(bestTrip)
    print(otherTrips)
  }
}
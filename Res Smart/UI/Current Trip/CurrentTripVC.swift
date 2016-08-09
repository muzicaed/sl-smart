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

class CurrentTripVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  var currentTrip: Trip?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
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
    
    return createRoutineTripCell(indexPath)
  }
  
  /**
   * Item count for section
   */
  override func collectionView(collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return 1
  }
  
  /**
   * Size for items.
   */
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let screenSize = UIScreen.mainScreen().bounds.size
    return CGSizeMake(screenSize.width - 20, 150)
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
//
//  SubscribeVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-31.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class SubscribeVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  var isProductsLoaded = false
  var isBuying = false
  var products = [SKProduct]()
  
  
  /**
   * View is done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
    SubscriptionManager.sharedInstance.requestProducts({ products in
      self.products = products
      self.isProductsLoaded = true
      self.collectionView?.reloadData()
    })
  }
  
  /**
   * User taps "No, thank you"
   */
  @IBAction func onNoTap(sender: UIBarButtonItem) {
    parentViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  /**
   * User tap buy monthly subscription.
   */
  @IBAction func onBuyMonthTap(sender: UIButton) {
    if !isBuying {
      sender.enabled = false
      isBuying = true
      SubscriptionManager.sharedInstance.executePayment(products[0], callback: {
        print("Month bought callback")
      })
    }
  }
  
  /**
   * User tap buy half year subscription.
   */
  @IBAction func onBuyHalfYearTap(sender: UIButton) {
    if !isBuying {
      sender.enabled = false
      isBuying = true
      SubscriptionManager.sharedInstance.executePayment(products[1], callback: {
        print("Half year bought callback")
      })
    }
  }
  
  // MARK: UICollectionViewController
  
  /**
  * Item count for section
  */
  override func collectionView(collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
      
      return (isProductsLoaded) ? 3 : 1
  }
  
  /**
   * Create cells for each data post.
   */
  override func collectionView(collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      
      if !isProductsLoaded {
        return collectionView.dequeueReusableCellWithReuseIdentifier("LoadingRow",
          forIndexPath: indexPath)
      }
      
      if indexPath.row == 0 {
        return collectionView.dequeueReusableCellWithReuseIdentifier("InfoRow",
          forIndexPath: indexPath)
      } else if indexPath.row == 1 {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SubscriptionMonthRow",
          forIndexPath: indexPath) as! SubscriptionCell
        cell.setData(products[0])
        return cell
      } else if indexPath.row == 2 {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SubscriptionHalfYearRow",
          forIndexPath: indexPath) as! SubscriptionCell
        cell.setData(products[1])
        return cell
      }
      fatalError("Could not create row")
  }
  
  /**
   * Size for items.
   */
  func collectionView(collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      
      let screenSize = UIScreen.mainScreen().bounds.size
      
      if !isProductsLoaded {
        return CGSizeMake(screenSize.width - 20, screenSize.height - 44)
      }
      
      if indexPath.row == 0 {
        return CGSizeMake(screenSize.width - 20, 70)
      } else if indexPath.row == 1 {
        return CGSizeMake(screenSize.width - 20, 235)
      } else if indexPath.row == 2 {
        return CGSizeMake(screenSize.width - 20, 235)
      }
      
      return CGSize.zero
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
    
    collectionView?.backgroundColor = StyleHelper.sharedInstance.background
  }
}
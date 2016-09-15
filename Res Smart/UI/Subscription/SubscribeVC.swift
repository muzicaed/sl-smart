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

class SubscribeVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, SubscribeDelegate {
  
  var isProductsLoaded = false
  var isBuying = false
  var products = [SKProduct]()
  
  @IBOutlet weak var noThanksButton: UIBarButtonItem!
  
  /**
   * View is done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
    SubscriptionManager.sharedInstance.delegate = self
    SubscriptionManager.sharedInstance.requestProducts()
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
      noThanksButton.enabled = false
      isBuying = true
      self.collectionView?.reloadData()
      SubscriptionManager.sharedInstance.executePayment(products[0])
    }
  }
  
  /**
   * User tap buy half year subscription.
   */
  @IBAction func onBuyHalfYearTap(sender: UIButton) {
    if !isBuying {
      sender.enabled = false
      noThanksButton.enabled = false
      isBuying = true
      self.collectionView?.reloadData()
      SubscriptionManager.sharedInstance.executePayment(products[1])
    }
  }
  
  // MARK: SubscribeDelegate
  
  /**
  * On successful subscription
  */
  func subscriptionSuccessful() {
    dispatch_async(dispatch_get_main_queue()) {
      self.showThanks()
    }
  }
  /**
   * Received product list
   */
  func recievedProducts(products: [SKProduct]) {
    dispatch_async(dispatch_get_main_queue()) {
      self.products = products
      self.isProductsLoaded = true
      self.collectionView?.reloadData()
    }
  }
  
  /**
   * On faild subscription
   */
  func subscriptionError(error: SubscriptionError) {
    dispatch_async(dispatch_get_main_queue()) {
      switch error {
      case .CanNotMakePayments:
        self.showCanNotMakePayments()
        break
      case .NoProductsFound:
        self.showNoProductsFound()
        break
      case .PaymentError:
        self.showPaymentError()
        break
      }
    }
  }
  
  // MARK: UICollectionViewController
  
  /**
  * Item count for section
  */
  override func collectionView(collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
      return (isProductsLoaded && !isBuying) ? 3 : 1
  }
  
  /**
   * Create cells for each data post.
   */
  override func collectionView(collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      
      if !isProductsLoaded || isBuying {
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
        return CGSizeMake(screenSize.width - 20, collectionView.bounds.height - 49 - 64 - 20)
      }
      
      if indexPath.row == 0 {
        return CGSizeMake(screenSize.width - 20, 75)
      }
      return CGSizeMake(screenSize.width - 20, 150)
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
  
  /**
   * Show a thanks alert
   */
  private func showThanks() {
    let invalidAlert = UIAlertController(
      title: "Tack!",
      message: "Prenumerationen är nu påbörjad och alla funktioner är upplåsta. Tack för att du väljer att prenumera.",
      preferredStyle: UIAlertControllerStyle.Alert)
    invalidAlert.addAction(
      UIAlertAction(title: "Varsågod!", style: UIAlertActionStyle.Default, handler: { _ in
        self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
      }))
    
    presentViewController(invalidAlert, animated: true, completion: nil)
  }
  
  /**
   * Show a no products found alert
   */
  private func showNoProductsFound() {
    let invalidAlert = UIAlertController(
      title: "Inga prenummerationer",
      message: "Det finns inga prenumerationer tillgängliga nu. Försök igen lite senare.",
      preferredStyle: UIAlertControllerStyle.Alert)
    invalidAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.Default, handler: { _ in
        self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
      }))
    
    presentViewController(invalidAlert, animated: true, completion: nil)
  }
  
  /**
   * Show a device cannot make payments alert
   */
  private func showCanNotMakePayments() {
    let invalidAlert = UIAlertController(
      title: "Eheten kan inte betala",
      message: "Denna enheten är inställd att inte tillåta betalningar. Kontrollera dina betalningsuppgifter, och oönskad föräldrakontroll. Är du ett barn måste du fråga dina föräldrar om lov.",
      preferredStyle: UIAlertControllerStyle.Alert)
    invalidAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.Default, handler: { _ in
        self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
      }))
    
    presentViewController(invalidAlert, animated: true, completion: nil)
  }
  
  /**
   * Show a payment faild alert
   */
  private func showPaymentError() {
    let invalidAlert = UIAlertController(
      title: "Betalningen misslyckades",
      message: "Ingen betalning har utförts. Kontrollera kortuppgifterna som är kopplad till ditt iTunes/App Store konto. Kontrollera även att dina bankinställningar tillåter internet betalningar.",
      preferredStyle: UIAlertControllerStyle.Alert)
    invalidAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.Default, handler: { _ in
        self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
      }))
    
    presentViewController(invalidAlert, animated: true, completion: nil)
  }
}
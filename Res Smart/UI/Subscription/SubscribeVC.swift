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
  @IBAction func onNoTap(_ sender: UIBarButtonItem) {
    parent?.dismiss(animated: true, completion: nil)
  }
  
  /**
   * User tap buy monthly subscription.
   */
  @IBAction func onBuyMonthTap(_ sender: UIButton) {
    sender.isEnabled = false
    buyProduct(0)
  }
  
  /**
   * User tap buy half year subscription.
   */
  @IBAction func onBuyHalfYearTap(_ sender: UIButton) {
    sender.isEnabled = false
    buyProduct(1)
  }
  
  @IBAction func onBuyYearTap(_ sender: UIButton) {
    sender.isEnabled = false
    buyProduct(2)
  }
  
  // MARK: SubscribeDelegate
  
  /**
   * On successful subscription
   */
  func subscriptionSuccessful() {
    DispatchQueue.main.async {
      self.showThanks()
    }
  }
  /**
   * Received product list
   */
  func recievedProducts(_ products: [SKProduct]) {
    DispatchQueue.main.async {
      self.products = products
      self.isProductsLoaded = true
      self.collectionView?.reloadData()
    }
  }
  
  /**
   * On faild subscription
   */
  func subscriptionError(_ error: SubscriptionError) {
    DispatchQueue.main.async {
      switch error {
      case .canNotMakePayments:
        self.showCanNotMakePayments()
        break
      case .noProductsFound:
        self.showNoProductsFound()
        break
      case .paymentError:
        self.showPaymentError()
        break
      }
    }
  }
  
  // MARK: UICollectionViewController
  
  /**
   * Item count for section
   */
  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return (isProductsLoaded && !isBuying) ? 4 : 1
  }
  
  /**
   * Create cells for each data post.
   */
  override func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if !isProductsLoaded || isBuying {
      return collectionView.dequeueReusableCell(
        withReuseIdentifier: "LoadingRow", for: indexPath)
    }
    
    if indexPath.row == 0 {
      return collectionView.dequeueReusableCell(
        withReuseIdentifier: "InfoRow", for: indexPath)
      
    } else if indexPath.row == 1 {
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: "SubscriptionYearRow", for: indexPath) as! SubscriptionCell
      cell.setData(products[0])
      return cell
     
    } else if indexPath.row == 2 {
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: "SubscriptionMonthRow", for: indexPath) as! SubscriptionCell
      cell.setData(products[1])
      return cell

    } else if indexPath.row == 3 {
      let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: "SubscriptionHalfYearRow", for: indexPath) as! SubscriptionCell
      cell.setData(products[2])
      return cell
    }
    
    fatalError("Could not create row")
  }
  
  /**
   * Size for items.
   */
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let screenSize = UIScreen.main.bounds.size
    
    if !isProductsLoaded {
      return CGSize(width: screenSize.width - 20, height: collectionView.bounds.height - 49 - 64 - 20)
    }
    
    if indexPath.row == 0 {
      return CGSize(width: screenSize.width - 20, height: 75)
    }
    return CGSize(width: screenSize.width - 20, height: 150)
  }
  
  // MARK: Private methods
  
  /**
   * Purchase a specific product item.
   */
  fileprivate func buyProduct(_ productIndex: Int) {
    if !isBuying {
      noThanksButton.isEnabled = false
      isBuying = true
      self.collectionView?.reloadData()
      SubscriptionManager.sharedInstance.executePayment(products[1])
    }
  }
  
  /**
   * Setup collection view properties and layout.
   */
  fileprivate func setupCollectionView() {
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
  fileprivate func showThanks() {
    let invalidAlert = UIAlertController(
      title: "Tack!",
      message: "Prenumerationen är nu påbörjad och alla funktioner är upplåsta. Tack för att du väljer att prenumera.",
      preferredStyle: UIAlertControllerStyle.alert)
    invalidAlert.addAction(
      UIAlertAction(title: "Varsågod!", style: UIAlertActionStyle.default, handler: { _ in
        self.parent?.dismiss(animated: true, completion: nil)
      }))
    
    present(invalidAlert, animated: true, completion: nil)
  }
  
  /**
   * Show a no products found alert
   */
  fileprivate func showNoProductsFound() {
    let invalidAlert = UIAlertController(
      title: "Inga prenummerationer",
      message: "Det finns inga prenumerationer tillgängliga nu. Försök igen lite senare.",
      preferredStyle: UIAlertControllerStyle.alert)
    invalidAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.default, handler: { _ in
        self.parent?.dismiss(animated: true, completion: nil)
      }))
    
    present(invalidAlert, animated: true, completion: nil)
  }
  
  /**
   * Show a device cannot make payments alert
   */
  fileprivate func showCanNotMakePayments() {
    let invalidAlert = UIAlertController(
      title: "Eheten kan inte betala",
      message: "Denna enheten är inställd att inte tillåta betalningar. Kontrollera dina betalningsuppgifter, och oönskad föräldrakontroll. Är du ett barn måste du fråga dina föräldrar om lov.",
      preferredStyle: UIAlertControllerStyle.alert)
    invalidAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.default, handler: { _ in
        self.parent?.dismiss(animated: true, completion: nil)
      }))
    
    present(invalidAlert, animated: true, completion: nil)
  }
  
  /**
   * Show a payment faild alert
   */
  fileprivate func showPaymentError() {
    let invalidAlert = UIAlertController(
      title: "Betalningen misslyckades",
      message: "Ingen betalning har utförts. Kontrollera kortuppgifterna som är kopplad till ditt iTunes/App Store konto. Kontrollera även att dina bankinställningar tillåter internet betalningar.",
      preferredStyle: UIAlertControllerStyle.alert)
    invalidAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.default, handler: { _ in
        self.parent?.dismiss(animated: true, completion: nil)
      }))
    
    present(invalidAlert, animated: true, completion: nil)
  }
}

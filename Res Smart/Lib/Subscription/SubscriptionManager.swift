//
//  SubscriptionManager.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2016-01-01.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import StoreKit
import ResStockholmApiKit

class SubscriptionManager: NSObject,
SKPaymentTransactionObserver, SKRequestDelegate {
  
  // Singelton pattern
  static let sharedInstance = SubscriptionManager()
  
  let productIdentifiers = Set(["6_MONTHS_NO_TRIAL", "12_MONTHS_NO_TRIAL", "1_MONTH_NO_TRIAL"])
  var product: SKProduct?
  var products = [SKProduct]()
  var productsRequest: SKProductsRequest
  var delegate: SubscribeDelegate?
  
  /**
   * Standard init
   */
  override init() {
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    super.init()
    //productsRequest.delegate = self
    SKPaymentQueue.default().add(self)
  }
  
  /**
   * Make sure instance exists.
   */
  func touch() {}
  
  /**
   * Validate subscription
   */
  func validateSubscription() {
    print("Will validate sub")
    if shouldCheckForNewReciept() {
      print("Will refresh...")
      let refresh = SKReceiptRefreshRequest()
      refresh.delegate = self
      refresh.start()
      
    }
  }
  
  /**
   * Execute payment request
   */
  func executePayment(_ product: SKProduct) {
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }
  
  /**
   * Restore subscription.
   */
  func restoreSubscription() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
  
  // MARK: SKProductsRequestDelegate
  

  
  // MARK: SKPaymentTransactionObserver
  
  func paymentQueue(
    _ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    
    for transaction:AnyObject in transactions {
      let trans = transaction as! SKPaymentTransaction
      switch trans.transactionState {
      case .purchased:
        handlePurchase(trans) {
          SKPaymentQueue.default().finishTransaction(trans)
        }
        break
      case .failed:
        handleFailedPurchase(trans)
        SKPaymentQueue.default().finishTransaction(trans)
        break
      case .restored:
        if let restored = trans.original {
          switch restored.transactionState {
          case .purchased:
            handlePurchase(restored) {
              SKPaymentQueue.default().finishTransaction(trans) // Note: Should be "trans"!
            }
            break
          case .failed:
            handleFailedPurchase(restored)
            SKPaymentQueue.default().finishTransaction(trans) // Note: Should be "trans"!
            break
          default:
            break
          }
        } else {
          // Wierd this should not happen... but it does...
          SKPaymentQueue.default().finishTransaction(trans) // Note: Should be "trans"!
        }
        break
      default:
        break
      }
    }
  }
  
  // MARK: SKRequestDelegate
  
  func requestDidFinish(_ request: SKRequest) {
    ReceiptManager.validateReceipt { (foundReceipt, date) -> Void in
      if foundReceipt {
        if date.timeIntervalSinceNow < 0 {
          SubscriptionStore.sharedInstance.setSubscriptionHaveExpired()
          return
        }
        SubscriptionStore.sharedInstance.setNewSubscriptionDate(date)
        return
      }
    }
  }
  
  // MARK: Private method
  
  /**
   * Check if it is needed to check for a renewed subscription.
   */
  fileprivate func shouldCheckForNewReciept() -> Bool {
    if let localEndDate = SubscriptionStore.sharedInstance.getLocalExpireDate() {
      return (localEndDate.timeIntervalSinceNow < 0)
    }
    
    return false
  }
  
  /**
   * Handels successfull purchase
   */
  fileprivate func handlePurchase(
    _ transaction: SKPaymentTransaction, doneCallback: @escaping () -> Void) {
    
    ReceiptManager.validateReceipt({ isValid, date in
      if isValid {
        if date.timeIntervalSinceNow > 0 {
          SubscriptionStore.sharedInstance.setNewSubscriptionDate(date)
          self.delegate?.subscriptionSuccessful()
          doneCallback()
          return
        }
        doneCallback()
        return
      }
      SubscriptionStore.sharedInstance.setSubscriptionHaveExpired()
      self.delegate?.subscriptionError(SubscriptionError.paymentError)
      doneCallback()
    })
  }
  
  /**
   * Handels failing purchase
   */
  fileprivate func handleFailedPurchase(_ transaction: SKPaymentTransaction) {
    delegate?.subscriptionError(SubscriptionError.paymentError)
  }
}

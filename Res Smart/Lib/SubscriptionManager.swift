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

class SubscriptionManager: NSObject, SKProductsRequestDelegate,
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
    productsRequest.delegate = self
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
    if shouldCheckForNewReciept() {
      let refresh = SKReceiptRefreshRequest()
      refresh.delegate = self
      refresh.start()
    }
  }
  
  /**
   * Request products from App Store.
   */
  func requestProducts() {
    if (SKPaymentQueue.canMakePayments()) {
      if products.count > 0 {
        delegate?.recievedProducts(products)
        return
      }
      productsRequest.start()
      return
    }
    
    delegate?.subscriptionError(SubscriptionError.canNotMakePayments)
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
  
  /**
   * Response handler for Products request
   */
  func productsRequest(
    _ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    
    if response.products.count != 0 {
      for product in response.products {
        products.append(product)
      }
      delegate?.recievedProducts(products)
    }
    else {
      delegate?.subscriptionError(SubscriptionError.noProductsFound)
    }
  }
  
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
        print("Found receipt date: \(DateUtils.dateAsDateAndTimeString(date))")
        if date.timeIntervalSinceNow < 0 {
          print("Receipt date expired!")
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
      print("Subscription end date: \(DateUtils.dateAsDateAndTimeString(localEndDate))")
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

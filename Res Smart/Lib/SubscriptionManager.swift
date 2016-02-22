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
  
  let productIdentifiers = Set(["1_MONTH_RES_SMART", "6_MONTH_RES_SMART"])
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
    SKPaymentQueue.defaultQueue().addTransactionObserver(self)
  }
  
  /**
   * Make sure instance exists.
   */
  func touch() {}
  
  /**
   * Validate subscription
   */
  func validateSubscription() {
    // TODO: Remove this
    /*
    if shouldCheckForNewReciept() {
      let refresh = SKReceiptRefreshRequest()
      refresh.delegate = self
      refresh.start()
    }
    */
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
    
    delegate?.subscriptionError(SubscriptionError.CanNotMakePayments)
  }
  
  /**
   * Execute payment request
   */
  func executePayment(product: SKProduct) {
    let payment = SKPayment(product: product)
    SKPaymentQueue.defaultQueue().addPayment(payment)
  }
  
  /**
   * Restore subscription.
   */
  func restoreSubscription() {
    SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
  }
  
  // MARK: SKProductsRequestDelegate
  
  /**
  * Response handler for Products request
  */
  func productsRequest(request: SKProductsRequest,
    didReceiveResponse response: SKProductsResponse) {
      if response.products.count != 0 {
        for product in response.products {
          products.append(product)
        }
        delegate?.recievedProducts(products)
      }
      else {
        delegate?.subscriptionError(SubscriptionError.NoProductsFound)
      }
  }
  
  // MARK: SKPaymentTransactionObserver
  
  func paymentQueue(queue: SKPaymentQueue,
    updatedTransactions transactions: [SKPaymentTransaction]) {
      for transaction:AnyObject in transactions {
        let trans = transaction as! SKPaymentTransaction
        switch trans.transactionState {
        case .Purchased:
          handlePurchase(trans) {
            SKPaymentQueue.defaultQueue().finishTransaction(trans)
          }
          break
        case .Failed:
          handleFailedPurchase(trans)
          SKPaymentQueue.defaultQueue().finishTransaction(trans)
          break
        case .Restored:
          if let restored = trans.originalTransaction {
            switch restored.transactionState {
            case .Purchased:
              handlePurchase(restored) {
                SKPaymentQueue.defaultQueue().finishTransaction(trans) // Note: Should be "trans"!
              }
              break
            case .Failed:
              handleFailedPurchase(restored)
              SKPaymentQueue.defaultQueue().finishTransaction(trans) // Note: Should be "trans"!
              break
            default:
              break
            }
          } else {
            // Wierd this should not happen... but it does...
            SKPaymentQueue.defaultQueue().finishTransaction(trans) // Note: Should be "trans"!
          }
          break
        default:
          break
        }
      }
  }
  
  // MARK: SKRequestDelegate
  
  func requestDidFinish(request: SKRequest) {

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
  private func shouldCheckForNewReciept() -> Bool {
    if let localEndDate = SubscriptionStore.sharedInstance.getLocalExpireDate() {
      if localEndDate.timeIntervalSinceNow < 0 {
        return true
      } else {
        return false
      }
    }
    
    return false
  }
  
  /**
   * Handels successfull purchase
   */
  private func handlePurchase(
    transaction: SKPaymentTransaction, doneCallback: () -> Void) {
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
        self.delegate?.subscriptionError(SubscriptionError.PaymentError)
        doneCallback()
      })
  }
  
  /**
   * Handels failing purchase
   */
  private func handleFailedPurchase(transaction: SKPaymentTransaction) {
    delegate?.subscriptionError(SubscriptionError.PaymentError)
  }
}
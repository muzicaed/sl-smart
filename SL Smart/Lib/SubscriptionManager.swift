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
    
    delegate?.subscriptionError(SubscriptionError.CanNotMakePayments)
  }
  
  /**
   * Execute payment request
   */
  func executePayment(product: SKProduct) {
    let payment = SKPayment(product: product)
    payment
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
  func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
    print("Got products")
    if response.products.count != 0 {
      for product in response.products {
        products.append(product)
      }
      delegate?.recievedProducts(products)
    }
    else {
      print("ERROR: There are no products.")
      delegate?.subscriptionError(SubscriptionError.NoProductsFound)
    }
  }
  
  // MARK: SKPaymentTransactionObserver
  
  func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    
    print("Updated Transactions")
    for transaction:AnyObject in transactions {
      let trans = transaction as! SKPaymentTransaction
      switch trans.transactionState {
      case .Purchased:
        print("Purchased")
        handlePurchase(trans) {
          SKPaymentQueue.defaultQueue().finishTransaction(trans)
        }
        break
      case .Failed:
        print("Failed")
        handleFailedPurchase(trans)
        SKPaymentQueue.defaultQueue().finishTransaction(trans)
        break
      case .Restored:
        print("Restored:")
        if let restored = trans.originalTransaction {
          switch restored.transactionState {
          case .Purchased:
            print(" - Purchased")
            handlePurchase(restored) {
              SKPaymentQueue.defaultQueue().finishTransaction(trans) // Note: Should be "trans"!
            }
            break
          case .Failed:
            print(" - Failed")
            handleFailedPurchase(restored)
            SKPaymentQueue.defaultQueue().finishTransaction(trans) // Note: Should be "trans"!
            break
          default:
            break
          }
        } else {
          // Wierd this should not happen... but it does...
          print(" - Wierd!")
          SKPaymentQueue.defaultQueue().finishTransaction(trans) // Note: Should be "trans"!
        }
        break
      default:
        print("Unhandled transaction state: \(trans.transactionState.rawValue)")
        break
      }
    }
  }
  
  // MARK: SKRequestDelegate
  
  func requestDidFinish(request: SKRequest) {
    print("Receipt refresh did finish")
    ReceiptManager.validateReceipt { (foundReceipt, date) -> Void in
      print("SubscriptionManager.isValid()")
      print(" - foundReceipt \(foundReceipt)")
      print(" - date \(DateUtils.dateAsDateAndTimeString(date))")
      
      if foundReceipt {
        print("Time left: \(date.timeIntervalSinceNow)")
        if date.timeIntervalSinceNow < 0 {
          print("LATEST RECEIPT EXPIRED")
          SubscriptionStore.sharedInstance.setSubscriptionHaveExpired()
          return
        }
        print("NEW DATE")
        SubscriptionStore.sharedInstance.setNewSubscriptionDate(date)
        return
      }
      print("Found no receipt. Error?? Do nothing.")
    }
  }
  
  // MARK: Private method
  
  /**
  * Check if it is needed to check for a renewed subscription.
  */
  private func shouldCheckForNewReciept() -> Bool {
    if let localEndDate = SubscriptionStore.sharedInstance.getLocalExpireDate() {
      if localEndDate.timeIntervalSinceNow < 0 {
        print("Local end date passed, check for renewed subscription.")
        return true
      } else {
        print("Local end date is valid, no new check.")
        return false
      }
    }
    
    print("No local end date, no check needed.")
    return false
  }
  
  /**
   * Handels successfull purchase
   */
  private func handlePurchase(
    transaction: SKPaymentTransaction, doneCallback: () -> Void) {
      print("Product Purchased")
      
      ReceiptManager.validateReceipt({ isValid, date in
        if isValid {
          print("Receipt is valid: \(DateUtils.dateAsDateAndTimeString(date))")
          
          if date.timeIntervalSinceNow > 0 {
            SubscriptionStore.sharedInstance.setNewSubscriptionDate(date)
            self.delegate?.subscriptionSuccessful()
            doneCallback()
            return
          }
          doneCallback()
          return
        }
        print("Receipt NOT valid: \(DateUtils.dateAsDateAndTimeString(date))")
        SubscriptionStore.sharedInstance.setSubscriptionHaveExpired()
        self.delegate?.subscriptionError(SubscriptionError.PaymentError)
        doneCallback()
      })
  }
  
  /**
   * Handels failing purchase
   */
  private func handleFailedPurchase(transaction: SKPaymentTransaction) {
    print("Purchased Failed")
    print("\(transaction.error?.localizedDescription)")
    delegate?.subscriptionError(SubscriptionError.PaymentError)
  }
}
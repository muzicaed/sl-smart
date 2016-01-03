//
//  SubscriptionManager.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2016-01-01.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import StoreKit

class SubscriptionManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
  
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
   * Ensure an instace in created
   */
  func touch() {}
  
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
  
  func executePayment(product: SKProduct) {
    let payment = SKPayment(product: product)
    payment
    SKPaymentQueue.defaultQueue().addPayment(payment)
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
      if let trans = transaction as? SKPaymentTransaction {
        switch trans.transactionState {
        case .Purchased:
          print("Purchased")
          handlePurchase(transaction as! SKPaymentTransaction)
          break
        case .Failed:
          print("Failed")
          handleFailedPurchase(transaction as! SKPaymentTransaction)
          break
        case .Restored:
          print("Restored:")
          if let restored = trans.originalTransaction {
            switch restored.transactionState {
            case .Purchased:
              handlePurchase(restored)
              break
            case .Failed:
              handleFailedPurchase(restored)
              break
            default:
              break
            }
          }
          break
        default:
          print("Unhandled transaction state: \(trans.transactionState.rawValue)")
          break
        }
      }
    }
  }
  
  // MARK: Private method
  
  /**
  * Handels successfull purchase
  */
  private func handlePurchase(transaction: SKPaymentTransaction) {
    print("Product Purchased")
    
    ReceiptManager.validateReceipt({ isValid, date in
      if isValid {
        // DATE!!!
        SubscriptionStore.sharedInstance.setSubscribed(true, endDate: date)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        self.delegate?.subscriptionSuccessful()
        return
      }
      SubscriptionStore.sharedInstance.setSubscribed(false, endDate: date)
      SKPaymentQueue.defaultQueue().finishTransaction(transaction)
      self.delegate?.subscriptionError(SubscriptionError.PaymentError)
    })
  }
  
  /**
   * Handels failing purchase
   */
  private func handleFailedPurchase(transaction: SKPaymentTransaction) {
    print("Purchased Failed")
    print("\(transaction.error?.localizedDescription)")
    SubscriptionStore.sharedInstance.setSubscribed(false, endDate: NSDate(timeIntervalSince1970: 0))
    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    delegate?.subscriptionError(SubscriptionError.PaymentError)
  }
}
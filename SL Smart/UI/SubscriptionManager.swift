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
  var callback: (([SKProduct]) -> Void)?
  
  /**
   * Standard init
   */
  override init() {
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    super.init()
    productsRequest.delegate = self
  }
  
  /**
   * Request products from App Store.
   */
  func requestProducts(callback: ([SKProduct]) -> Void) {
    if products.count > 0 {
      callback(products)
      return
    }
    
    self.callback = callback
    productsRequest.start()
  }
  
  func executePayment(product: SKProduct, callback: () -> Void) {
    let payment = SKPayment(product: product)
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
      self.callback?(products)
    }
    else {
      print("ERROR: There are no products.")
    }
  }
  
  // MARK: SKPaymentTransactionObserver
  
  func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

    print("Product Purchased")
    for transaction:AnyObject in transactions {
      if let trans = transaction as? SKPaymentTransaction {
        switch trans.transactionState {
        case .Purchased:
          print("Product Purchased")
          SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
          break;
        case .Failed:
          print("Purchased Failed")
          SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
          break;
          // case .Restored:
          //[self restoreTransaction:transaction];
        default:
          break;
        }
      }
    }
  }
}
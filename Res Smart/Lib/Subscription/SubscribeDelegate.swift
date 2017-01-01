//
//  SubscribeDelegate.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2016-01-03.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import StoreKit

protocol SubscribeDelegate {
  func subscriptionSuccessful()
  func subscriptionError(_ error: SubscriptionError)
}

enum SubscriptionError {
  case paymentError
  case canNotMakePayments
  case noProductsFound
}

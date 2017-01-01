//
//  ResSmartPremiumProducts.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-01-01.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation

public struct PremiumProducts {
  
  public static let productIdentifiers: Set<ProductIdentifier> = Set([
    "6_MONTHS_NO_TRIAL", "12_MONTHS_NO_TRIAL", "1_MONTH_NO_TRIAL"])
  
  public static let store = IAPHelper(productIds: PremiumProducts.productIdentifiers)
}

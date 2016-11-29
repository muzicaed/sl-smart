//
//  SubscriptionCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2016-01-01.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class SubscriptionCell: UICollectionViewCell {
  
  @IBOutlet weak var priceLabel: UILabel!
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  /**
   * Set cell data
   */
  func setData(_ product: SKProduct) {
    if product.productIdentifier == "6_MONTHS_NO_TRIAL" {
      priceLabel.text = "\(product.price) kr / halvår"
      priceLabel.accessibilityLabel = "\(product.price) kronor per halvår"
    } else if product.productIdentifier == "12_MONTHS_NO_TRIAL" {
      priceLabel.text = "\(product.price) kr / år"
      priceLabel.accessibilityLabel = "\(product.price) kronor per år"
    } else if product.productIdentifier == "1_MONTH_NO_TRIAL" {
      priceLabel.text = "\(product.price) kr / månad"
      priceLabel.accessibilityLabel = "\(product.price) kronor per månad"
    }
  }
  
  /**
   * Shared init code.
   */
  func setup() {
    layer.masksToBounds = false
    layer.shadowOffset = CGSize(width: 1, height: 1)
    layer.shadowRadius = 1.5
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.10
    layer.cornerRadius = 4.0
    clipsToBounds = false
  }
}

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
  func setData(product: SKProduct) {
    if product.productIdentifier == "6_MONTHS_NO_TRIAL" {
      priceLabel.text = "\(product.price) kr / halvår"
    } else if product.productIdentifier == "12_MONTHS_NO_TRIAL" {
      priceLabel.text = "\(product.price) kr / år"
    }
  }
  
  /**
   * Shared init code.
   */
  func setup() {
    layer.masksToBounds = false
    layer.shadowOffset = CGSizeMake(1, 1)
    layer.shadowRadius = 1.5
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOpacity = 0.10
    layer.cornerRadius = 4.0
    clipsToBounds = false
  }
}
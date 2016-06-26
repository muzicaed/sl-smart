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
    if product.productIdentifier == "1_MONTH_RES_SMART" {
      priceLabel.text = "\(product.price) " + NSLocalizedString("kr / månad", comment: "")
    } else if product.productIdentifier == "6_MONTH_RES_SMART" {
      priceLabel.text = "\(product.price) " + NSLocalizedString("kr / halvår", comment: "")
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
    layer.shadowOpacity = 0.05
    layer.cornerRadius = 4.0
    clipsToBounds = false
  }
}
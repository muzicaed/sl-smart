//
//  HereToThereCell.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-06.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class HereToThereCell: UICollectionViewCell {
  
  @IBOutlet weak var hereToThereLabel: UILabel!
  @IBOutlet weak var wrapperView: UIView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
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
  
  /**
   * Set the from location text.
   */
  func setFromLocationText(_ location: Location) {
    hereToThereLabel.text = "Från \(location.name)"
    wrapperView.accessibilityLabel = "Ta mig till valfri plats. Från \(location.name)"
  }
}

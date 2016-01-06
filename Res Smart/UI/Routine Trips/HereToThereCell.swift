//
//  HereToThereCell.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-06.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class HereToThereCell: UICollectionViewCell {
  
  @IBOutlet weak var hereToThereLabel: UILabel!
  
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
    layer.shadowOffset = CGSizeMake(1, 1)
    layer.shadowRadius = 2.0
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOpacity = 0.15
    layer.cornerRadius = 4.0
    clipsToBounds = false
  }
}
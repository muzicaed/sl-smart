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
  
  /**
   * Set the from location text.
   */
  func setFromLocationText(_ location: Location) {
    layer.borderWidth = 0.5
    layer.borderColor = UIColor.lightGray.cgColor
    hereToThereLabel.text = "\("From".localized) \(location.name)"
  }
}
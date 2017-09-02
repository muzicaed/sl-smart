//
//  HereToThereCell.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-09-02.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class HereToThereCell: UITableViewCell {
  
  @IBOutlet weak var locationLabel: UILabel!
  
  /**
   * Set the from location text.
   */
  func setFromLocationText(_ location: Location) {
    locationLabel.text = "\("From".localized) \(location.name)"
  }
}

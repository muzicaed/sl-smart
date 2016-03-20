//
//  SituationRow.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-10.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class SituationRow: UITableViewCell {

  @IBOutlet weak var messageLabel: UILabel!
  
  func setupData(situation: Situation) {
    messageLabel.text = situation.message
  }
}
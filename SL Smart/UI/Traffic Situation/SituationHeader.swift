//
//  SituationHeader.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-10.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class SituationHeader: UITableViewCell {

  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var statusIcon: UIImageView!
  @IBOutlet weak var typeIcon: UIImageView!
  
  /**
   * Setup data
   */
  func setupData(group: SituationGroup) {
    title.text = group.name
    statusIcon.image = UIImage(named: group.statusIcon)
    typeIcon.image = UIImage(named: group.type)
  }
  
  
}
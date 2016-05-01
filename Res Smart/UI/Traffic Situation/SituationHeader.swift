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
  
  /**
   * Setup data
   */
  func setupData(group: SituationGroup) {
    title.text = group.name
    userInteractionEnabled = false
    if group.hasPlannedEvent && group.statusIcon == "EventGood" {
      statusIcon.image = UIImage(named: "EventPlanned")
      title.accessibilityLabel = group.name + ". Har plannerade avvikelser."
    } else {
      statusIcon.image = UIImage(named: group.statusIcon)
      if group.statusIcon == "EventGood" {
        title.accessibilityLabel = group.name + ". Allt OK."        
      } else {
        title.accessibilityLabel = group.name + ". Finns pågående störningar."
      }
    }
  }
}
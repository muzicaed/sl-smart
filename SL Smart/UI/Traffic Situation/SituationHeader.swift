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
    setBackgroundColor(group.statusIcon)
  }
  
  // MARK: Private
  
  /**
  * Set background color based on type of situation
  */
  private func setBackgroundColor(status: String) {
    if status == "EventMajor" {
      title.textColor = UIColor(red: 249/255, green: 93/255, blue: 89/255, alpha: 1.0)
    } else if status == "EventMinor" {
      title.textColor = UIColor(red: 235/255, green: 151/255, blue: 89/255, alpha: 1.0)
    }
  }
}
//
//  OtherRoutineTripCell.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-09-02.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class OtherRoutineTripCell: UITableViewCell {
  @IBOutlet weak var routineTitleLabel: UILabel!
  @IBOutlet weak var tripPathLabel: UILabel!
  @IBOutlet weak var topBorderView: UIView!
  
  /**
   * Populate cell data based on passed RoutineTrip
   */
  func setupData(_ routineTrip: RoutineTrip, _ rowCount: Int) {
    routineTitleLabel.text = routineTrip.title
    tripPathLabel.text = routineTrip.criterions.origin!.cleanName + " - " + routineTrip.criterions.dest!.cleanName
    if rowCount == 0 {
      topBorderView.backgroundColor = UIColor.lightGray
    } else {
      topBorderView.backgroundColor = UIColor.clear
    }
  }
}

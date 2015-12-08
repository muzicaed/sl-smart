//
//  TripDetailsHeaderCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class TripDetailsHeaderCell: UITableViewCell, TripCellProtocol {

  @IBOutlet weak var dateTimeLabel: UILabel!
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var miniMap: MKMapView!

  /**
   * Set cell data.
   */
  func setData(indexPath: NSIndexPath, trip: Trip) {
    dateTimeLabel.text = DateUtils.friendlyDate(trip.tripSegments.last!.arrivalDateTime)
    originLabel.text = trip.tripSegments.first!.origin.name
    destinationLabel.text = trip.tripSegments.last!.destination.name
  }
}
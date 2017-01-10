//
//  CurrentTripVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-08-09.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit
import MapKit

class CurrentTripVC: UIViewController, MKMapViewDelegate {

  @IBOutlet weak var mapView: MKMapView!
  var currentTrip: Trip?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  /**
   * Close and terminate current trip.
   */
  @IBAction func closeCurrentTrip(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
}

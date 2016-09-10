//
//  Pins.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-17.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import MapKit

class DestinationPin: MKPointAnnotation {
  
}

class BigPin: MKPointAnnotation {
  var stationIndex = -1
  var imageName: String?
}

class SmallPin: MKPointAnnotation {
  var imageName: String?
}
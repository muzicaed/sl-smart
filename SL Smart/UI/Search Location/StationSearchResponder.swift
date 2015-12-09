//
//  StationSearchResponder.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit

protocol StationSearchResponder {

  func selectedStationFromSearch(station: Station) -> Void
  
}
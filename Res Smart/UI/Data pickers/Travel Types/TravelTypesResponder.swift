//
//  TravelTypesResponder.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-14.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit

protocol TravelTypesResponder {
  
  func selectedTravelType(
    useMetro: Bool, useTrain: Bool, useTram: Bool,
    useBus: Bool, useBoat: Bool) -> Void
}
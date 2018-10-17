//
//  LocationSearchResponder.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit

@objc protocol LocationSearchResponder {
    
    func selectedLocationFromSearch(_ location: Location) -> Void
}

//
//  TripCellProtocol.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

protocol TripCellProtocol {
  
  func setData(indexPath: NSIndexPath, trip: Trip)
}
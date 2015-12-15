//
//  AdvancedCriterionsHelper.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-14.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit

class AdvancedCriterionsHelper {

  /**
   * Creates a human readable string to 
   * describe the advanced search criterias.
   */
  static func createAdvCriterionText(criterions: TripSearchCriterion) -> String {
    var text = ""
    if criterions.isAdvanced {
      if let via = criterions.via {
        text = "Via \(via.name)"
      }
    }
    
    let travelTypesString = createTravelTypeString(criterions)
    if text != "" && travelTypesString != "" {
      text = "\(text). \(travelTypesString)."
    } else {
      text = text + travelTypesString + "."
    }
    return text
  }
  
  /**
   * Creates human readable travel type string
   */
  static private func createTravelTypeString(criterions: TripSearchCriterion) -> String {
    var travelTypesString = ""
    if !criterions.useMetro {
      travelTypesString += "Tunnelbana, "
    }
    if !criterions.useTrain {
      travelTypesString += "Pendeltåg, "
    }
    if !criterions.useTram {
      travelTypesString += "Spårvagn, "
    }
    if !criterions.useBus {
      travelTypesString += "Buss, "
    }
    if !criterions.useFerry {
      travelTypesString += "Båt, "
    }
    
    if travelTypesString != "" {
      travelTypesString = "Ej; " + travelTypesString.substringToIndex(
        travelTypesString.endIndex.predecessor().predecessor())
    }
    return travelTypesString
  }
}
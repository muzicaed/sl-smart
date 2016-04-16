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
        text = "Via \(via.name). "
      }
    }
    
    let travelTypesString = createTravelTypeString(criterions)
    return (text + travelTypesString)
  }
  
  /**
   * Creates human readable travel type string
   */
  static private func createTravelTypeString(criterions: TripSearchCriterion) -> String {
    var travelTypeString = ""
    
    if countNonIncluded(criterions) > 2 {
      travelTypeString = createIncludedTravelTypeString(criterions)
    } else {
      travelTypeString = createNotIncludedTravelTypeString(criterions)
    }
    
    return travelTypeString
  }
  
  /**
   * Counts travel types that are not included.
   */
  static private func countNonIncluded(criterions: TripSearchCriterion) -> Int {
    var count = 0
    if !criterions.useMetro {
      count += 1
    }
    if !criterions.useTrain {
      count += 1
    }
    if !criterions.useTram {
      count += 1
    }
    if !criterions.useBus {
      count += 1
    }
    if !criterions.useFerry {
      count += 1
    }
    return count
  }
  
  /**
   * Creates a human friendly travel string
   * explaining not included travel types.
   */
  static private func createNotIncludedTravelTypeString(
    criterions: TripSearchCriterion) -> String {
      
      var travelTypesString = ""
      if !criterions.useMetro {
        travelTypesString += "tunnelbana, "
      }
      if !criterions.useTrain {
        travelTypesString += "pendeltåg, "
      }
      if !criterions.useTram {
        travelTypesString += "spårvagn, "
      }
      if !criterions.useBus {
        travelTypesString += "buss, "
      }
      if !criterions.useFerry {
        travelTypesString += "båt, "
      }
      
      if travelTypesString != "" {
        travelTypesString = "Ej med " + travelTypesString.substringToIndex(
          travelTypesString.endIndex.predecessor().predecessor()) + "."
      }
      if let lastRange = travelTypesString.rangeOfString(", ",
        options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil) {
          travelTypesString.replaceRange(lastRange, with: " eller ")
      }
      return travelTypesString
  }
  
  /**
   * Creates a human friendly travel string
   * explaining included travel types.
   */
  static private func createIncludedTravelTypeString(
    criterions: TripSearchCriterion) -> String {
      
      var travelTypesString = ""
      if criterions.useMetro {
        travelTypesString += "tunnelbana, "
      }
      if criterions.useTrain {
        travelTypesString += "pendeltåg, "
      }
      if criterions.useTram {
        travelTypesString += "spårvagn, "
      }
      if criterions.useBus {
        travelTypesString += "buss, "
      }
      if criterions.useFerry {
        travelTypesString += "båt, "
      }
      
      if travelTypesString != "" {
        travelTypesString = "Endast med " + travelTypesString.substringToIndex(
          travelTypesString.endIndex.predecessor().predecessor()) + "."
      }
      if let lastRange = travelTypesString.rangeOfString(", ",
        options: NSStringCompareOptions.BackwardsSearch, range: nil, locale: nil) {
          travelTypesString.replaceRange(lastRange, with: " och ")
      }
      return travelTypesString
  }
}
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
  static func createAdvCriterionText(_ criterions: TripSearchCriterion) -> String {
    let isViaString = (criterions.via != nil) ? "\("Via".localized) \(criterions.via!.name). " : ""
    let travelTypesString = createTravelTypeString(criterions)
    let numChangeString = createNoChangeString(criterions)
    let walkDistanceString = createWalkDistanceString(criterions)
    let extraTimeString = createExtraTimeString(criterions)
    let isUnsharpString = (criterions.unsharp) ? "\("Alternativa".localized). " : ""
    let incLinesString = (criterions.lineInc != nil) ? "\("Endast".localized) \(criterions.lineInc!). " : ""
    let excLinesString = (criterions.lineExc != nil) ? "\("Inte".localized) \(criterions.lineExc!). " : ""
    let arrivalTimeString = (criterions.time != nil) ? "\("Framme".localized) \(criterions.time!). " : ""
    
    return (isViaString + arrivalTimeString + travelTypesString + numChangeString +
      walkDistanceString + extraTimeString + isUnsharpString + incLinesString + excLinesString)
  }
  
  /**
   * Creates human readable max number of changes string.
   */
  static fileprivate func createNoChangeString(_ criterions: TripSearchCriterion) -> String {
    var text = ""
    if criterions.numChg > -1 {
      switch criterions.numChg {
      case 0:
        text = "Inga byten. "
      case 1:
        text = "Högst 1 byte. "
      default:
        text = "Högst \(criterions.numChg) byten. "
      }
    }
    return text
  }
  
  /**
   * Creates human readable max walk distance string.
   */
  static fileprivate func createWalkDistanceString(_ criterions: TripSearchCriterion) -> String {
    var text = ""
    if criterions.maxWalkDist != 1000 {
      switch criterions.maxWalkDist {
      case 2000:
        text = "Högst \(criterions.maxWalkDist / 1000) km. "
      default:
        text = "Högst \(criterions.maxWalkDist) m. "
      }
    }
    return text
  }
  
  /**
   * Creates human readable extra time string.
   */
  static fileprivate func createExtraTimeString(_ criterions: TripSearchCriterion) -> String {
    var text = ""
    if criterions.minChgTime > 0 {
      text = "\(criterions.minChgTime) min extra. "
    }
    return text
  }
  
  /**
   * Creates human readable travel type string
   */
  static fileprivate func createTravelTypeString(_ criterions: TripSearchCriterion) -> String {
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
  static fileprivate func countNonIncluded(_ criterions: TripSearchCriterion) -> Int {
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
  static fileprivate func createNotIncludedTravelTypeString(
    _ criterions: TripSearchCriterion) -> String {
    
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
      travelTypesString = "Ej med " + travelTypesString.substring(
        to: travelTypesString.index(before: travelTypesString.characters.index(before: travelTypesString.endIndex))) + ". "
    }
    if let lastRange = travelTypesString.range(of: ", ",
                                                       options: NSString.CompareOptions.backwards, range: nil, locale: nil) {
      travelTypesString.replaceSubrange(lastRange, with: " eller ")
    }
    return travelTypesString
  }
  
  /**
   * Creates a human friendly travel string
   * explaining included travel types.
   */
  static fileprivate func createIncludedTravelTypeString(
    _ criterions: TripSearchCriterion) -> String {
    
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
      travelTypesString = "Endast med " + travelTypesString.substring(
        to: travelTypesString.index(before: travelTypesString.characters.index(before: travelTypesString.endIndex))) + ". "
    }
    if let lastRange = travelTypesString.range(of: ", ",
                                                       options: NSString.CompareOptions.backwards, range: nil, locale: nil) {
      travelTypesString.replaceSubrange(lastRange, with: " och ")
    }
    return travelTypesString
  }
}

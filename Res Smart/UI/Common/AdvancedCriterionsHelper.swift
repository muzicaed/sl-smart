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
    let isUnsharpString = (criterions.unsharp) ? "\("Alternative".localized). " : ""
    let incLinesString = (criterions.lineInc != nil) ? "\("Only".localized) \(criterions.lineInc!). " : ""
    let excLinesString = (criterions.lineExc != nil) ? "\("Not".localized) \(criterions.lineExc!). " : ""
    let arrivalTimeString = (criterions.time != nil) ? "\("Arrive".localized) \(criterions.time!). " : ""
    
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
        text = "No transfers. ".localized
      case 1:
        text = "Max 1 transfer. ".localized
      default:
        text = String(format: "Max %d transfers.".localized, criterions.numChg)
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
        text = String(format: "Max %d km.".localized, criterions.maxWalkDist / 1000)
      default:
        text = String(format: "Max %d m.".localized, criterions.maxWalkDist)
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
      text = String(format: "%d min extra. ".localized, criterions.minChgTime)
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
      travelTypesString += "metro, ".localized
    }
    if !criterions.useTrain {
      travelTypesString += "train, ".localized
    }
    if !criterions.useTram {
      travelTypesString += "tram, ".localized
    }
    if !criterions.useBus {
      travelTypesString += "bus, ".localized
    }
    if !criterions.useFerry {
      travelTypesString += "boat, ".localized
    }
    
    if travelTypesString != "" {
      travelTypesString = "Not with ".localized + travelTypesString.substring(
        to: travelTypesString.index(before: travelTypesString.characters.index(before: travelTypesString.endIndex))) + ". "
    }
    if let lastRange = travelTypesString.range(of: ", ",
                                                       options: NSString.CompareOptions.backwards, range: nil, locale: nil) {
      travelTypesString.replaceSubrange(lastRange, with: " or ".localized)
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
      travelTypesString += "metro, ".localized
    }
    if criterions.useTrain {
      travelTypesString += "train, ".localized
    }
    if criterions.useTram {
      travelTypesString += "metro, ".localized
    }
    if criterions.useBus {
      travelTypesString += "bus, ".localized
    }
    if criterions.useFerry {
      travelTypesString += "boat, ".localized
    }
    
    if travelTypesString != "" {
      travelTypesString = "Only with ".localized + travelTypesString.substring(
        to: travelTypesString.index(before: travelTypesString.characters.index(before: travelTypesString.endIndex))) + ". "
    }
    if let lastRange = travelTypesString.range(of: ", ",
                                                       options: NSString.CompareOptions.backwards, range: nil, locale: nil) {
      travelTypesString.replaceSubrange(lastRange, with: " and ".localized)
    }
    return travelTypesString
  }
}

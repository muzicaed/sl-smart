//
//  Deviation.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-02-22.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

public class Deviation {
  
  public let scope: String
  public let title: String
  public let details: String
  public let reported: NSDate
  public let fromDate: NSDate
  public let tripType: TripType
  
  init(scope: String, title: String, details: String, reportedDate: String, fromDate: String) {
    
    self.scope = Deviation.makeFriendlyScope(scope)
    self.title = title
    self.details = details
    self.reported = Deviation.convertDate(reportedDate)
    self.fromDate = Deviation.convertDate(fromDate)
    self.tripType = Deviation.extractTripType(scope)
  }
  
  /**
   * Converts "2016-02-21T11:49:58.79+01:00" into NSDate object
   */
  private static func convertDate(dateStr: String) -> NSDate {
    let start = dateStr.startIndex.advancedBy(0)
    let end = start.advancedBy(16)
    var croppedStr = dateStr[Range(start: start, end: end)]
    croppedStr = croppedStr.stringByReplacingOccurrencesOfString("T",
      withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
    return DateUtils.convertDateString(croppedStr)
  }
  
  /**
   * Extracts trip type from scope string.
   */
  private static func extractTripType(scope: String) -> TripType {
    if scope.lowercaseString.rangeOfString("pendeltåg") != nil {
      return TripType.Train
    } else if scope.lowercaseString.rangeOfString("buss") != nil {
      return TripType.Bus
    } else if scope.lowercaseString.rangeOfString("närtrafiken") != nil {
      return TripType.Bus
    } else if scope.lowercaseString.rangeOfString("tunnelbana") != nil {
      return TripType.Metro
    } else if scope.lowercaseString.rangeOfString("spårvagn") != nil {
      return TripType.Tram
    } else if scope.lowercaseString.rangeOfString("saltsjöbanan") != nil {
      return TripType.Local
    } else if scope.lowercaseString.rangeOfString("roslagsbanan") != nil {
      return TripType.Local
    }    
    
    return TripType.Bus
  }
  
  /**
   * Fix scope text to match sematics
   */
  private static func makeFriendlyScope(var scope: String) -> String {
    scope = scope.stringByReplacingOccurrencesOfString("Tunnelbanans röda linje", withString: "Röda linjen")
    scope = scope.stringByReplacingOccurrencesOfString("Tunnelbanans gröna linje", withString: "Gröna linjen")    
    scope = scope.stringByReplacingOccurrencesOfString("Tunnelbanans blå linje", withString: "Blå linjen")
    
    return scope
  }
}
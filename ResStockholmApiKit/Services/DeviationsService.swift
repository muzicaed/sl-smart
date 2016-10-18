//
//  DeviationsService.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-02-22.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

class DeviationsService {
  
  private static let api = SLDeviationsApi()
  
  /**
   * Fetch deviations data
   */
  static func fetchInformation(
    callback: (data: [Deviation], error: SLNetworkError?) -> Void) {
      api.fetchInformation { resTuple -> Void in
        var deviations = [Deviation]()
        if let data = resTuple.data {
          if data.length == 0 {
            HttpRequestHelper.clearCache()
            callback(data: deviations, error: SLNetworkError.NoDataFound)
            return
          }
          
          deviations = self.convertJsonResponse(data)
        }
        callback(data: deviations, error: resTuple.error)
      }
  }
  
  /**
   * Converts the raw json string into array of Deviation.
   */
  private static func convertJsonResponse(data: NSData) -> [Deviation] {
    var deviations = [Deviation]()
    let jsonData = JSON(data: data)
    if jsonData["ResponseData"].isExists() {
      if let response = jsonData["ResponseData"].array {
        for deviationJson in response {
          deviations.append(convertDeviationJson(deviationJson))
        }
      }
    }
    
    return deviations
  }
  
  /**
   * Converts the raw json string into a Deviation
   */
  private static func convertDeviationJson(json: JSON) -> Deviation {
    return Deviation(
      scope: json["Scope"].string!,
      title: json["Header"].string!,
      details: json["Details"].string!,
      reportedDate: json["Updated"].string!,
      fromDate: json["FromDateTime"].string!)
  }
}

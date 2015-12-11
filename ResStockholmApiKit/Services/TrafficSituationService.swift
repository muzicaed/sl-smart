//
//  TrafficSituationService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-10.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class TrafficSituationService {
  
  private static let api = SLTrafficSituationServiceApi()
  
  public static func fetchInformation(
    callback: (data: [SituationGroup], error: SLNetworkError?) -> Void) {
      api.fetchInformation { resTuple -> Void in
        var situations = [SituationGroup]()
        if let data = resTuple.data {
          if data.length == 0 {
            callback(data: situations, error: SLNetworkError.NoDataFound)
            return
          }
          situations = self.convertJsonResponse(data)
        }
        callback(data: situations, error: resTuple.error)
      }
  }
  
  /**
   * Converts the raw json string into array of SituationGroup.
   */
  private static func convertJsonResponse(jsonDataString: NSData) -> [SituationGroup] {
    var result = [SituationGroup]()
    let data = JSON(data: jsonDataString)
    if checkErrors(data) {
      return [SituationGroup]()
    }
    
    if let groupsJson = data["ResponseData"]["TrafficTypes"].array {
      for groupJson in groupsJson {
        result.append(convertJsonToGroup(groupJson))
      }
    }
    
    return result
  }
  
  /**
   * Converts the raw json string into a SituationGroup
   */
  private static func convertJsonToGroup(groupJson: JSON) -> SituationGroup {
    return SituationGroup(
      statusIcon: groupJson["StatusIcon"].string!,
      hasPlannedEvent: groupJson["HasPlannedEvent"].bool!,
      name: groupJson["Name"].string!,
      tripType: groupJson["Type"].string!,
      situations: convertJsonToSituations(groupJson["Events"]))
  }
  
  /**
   * Converts the raw json string into array of situations
   */
  private static func convertJsonToSituations(situationsJson: JSON) -> [Situation] {
    var situations = [Situation]()
    
    for situationJson in situationsJson.array! {
      if situationJson["StatusIcon"].string! != "EventGood" {
        situations.append(Situation(
          planned: situationJson["Planned"].bool!,
          trafficLine: situationJson["TrafficLine"].string,
          statusIcon: situationJson["StatusIcon"].string!,
          message: situationJson["Message"].string!))
      }
    }
    
    return situations
  }
  
  /**
   * Checks if service returned error.
   */
  private static func checkErrors(data: JSON) -> Bool {
    if let statusCode = data["StatusCode"].int {
      return (statusCode != 0) ? true : false
    }
    return false
  }
}

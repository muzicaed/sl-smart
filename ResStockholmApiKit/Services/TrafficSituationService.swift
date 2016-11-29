//
//  TrafficSituationService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-10.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

open class TrafficSituationService {
  
  fileprivate static let situationsApi = SLTrafficSituationServiceApi()
  
  /**
   * Fetch trafic situation data
   */
  open static func fetchInformation(
    _ callback: (_ data: [SituationGroup], _ error: SLNetworkError?) -> Void) {
      situationsApi.fetchInformation { resTuple -> Void in
        var situations = [SituationGroup]()
        if let data = resTuple.data {
          if data.count == 0 {
            HttpRequestHelper.clearCache()
            callback(situations, SLNetworkError.noDataFound)
            return
          }
          
          situations = self.convertJsonResponse(data)
          mergeDeviations(situations, callback: callback)
        } else {
          callback(situations, resTuple.error)
        }
        
      }
  }
  
  /**
   * Handle traffic situations and merge with deviations.
   */
  fileprivate static func mergeDeviations(_ situations: [SituationGroup],
    callback: (_ data: [SituationGroup], _ error: SLNetworkError?) -> Void) {

      DeviationsService.fetchInformation { (data, error) -> Void in
        if let err = error {
          callback([SituationGroup](), err)
        }
        
        for group in situations {
          addDeviationsToGroup(group, deviations: data)
        }
        callback(situations, nil)
      }
  }
  
  /**
   * Add deviations to a situation group.
   */
  fileprivate static func addDeviationsToGroup(_ group: SituationGroup, deviations: [Deviation]) {
    for deviation in deviations {
      if group.tripType == deviation.tripType {
        group.deviations.append(deviation)
      }
    }
  }
  
  /**
   * Converts the raw json string into array of SituationGroup.
   */
  fileprivate static func convertJsonResponse(_ jsonDataString: Data) -> [SituationGroup] {
    var result = [SituationGroup]()
    let data = JSON(data: jsonDataString)
    if checkErrors(data) {
      return [SituationGroup]()
    }
    
    if data["ResponseData"].isExists() {
      if let groupsJson = data["ResponseData"]["TrafficTypes"].array {
        for groupJson in groupsJson {
          result.append(convertJsonToGroup(groupJson))
        }
      }
    }
    return result
  }
  
  /**
   * Converts the raw json string into a SituationGroup
   */
  fileprivate static func convertJsonToGroup(_ groupJson: JSON) -> SituationGroup {
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
  fileprivate static func convertJsonToSituations(_ situationsJson: JSON) -> [Situation] {
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
  fileprivate static func checkErrors(_ data: JSON) -> Bool {
    if let statusCode = data["StatusCode"].int {
      return (statusCode != 0) ? true : false
    }
    return false
  }
}

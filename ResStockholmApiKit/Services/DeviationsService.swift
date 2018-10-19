//
//  DeviationsService.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-02-22.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

class DeviationsService {
    
    fileprivate static let api = SLDeviationsApi()
    
    /**
     * Fetch deviations data
     */
    static func fetchInformation(
        _ callback: @escaping ([Deviation], SLNetworkError?) -> Void) {
        api.fetchInformation { resTuple -> Void in
            var deviations = [Deviation]()
            if let data = resTuple.0 {
                if data.count == 0 {
                    HttpRequestHelper.clearCache()
                    callback(deviations, SLNetworkError.noDataFound)
                    return
                }
                
                deviations = self.convertJsonResponse(data)
            }
            callback(deviations, resTuple.1)
        }
    }
    
    /**
     * Converts the raw json string into array of Deviation.
     */
    fileprivate static func convertJsonResponse(_ data: Data) -> [Deviation] {
        var deviations = [Deviation]()
        let jsonData = JSON(data: data)
        if let response = jsonData["ResponseData"].array {
            for deviationJson in response {
                deviations.append(convertDeviationJson(deviationJson))
            }
            
        }
        
        return deviations
    }
    
    /**
     * Converts the raw json string into a Deviation
     */
    fileprivate static func convertDeviationJson(_ json: JSON) -> Deviation {
        return Deviation(
            scope: json["Scope"].string!,
            title: json["Header"].string!,
            details: json["Details"].string!,
            reportedDate: json["Updated"].string!,
            fromDate: json["FromDateTime"].string!)
    }
}

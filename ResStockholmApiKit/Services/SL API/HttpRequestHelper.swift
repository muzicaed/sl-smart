//
//  HttpRequestHelper.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import SwiftHTTP

class HttpRequestHelper {
  
  /**
   * Makes a async get request to passed url.
   * Returns the response data using callback.
   */
  static func makeGetRequest(url: String,
    callback: ((data: NSData?, error: SLNetworkError?)) -> Void) {
      print("GET: \(url)")
      let operationQueue = NSOperationQueue()
      operationQueue.maxConcurrentOperationCount = 4
      
      do {
        let opt = try HTTP.New(url, method: .GET)
        opt.onFinish = { response in
          if response.error != nil {
            callback((nil, SLNetworkError.NetworkError))
          }
          
          // TODO: Remove test code
          let data = "{ \"TripList\":{ \"noNamespaceSchemaLocation\":\"hafasRestTrip.xsd\", \"Trip\":[{ \"dur\":\"4\", \"chg\":\"0\", \"co2\":\"0.00\", \"LegList\":{ \"Leg\":{ \"idx\":\"0\", \"name\":\"Tåg 36\", \"type\":\"TRAIN\", \"dir\":\"Södertälje C\", \"line\":\"36\", \"Origin\":{ \"name\":\"Tullinge\", \"type\":\"ST\", \"id\":\"400105181\", \"lon\":\"17.903824\", \"lat\":\"59.205411\", \"routeIdx\":\"16\", \"time\":\"09:01\", \"date\":\"2016-01-27\" }, \"Destination\":{ \"name\":\"Tumba\", \"type\":\"ST\", \"id\":\"400105191\", \"lon\":\"17.836423\", \"lat\":\"59.199675\", \"routeIdx\":\"17\", \"time\":\"09:05\", \"date\":\"2016-01-27\" }, \"RTUMessages\":{ \"RTUMessage\":{ \"$\":\"Försenad pga tågkö\" } }, \"JourneyDetailRef\":{ \"ref\":\"ref%3D683283%2F234615%2F100404%2F177559%2F74%3Fdate%3D2016-01-27%26station_evaId%3D400105181%26station_type%3Ddep%26lang%3Dsv%26format%3Djson%26\" }, \"GeometryRef\":{ \"ref\":\"ref%3D683283%2F234615%2F100404%2F177559%2F74%26startIdx%3D16%26endIdx%3D17%26lang%3Dsv%26format%3Djson%26\" } } }, \"PriceInfo\":{ \"TariffZones\":{ \"$\":\"B\" }, \"TariffRemark\":{ \"$\":\"2 biljett\" } } },{ \"dur\":\"4\", \"chg\":\"0\", \"co2\":\"0.00\", \"LegList\":{ \"Leg\":{ \"idx\":\"0\", \"name\":\"Tåg 36\", \"type\":\"TRAIN\", \"dir\":\"Södertälje C\", \"line\":\"36\", \"Origin\":{ \"name\":\"Tullinge\", \"type\":\"ST\", \"id\":\"400105181\", \"lon\":\"17.903824\", \"lat\":\"59.205411\", \"routeIdx\":\"18\", \"time\":\"09:08\", \"date\":\"2016-01-27\" }, \"Destination\":{ \"name\":\"Tumba\", \"type\":\"ST\", \"id\":\"400105191\", \"lon\":\"17.836423\", \"lat\":\"59.199675\", \"routeIdx\":\"19\", \"time\":\"09:12\", \"date\":\"2016-01-27\" }, \"JourneyDetailRef\":{ \"ref\":\"ref%3D93351%2F37884%2F874388%2F406077%2F74%3Fdate%3D2016-01-27%26station_evaId%3D400105181%26station_type%3Ddep%26lang%3Dsv%26format%3Djson%26\" }, \"GeometryRef\":{ \"ref\":\"ref%3D93351%2F37884%2F874388%2F406077%2F74%26startIdx%3D18%26endIdx%3D19%26lang%3Dsv%26format%3Djson%26\" } } }, \"PriceInfo\":{ \"TariffZones\":{ \"$\":\"B\" }, \"TariffRemark\":{ \"$\":\"2 biljett\" } } },{ \"dur\":\"4\", \"chg\":\"0\", \"co2\":\"0.00\", \"LegList\":{ \"Leg\":{ \"idx\":\"0\", \"name\":\"Tåg 36\", \"type\":\"TRAIN\", \"dir\":\"Södertälje C\", \"line\":\"36\", \"Origin\":{ \"name\":\"Tullinge\", \"type\":\"ST\", \"id\":\"400105181\", \"lon\":\"17.903824\", \"lat\":\"59.205411\", \"routeIdx\":\"18\", \"time\":\"09:23\", \"date\":\"2016-01-27\" }, \"Destination\":{ \"name\":\"Tumba\", \"type\":\"ST\", \"id\":\"400105191\", \"lon\":\"17.836423\", \"lat\":\"59.199675\", \"routeIdx\":\"19\", \"time\":\"09:27\", \"date\":\"2016-01-27\" }, \"JourneyDetailRef\":{ \"ref\":\"ref%3D525405%2F181976%2F598386%2F124064%2F74%3Fdate%3D2016-01-27%26station_evaId%3D400105181%26station_type%3Ddep%26lang%3Dsv%26format%3Djson%26\" }, \"GeometryRef\":{ \"ref\":\"ref%3D525405%2F181976%2F598386%2F124064%2F74%26startIdx%3D18%26endIdx%3D19%26lang%3Dsv%26format%3Djson%26\" } } }, \"PriceInfo\":{ \"TariffZones\":{ \"$\":\"B\" }, \"TariffRemark\":{ \"$\":\"2 biljett\" } } },{ \"dur\":\"4\", \"chg\":\"0\", \"co2\":\"0.00\", \"LegList\":{ \"Leg\":{ \"idx\":\"0\", \"name\":\"Tåg 36\", \"type\":\"TRAIN\", \"dir\":\"Södertälje C\", \"line\":\"36\", \"Origin\":{ \"name\":\"Tullinge\", \"type\":\"ST\", \"id\":\"400105181\", \"lon\":\"17.903824\", \"lat\":\"59.205411\", \"routeIdx\":\"18\", \"time\":\"09:38\", \"date\":\"2016-01-27\" }, \"Destination\":{ \"name\":\"Tumba\", \"type\":\"ST\", \"id\":\"400105191\", \"lon\":\"17.836423\", \"lat\":\"59.199675\", \"routeIdx\":\"19\", \"time\":\"09:42\", \"date\":\"2016-01-27\" }, \"JourneyDetailRef\":{ \"ref\":\"ref%3D681870%2F234054%2F425166%2F14707%2F74%3Fdate%3D2016-01-27%26station_evaId%3D400105181%26station_type%3Ddep%26lang%3Dsv%26format%3Djson%26\" }, \"GeometryRef\":{ \"ref\":\"ref%3D681870%2F234054%2F425166%2F14707%2F74%26startIdx%3D18%26endIdx%3D19%26lang%3Dsv%26format%3Djson%26\" } } }, \"PriceInfo\":{ \"TariffZones\":{ \"$\":\"B\" }, \"TariffRemark\":{ \"$\":\"2 biljett\" } } },{ \"dur\":\"4\", \"chg\":\"0\", \"co2\":\"0.00\", \"LegList\":{ \"Leg\":{ \"idx\":\"0\", \"name\":\"Tåg 36\", \"type\":\"TRAIN\", \"dir\":\"Södertälje C\", \"line\":\"36\", \"Origin\":{ \"name\":\"Tullinge\", \"type\":\"ST\", \"id\":\"400105181\", \"lon\":\"17.903824\", \"lat\":\"59.205411\", \"routeIdx\":\"18\", \"time\":\"09:53\", \"date\":\"2016-01-27\" }, \"Destination\":{ \"name\":\"Tumba\", \"type\":\"ST\", \"id\":\"400105191\", \"lon\":\"17.836423\", \"lat\":\"59.199675\", \"routeIdx\":\"19\", \"time\":\"09:57\", \"date\":\"2016-01-27\" }, \"JourneyDetailRef\":{ \"ref\":\"ref%3D343332%2F121283%2F786818%2F278965%2F74%3Fdate%3D2016-01-27%26station_evaId%3D400105181%26station_type%3Ddep%26lang%3Dsv%26format%3Djson%26\" }, \"GeometryRef\":{ \"ref\":\"ref%3D343332%2F121283%2F786818%2F278965%2F74%26startIdx%3D18%26endIdx%3D19%26lang%3Dsv%26format%3Djson%26\" } } }, \"PriceInfo\":{ \"TariffZones\":{ \"$\":\"B\" }, \"TariffRemark\":{ \"$\":\"2 biljett\" } } }] } }".dataUsingEncoding(NSUTF8StringEncoding)
          
          callback((data, nil))
          //callback((response.data, nil))
        }
        operationQueue.addOperation(opt)
      } catch _ {
        callback((nil, SLNetworkError.InvalidRequest))
      }
  }
}
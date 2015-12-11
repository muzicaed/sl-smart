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
  
  public static func fetchInformation() {
    api.fetchInformation { (data, error) -> Void in
      print("\(error)")
      print("\(error)")
      if let data = data {
        let json = JSON(data: data)
        print(json)
      }
    }
    
  }
}

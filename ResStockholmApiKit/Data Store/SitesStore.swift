//
//  SitesStore.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-06.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

public class SitesStore {
  
  private var cachedSites = [String: StaticSite]()
  
  // Singelton pattern
  public static let sharedInstance = SitesStore()
  
  /**
   * Gets all static sites.
   */
  public func getSites() -> [String: StaticSite] {
    if cachedSites.count == 0 {
      cachedSites = readJson()
    }
    
    return cachedSites
  }
  
  // MARK: Private
  
  /**
   * Reads static site data from json file.
   */
  private func readJson() -> [String: StaticSite] {
    let bundle = NSBundle.mainBundle()
    do {
      if let path = bundle.pathForResource("site", ofType: "json") {
        let data = try NSData(contentsOfFile: path,options: .DataReadingMappedIfSafe)
        return convertData(data)
      } else {
        print("Path not found for static sites.")
      }
    }
    catch {
      fatalError("Could not load site.json")
    }
    

    return [String: StaticSite]()
  }
  
  /**
   * Converts json data to dictionary.
   */
  private func convertData(data: NSData) -> [String: StaticSite] {
    var results = [String: StaticSite]()
    let jsonData = JSON(data: data)
    if jsonData["ResponseData"].isExists() {
      if let sitesJson = jsonData["ResponseData"]["Result"].array {
        for site in sitesJson {
          results[site["SiteId"].string!] = StaticSite(
            siteId: site["SiteId"].string!,
            siteName: site["SiteName"].string!,
            stopAreaNumber: site["StopAreaNumber"].string!)
        }
      }
    }
    
    return results
  }
}
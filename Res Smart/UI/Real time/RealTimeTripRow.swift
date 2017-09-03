//
//  RealTimeTripRow.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class RealTimeTripRow: UITableViewCell {
  
  @IBOutlet weak var lineLabel: UILabel!
  @IBOutlet weak var infoLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var deviationsLabel: UILabel!
  @IBOutlet weak var stopPointDesignation: UILabel!
  
  
  /**
   * Set data for this cell
   * TODO: Refactoring, function break out
   */
  func setData(realTimeDepartures: RealTimeDepartures, indexPath: IndexPath,
               tabTypesKeys: [String], busKeys: [String],
               metroKeys: [String], trainKeys: [String],
               tramKeys: [String], localTramKeys: [String],
               boatKeys: [String], segmentView: SMSegmentView) {
    
    let index = indexPath.section - 1
    var data: RTTransport?
    let tabKeys = tabTypesKeys[segmentView.indexOfSelectedSegment]
    stopPointDesignation.text = ""
    switch tabKeys {
    case "BUS":
      data = realTimeDepartures.busses[busKeys[index]]![indexPath.row - 1]
      lineLabel.text = "Bus".localized + " " + data!.lineNumber
      if data!.stopPointDesignation != "" {
        stopPointDesignation.text = "Läge \(data!.stopPointDesignation)"
      }
      
    case "METRO":
      data = realTimeDepartures.metros[metroKeys[index]]![indexPath.row - 1]
      lineLabel.text = "Line".localized + " " + data!.lineNumber
      stopPointDesignation.text = "Spår \(data!.stopPointDesignation)"
      
    case "TRAIN":
      let train = realTimeDepartures.trains[trainKeys[index]]![indexPath.row - 1]
      stopPointDesignation.text = "Spår \(train.stopPointDesignation)"
      lineLabel.text = "Line".localized + " " + data!.lineNumber
      let via = ((train.secondaryDestinationName != nil) ? " via \(train.secondaryDestinationName!)" : "")      
      infoLabel.text = "Toward".localized + " " + train.destination + via
      if train.displayTime == "Nu" {
        departureTimeLabel.font = UIFont.systemFont(ofSize: 18)
        departureTimeLabel.textColor = StyleHelper.sharedInstance.mainGreen
        departureTimeLabel.text = "Now".localized
      } else {
        departureTimeLabel.font = UIFont.systemFont(ofSize: 18)
        departureTimeLabel.textColor = UIColor.black
        departureTimeLabel.text = train.displayTime
      }
      deviationsLabel.text = train.deviations.joined(separator: " ")
      if DisturbanceTextHelper.isDisturbance(deviationsLabel.text) {
        deviationsLabel.textColor = StyleHelper.sharedInstance.warningColor
      } else {
        deviationsLabel.textColor = UIColor.darkGray
      }
      return
      
    case "TRAM":
      data = realTimeDepartures.trams[tramKeys[index]]![indexPath.row - 1] as RTTransport
      stopPointDesignation.text = "Spår \(data!.stopPointDesignation)"
      lineLabel.text = "Line".localized + " " + data!.lineNumber
      
    case "LOCAL-TRAM":
      data = realTimeDepartures.localTrams[localTramKeys[index]]![indexPath.row - 1] as RTTransport
      stopPointDesignation.text = "Spår \(data!.stopPointDesignation)"
      lineLabel.text = "Line".localized + " " + data!.lineNumber
      
    case "SHIP":
      data = realTimeDepartures.boats[boatKeys[index]]![indexPath.row - 1] as RTTransport
      stopPointDesignation.text = data!.stopPointDesignation
      stopPointDesignation.text = "Läge \(data!.stopPointDesignation)"
      lineLabel.text = "Line".localized + " " + data!.lineNumber
      
    default:
      break
    }
    
    updateFields(data: data)
  }
  
  /**
   * Populates all fields
   */
  fileprivate func updateFields(data: RTTransport?) {
    if let data = data {
      infoLabel.text = "Toward".localized + " " + data.destination
      if data.displayTime == "Nu" {
        departureTimeLabel.font = UIFont.boldSystemFont(ofSize: 18)
        departureTimeLabel.textColor = StyleHelper.sharedInstance.mainGreen
        departureTimeLabel.text = "Now".localized
      } else {
        departureTimeLabel.font = UIFont.systemFont(ofSize: 18)
        departureTimeLabel.textColor = UIColor.black
        departureTimeLabel.text = data.displayTime
      }
      departureTimeLabel.text = data.displayTime
      deviationsLabel.text = data.deviations.joined(separator: " ")
      if DisturbanceTextHelper.isDisturbance(deviationsLabel.text) {
        deviationsLabel.textColor = StyleHelper.sharedInstance.warningColor
      } else {
        deviationsLabel.textColor = UIColor.darkGray
      }
    }
  }
}

//
//  RealTimeHeaderRow.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit
import UIKit

class RealTimeHeaderRow: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    /**
     * Set data for this cell
     */
    func setData(realTimeDepartures: RealTimeDepartures, indexPath: IndexPath, tabTypesKeys: [String],
                 busKeys: [String], metroKeys: [String], trainKeys: [String],
                 tramKeys: [String], localTramKeys: [String], boatKeys: [String],
                 segmentView: SMSegmentView) {
        
        let index = indexPath.section - 1
        let tabKeys = tabTypesKeys[segmentView.indexOfSelectedSegment]
        switch tabKeys {
        case "BUS":
            let bus = realTimeDepartures.busses[busKeys[index]]!.first!
            titleLabel.text = bus.stopAreaName
        case "METRO":
            let metro = realTimeDepartures.metros[metroKeys[index]]!.first!
            titleLabel.text = metro.groupOfLine!.uppercaseFirst.localized
        case "TRAIN":
            let train = realTimeDepartures.trains[trainKeys[index]]!.first!
            if train.journeyDirection == 1 {
                titleLabel.text = "Trains, south".localized
            } else if train.journeyDirection == 2 {
                titleLabel.text = "Trains, north".localized
            }
        case "TRAM":
            let tram = realTimeDepartures.trams[tramKeys[index]]!.first!
            titleLabel.text = tram.groupOfLine
        case "LOCAL-TRAM":
            let tram = realTimeDepartures.localTrams[localTramKeys[index]]!.first!
            titleLabel.text = tram.groupOfLine
        case "SHIP":
            let boat = realTimeDepartures.boats[boatKeys[index]]!.first!
            titleLabel.text = boat.stopAreaName
        default:
            break
        }
    }
}

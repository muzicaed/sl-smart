//
//  RealTimeDepartures.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

open class RealTimeDepartures {
    
    open let latestUpdated: Date?
    open let dataAge: Int
    open var busses = [String: [RTTransport]]()
    open var metros = [String: [RTTransport]]()
    open var trains = [String: [RTTransport]]()
    open var trams = [String: [RTTransport]]()
    open var localTrams = [String: [RTTransport]]()
    open var boats = [String: [RTTransport]]()
    open var deviations = [(String, String)]()
    
    /**
     * Init
     */
    init(lastUpdated: String?, dataAge: Int?) {
        if let dateString = lastUpdated {
            self.latestUpdated = RealTimeDepartures.convertDate(dateString)
        } else {
            self.latestUpdated = nil
        }
        if let age = dataAge {
            self.dataAge = age
        } else {
            self.dataAge = 0
        }
    }
    
    /**
     * Converts string to date.
     */
    fileprivate static func convertDate(_ dateStr: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.date(from: dateStr)!
    }
}

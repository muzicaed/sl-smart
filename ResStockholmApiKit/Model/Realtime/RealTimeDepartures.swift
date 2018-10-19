//
//  RealTimeDepartures.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

open class RealTimeDepartures {
    
    public let latestUpdated: Date?
    public let dataAge: Int
    public var busses = [String: [RTTransport]]()
    public var metros = [String: [RTTransport]]()
    public var trains = [String: [RTTransport]]()
    public var trams = [String: [RTTransport]]()
    public var localTrams = [String: [RTTransport]]()
    public var boats = [String: [RTTransport]]()
    public var deviations = [(String, String)]()
    
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

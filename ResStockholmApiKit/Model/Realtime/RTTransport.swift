//
//  RTTransport.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

open class RTTransport {
    
    public let stopAreaName: String
    public let lineNumber: String
    public let destination: String
    public let displayTime: String
    public let deviations: [String]
    public let journeyDirection: Int
    public let stopPointDesignation: String
    public let groupOfLine: String?
    public let secondaryDestinationName: String?
    
    
    /**
     * Init
     */
    init(stopAreaName: String, lineNumber: String, destination: String,
         displayTime: String, deviations: [String], journeyDirection: Int,
         stopPointDesignation: String?, groupOfLine: String?,
         secondaryDestinationName: String?) {
        
        self.stopAreaName = stopAreaName
        self.lineNumber = lineNumber
        self.destination = destination
        self.displayTime = displayTime
        self.deviations = deviations
        self.journeyDirection = journeyDirection
        self.groupOfLine = groupOfLine
        self.secondaryDestinationName = secondaryDestinationName
        if let stopPoint = stopPointDesignation {
            self.stopPointDesignation = stopPoint
        } else {
            self.stopPointDesignation = ""
        }
    }
}

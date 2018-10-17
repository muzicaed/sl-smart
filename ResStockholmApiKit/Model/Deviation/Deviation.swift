//
//  Deviation.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-02-22.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

public class Deviation {
    
    public let scope: String
    public let title: String
    public let details: String
    public let reported: Date
    public let fromDate: Date
    public let tripType: TripType
    
    init(scope: String, title: String, details: String, reportedDate: String, fromDate: String) {
        
        self.scope = Deviation.makeFriendlyScope(scope)
        self.title = title
        self.details = details
        self.reported = Deviation.convertDate(reportedDate)
        self.fromDate = Deviation.convertDate(fromDate)
        self.tripType = Deviation.extractTripType(scope)
    }
    
    /**
     * Converts "2016-02-21T11:49:58.79+01:00" into NSDate object
     */
    fileprivate static func convertDate(_ dateStr: String) -> Date {
        let end = dateStr.characters.index(dateStr.startIndex, offsetBy: 16)
        var croppedStr = String(dateStr[dateStr.startIndex ..< end])
        croppedStr = croppedStr.replacingOccurrences(
            of: "T",
            with: " ",
            options: NSString.CompareOptions.literal,
            range: nil)
        return DateUtils.convertDateString(String(croppedStr))
    }
    
    /**
     * Extracts trip type from scope string.
     */
    fileprivate static func extractTripType(_ scope: String) -> TripType {
        if scope.lowercased().range(of: "pendeltåg") != nil {
            return TripType.Train
        } else if scope.lowercased().range(of: "buss") != nil {
            return TripType.Bus
        } else if scope.lowercased().range(of: "närtrafiken") != nil {
            return TripType.Bus
        } else if scope.lowercased().range(of: "tunnelbana") != nil {
            return TripType.Metro
        } else if scope.lowercased().range(of: "spårvagn") != nil {
            return TripType.Tram
        } else if scope.lowercased().range(of: "saltsjöbanan") != nil {
            return TripType.Local
        } else if scope.lowercased().range(of: "roslagsbanan") != nil {
            return TripType.Local
        }
        
        return TripType.Bus
    }
    
    /**
     * Fix scope text to match sematics
     */
    fileprivate static func makeFriendlyScope(_ scope: String) -> String {
        var newScope = scope
        newScope = scope.replacingOccurrences(of: "Tunnelbanans röda linje", with: "Röda linjen")
        newScope = scope.replacingOccurrences(of: "Tunnelbanans gröna linje", with: "Gröna linjen")
        newScope = scope.replacingOccurrences(of: "Tunnelbanans blå linje", with: "Blå linjen")
        
        return newScope
    }
}

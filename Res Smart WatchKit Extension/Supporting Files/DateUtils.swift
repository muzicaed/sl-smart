//
//  DateUtils.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class DateUtils {
    
    /**
     * Converts date and time strings ("2015-01-01" and "13:32") to
     * NSDate object.
     */
    static func convertDateString(_ dateTime: String) -> Date {
        let formatter = getSwedishFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: dateTime)!
    }
    
    /**
     * Converts a NSDate to a swedish local date string
     * eg. "2015-02-06"
     */
    static func dateAsDateString(_ date: Date) -> String {
        let formatter = getSwedishFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    /**
     * Converts a NSDate to a swedish local time string
     * eg. "17:04"
     */
    static func dateAsTimeString(_ date: Date) -> String {
        let formatter = getSwedishFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    /**
     * Converts a NSDate to a swedish local time string
     * eg. "17:04"
     */
    public static func dateAsTimeNoSecString(_ date: Date) -> String {
        let formatter = getSwedishFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    /**
     * Converts a NSDate to a swedish local friendly
     * date string.
     */
    public static func friendlyDate(_ date: Date) -> String {
        let formatter = getFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        if Calendar.current.isDateInToday(date) {
            return "Today".localized
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow".localized
        }
        
        return formatter.string(from: date)
    }
    
    /**
     * Converts a NSDate to a swedish local friendly
     * date string.
     */
    public static func friendlyDateAndTime(_ date: Date) -> String {
        let formatter = getFormatter()
        
        formatter.dateFormat = "EEEE"
        var dayStr = formatter.string(from: date)
        if Calendar.current.isDateInToday(date) {
            formatter.dateStyle = .none
            dayStr = "Today".localized
        } else if Calendar.current.isDateInTomorrow(date) {
            formatter.dateStyle = .none
            dayStr = "Tomorrow".localized
        }
        
        return dayStr
    }
    
    /**
     * Converts a NSDate to a swedish local tuple with
     * date and time string
     * eg. "2015-02-06" and "17:04"
     */
    static func dateAsStringTuple(_ date: Date) -> (date: String, time: String) {
        return (dateAsDateString(date), dateAsTimeString(date))
    }
    
    /**
     * Gets today's day of week as integer.
     */
    static func getDayOfWeek() -> Int {
        let formatter = getSwedishFormatter()
        formatter.dateFormat = "c"
        return Int(formatter.string(from: Date()))!
    }
    
    /**
     * Gets today's hour of day as integer.
     */
    static func getHourOfDay() -> Int {
        let formatter = getSwedishFormatter()
        formatter.dateFormat = "H"
        return Int(formatter.string(from: Date()))!
    }
    
    /**
     * Creates a human friendly deparure time.
     */
    static func createDepartureTimeString(_ departureTime: String, isWalk: Bool) -> String {
        var aboutStr = "In".localized
        var nowStr = "Departs now".localized
        if isWalk {
            aboutStr = "Walk in".localized
            nowStr = "Walk now".localized
        }
        
        let departureDate = DateUtils.convertDateString(departureTime)
        let diffMin = Int(ceil(((departureDate.timeIntervalSince1970 - Date().timeIntervalSince1970) / 60)) + 0.5)
        if diffMin < 31 && diffMin > -1 {
            return (diffMin < 1) ? "\(nowStr)" : "\(aboutStr) \(diffMin) min"
        }
        
        return DateUtils.dateAsTimeString(departureDate)
    }
    
    // MARK: Private
    
    static func getSwedishFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "sv_SE")
        return formatter
    }
    
    fileprivate static func getFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        return formatter
    }
}

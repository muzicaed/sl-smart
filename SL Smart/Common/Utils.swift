//
//  Utils.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class Utils {
  
  /**
   * Converts date and time strings ("2015-01-01" and "13:32") to
   * NSDate object.
   */
  static func convertDateString(dateTime: String) -> NSDate {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "sv_SE")
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    
    return formatter.dateFromString(dateTime)!
  }
  
  /**
   * Converts a NSDate to a swedish local date string
   * eg. "2015-02-06"
   */
  static func dateAsDateString(date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "sv_SE")
    formatter.dateFormat = "yyyy-MM-dd"
    
    return formatter.stringFromDate(date)
  }
  
  /**
   * Converts a NSDate to a swedish local time string
   * eg. "17:04"
   */
  static func dateAsTimeString(date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "sv_SE")
    formatter.dateFormat = "HH:mm"
    
    return formatter.stringFromDate(date)
  }

   /**
   * Converts a NSDate to a swedish local friendly
   * date string.
   */
  static func friendlyDate(date: NSDate) -> String {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "sv_SE")
    
    formatter.dateFormat = "EEEE"
    let weekDay = (formatter.stringFromDate(date) + "en").capitalizedString

    formatter.dateFormat = "d"
    var day = formatter.stringFromDate(date)
    day = (day == "1" || day == "2") ? day + ":a" : day + ":e"

    formatter.dateFormat = "MMMM"
    let month = formatter.stringFromDate(date)
    
    return ("\(weekDay) den \(day) \(month)")
  }
  
  /**
   * Converts a NSDate to a swedish local tuple with 
   * date and time string
   * eg. "2015-02-06" and "17:04"
   */
  static func dateAsStringTuple(date: NSDate) -> (date: String, time: String) {
    return (dateAsDateString(date), dateAsTimeString(date))
  }
}
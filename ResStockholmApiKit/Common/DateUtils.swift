//
//  DateUtils.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class DateUtils {
  
  /**
   * Converts date and time string ("2015-01-01 13:32") to
   * NSDate object.
   */
  public static func convertDateString(dateTime: String) -> NSDate {
    let formatter = getSwedishFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.dateFromString(dateTime)!
  }
  
  /**
   * Converts a NSDate to a swedish local date string
   * eg. "2015-02-06"
   */
  public static func dateAsDateString(date: NSDate) -> String {
    let formatter = getSwedishFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.stringFromDate(date)
  }
  
  /**
   * Converts a NSDate to a swedish local time string
   * eg. "17:04"
   */
  public static func dateAsTimeString(date: NSDate) -> String {
    let formatter = getSwedishFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.stringFromDate(date)
  }
  
  /**
   * Converts a NSDate to a swedish local date and time string
   * eg. "2015-02-06 11:32"
   */
  public static func dateAsDateAndTimeString(date: NSDate) -> String {
    let formatter = getSwedishFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.stringFromDate(date)
  }
  
  /**
   * Converts a NSDate to a swedish local friendly
   * date string.
   */
  public static func friendlyDate(date: NSDate) -> String {
    let formatter = getSwedishFormatter()
    
    formatter.dateFormat = "EEEE"
    var weekDay = formatter.stringFromDate(date)
    if formatter.stringFromDate(NSDate()) == weekDay {
      weekDay = "Idag, \(weekDay)en"
    } else if formatter.stringFromDate(NSDate(timeIntervalSinceNow: 86400)) == weekDay {
      weekDay = "Imorgon, \(weekDay)en"
    } else {
      weekDay = (weekDay + "en").capitalizedString
    }
    
    formatter.dateFormat = "d"
    var day = formatter.stringFromDate(date)
    day = (day == "1" || day == "2") ? day + ":a" : day + ":e"
    
    formatter.dateFormat = "MMMM"
    let month = formatter.stringFromDate(date)
    
    return ("\(weekDay) den \(day) \(month)")
  }
  
  /**
   * Converts a NSDate to a swedish local friendly
   * date string.
   */
  public static func friendlyDateAndTime(date: NSDate) -> String {
    let formatter = getSwedishFormatter()
    
    formatter.dateFormat = "d"
    var day = formatter.stringFromDate(date)
    day = (day == "1" || day == "2") ? day + ":a" : day + ":e"
    
    formatter.dateFormat = "EEEE"
    var weekDay = formatter.stringFromDate(date)
    if formatter.stringFromDate(NSDate()) == weekDay {
      weekDay = "Idag"
    } else if formatter.stringFromDate(NSDate(timeIntervalSinceNow: 86400)) == weekDay {
      weekDay = "imorgon"
    } else {
      weekDay = weekDay.capitalizedString + " den \(day)"
    }
    
    formatter.dateFormat = "HH:mm"
    let time = formatter.stringFromDate(date)
    
    return ("\(weekDay), kl. \(time)")
  }
  
  /**
   * Creates an "(om xx min)" for depature time.
   */
  public static func createAboutTimeText(departure: NSDate, isWalk: Bool) -> String {
    var aboutStr = "Om"
    var nowStr = "Avgår nu"
    if isWalk {
      aboutStr = "Gå om"
      nowStr = "Gå nu"
    }
    
    let diffMin = Int(ceil(((departure.timeIntervalSince1970 - NSDate().timeIntervalSince1970) / 60)) + 0.5)
    if diffMin < 60 {
      let diffMinStr = (diffMin < 1) ? "\(nowStr)" : "\(aboutStr) \(diffMin) min"
      return diffMinStr
    }
    
    return ""
  }
  
  /**
   * Converts a NSDate to a swedish local tuple with
   * date and time string
   * eg. "2015-02-06" and "17:04"
   */
  public static func dateAsStringTuple(date: NSDate) -> (date: String, time: String) {
    return (dateAsDateString(date), dateAsTimeString(date))
  }
  
  /**
   * Gets today's day of week as integer.
   */
  public static func getDayOfWeek() -> Int {
    let formatter = getSwedishFormatter()
    formatter.dateFormat = "c"
    return Int(formatter.stringFromDate(NSDate()))!
  }
  
  /**
   * Gets today's hour of day as integer.
   */
  public static func getHourOfDay() -> Int {
    let formatter = getSwedishFormatter()
    formatter.dateFormat = "H"
    return Int(formatter.stringFromDate(NSDate()))!
  }
  
  /**
   * Creates human friendly trip duration string.
   */
  public static func createTripDurationString(min: Int) -> String {
    if min < 60 {
      return "Restid: \(min) min"
    }
    
    var remainder = String(min % 60)
    if remainder.characters.count <= 1 {
      remainder = "0" + remainder
    }
    return "Restid: \(min / 60):\(remainder) tim"
  }
  
  // MARK: Private
  
  private static func getSwedishFormatter() -> NSDateFormatter {
    let formatter = NSDateFormatter()
    formatter.locale = NSLocale(localeIdentifier: "sv_SE")
    return formatter
  }
}
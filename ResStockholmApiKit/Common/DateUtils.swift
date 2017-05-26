//
//  DateUtils.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

open class DateUtils {
  
  /**
   * Converts date and time string ("2015-01-01 13:32") to
   * NSDate object.
   */
  open static func convertDateString(_ dateTime: String) -> Date {
    let formatter = getSwedishFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    if let date =  formatter.date(from: dateTime) {
      return date
    }
    return Date.distantPast
  }
  
  /**
   * Converts a NSDate to a swedish local date string
   * eg. "2015-02-06"
   */
  open static func dateAsDateString(_ date: Date) -> String {
    let formatter = getSwedishFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
  }
  
  /**
   * Converts a NSDate to a swedish local time string
   * eg. "17:04"
   */
  open static func dateAsTimeString(_ date: Date) -> String {
    let formatter = getSwedishFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  }
  
  /**
   * Converts a NSDate to a swedish local date and time string
   * eg. "2015-02-06 11:32"
   */
  open static func dateAsDateAndTimeString(_ date: Date) -> String {
    let formatter = getSwedishFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.string(from: date)
  }
  
  /**
   * Converts a NSDate to a swedish local friendly
   * date string.
   */
  open static func friendlyDate(_ date: Date) -> String {
    let formatter = getSwedishFormatter()
    
    formatter.dateFormat = "EEEE"
    var weekDay = formatter.string(from: date)
    if formatter.string(from: Date()) == weekDay {
      weekDay = "Idag, \(weekDay)en"
    } else if formatter.string(from: Date(timeIntervalSinceNow: 86400)) == weekDay {
      weekDay = "Imorgon, \(weekDay)en"
    } else {
      weekDay = (weekDay + "en").capitalized
    }
    
    formatter.dateFormat = "d"
    var day = formatter.string(from: date)
    day = (day == "1" || day == "2") ? day + ":a" : day + ":e"
    
    formatter.dateFormat = "MMMM"
    let month = formatter.string(from: date)
    
    return ("\(weekDay) den \(day) \(month)")
  }
  
  /**
   * Converts a NSDate to a swedish local friendly
   * date string.
   */
  open static func friendlyDateAndTime(_ date: Date) -> String {
    let formatter = getSwedishFormatter()
    
    formatter.dateFormat = "d"
    var day = formatter.string(from: date)
    day = (day == "1" || day == "2") ? day + ":a" : day + ":e"
    
    formatter.dateFormat = "MMMM"
    let month = formatter.string(from: date)
    
    formatter.dateFormat = "EEEE"
    var weekDay = formatter.string(from: date)
    
    if formatter.string(from: Date()) == weekDay {
      weekDay = "Idag"
    } else if formatter.string(from: Date(timeIntervalSinceNow: 86400)) == weekDay {
      weekDay = "imorgon"
    } else {
      weekDay = weekDay.capitalized + " den \(day) \(month)"
    }
    
    formatter.dateFormat = "HH:mm"
    let time = formatter.string(from: date)
    
    return ("\(weekDay), kl. \(time)")
  }
  
  /**
   * Creates an "(om xx min)" for depature time.
   */
  open static func createAboutTimeText(_ departure: Date, isWalk: Bool) -> String {    
    var aboutStr = "In".localized
    var nowStr = "Departs now".localized
    if isWalk {
      aboutStr = "Walk in about".localized
      nowStr = "Walk now".localized
    }
    
    let diffMin = Int(ceil(((departure.timeIntervalSince1970 - Date().timeIntervalSince1970) / 60)) + 0.5)
    if diffMin < 60 && diffMin > 0 {
      let diffMinStr = (diffMin < 1) ? "\(nowStr)" : "\(aboutStr) \(diffMin) min"
      return diffMinStr
    } else if (diffMin < 0) {
      return "Already departed".localized
    }
    
    return ""
  }
  
  /**
   * Converts a NSDate to a swedish local tuple with
   * date and time string
   * eg. "2015-02-06" and "17:04"
   */
  open static func dateAsStringTuple(_ date: Date) -> (date: String, time: String) {
    return (dateAsDateString(date), dateAsTimeString(date))
  }
  
  /**
   * Gets today's day of week as integer.
   */
  open static func getDayOfWeek() -> Int {
    let formatter = getSwedishFormatter()
    formatter.dateFormat = "c"
    return Int(formatter.string(from: Date()))!
  }
  
  /**
   * Gets today's hour of day as integer.
   */
  open static func getHourOfDay() -> Int {
    let formatter = getSwedishFormatter()
    formatter.dateFormat = "H"
    return Int(formatter.string(from: Date()))!
  }
  
  /**
   * Creates human friendly trip duration string.
   */
  open static func createTripDurationString(_ min: Int) -> String {
    if min < 60 {
      return "\("Trip time:".localized): \(min) min"
    }
    
    var remainder = String(min % 60)
    if remainder.characters.count <= 1 {
      remainder = "0" + remainder
    }
    return "\("Trip time:".localized): \(min / 60):\(remainder) \("h".localized)"
  }
  
  // MARK: Private
  
  fileprivate static func getSwedishFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "sv_SE")
    return formatter
  }
}

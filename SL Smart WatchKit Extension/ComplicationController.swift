//
//  ComplicationController.swift
//  SL Smart WatchKit Extension
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
  
  let tintColor = UIColor(red: 22/255, green: 173/255, blue: 126/255, alpha: 1.0)
  
  // MARK: - Timeline Configuration
  
  func getSupportedTimeTravelDirectionsForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationTimeTravelDirections) -> Void) {
    //handler([.Forward])
    handler([])
  }
  
  func getTimelineStartDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
    handler(nil)
  }
  
  func getTimelineEndDateForComplication(complication: CLKComplication, withHandler handler: (NSDate?) -> Void) {
    handler(nil)
  }
  
  func getPrivacyBehaviorForComplication(complication: CLKComplication, withHandler handler: (CLKComplicationPrivacyBehavior) -> Void) {
    handler(.ShowOnLockScreen)
  }
  
  // MARK: - Timeline Population
  
  /**
   * Call the handler with the current timeline entry
   */
  func getCurrentTimelineEntryForComplication(complication: CLKComplication, withHandler handler: ((CLKComplicationTimelineEntry?) -> Void)) {

    var template: CLKComplicationTemplate? = nil
    switch complication.family {
    case .ModularSmall:
      template = createModularSmall("12:34")
    case .ModularLarge:
      template = createModularLarge("Åka till jobbet",
        originTime: "12:34", originName: "Kälvestavägen",
        destinationTime: "13:13",destinationName:  "Karlberg")
    case .UtilitarianSmall:
      template = createUtilitarianSmall("12:34")
    case .UtilitarianLarge:
      template = createUtilitarianLarge("12:34 Hälsa på Petter")
    case .CircularSmall:
      template = nil
    }
    
    if let template = template {
      handler(CLKComplicationTimelineEntry(date: NSDate(), complicationTemplate: template))
      return
    }
    handler(nil)
  }
  
  func getTimelineEntriesForComplication(complication: CLKComplication, beforeDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
    // Call the handler with the timeline entries prior to the given date
    handler(nil)
  }
  
  func getTimelineEntriesForComplication(complication: CLKComplication, afterDate date: NSDate, limit: Int, withHandler handler: (([CLKComplicationTimelineEntry]?) -> Void)) {
    // Call the handler with the timeline entries after to the given date
    handler(nil)
  }
  
  // MARK: - Update Scheduling
  
  /**
  * Schedule next data update
  */
  func getNextRequestedUpdateDateWithHandler(handler: (NSDate?) -> Void) {
    handler(NSDate(timeIntervalSinceNow: 60 * 15))
  }
  
  // MARK: - Placeholder Templates
  
  /**
  * This method will be called once per supported complication,
  * and the results will be cached
  */
  func getPlaceholderTemplateForComplication(
    complication: CLKComplication, withHandler handler: (CLKComplicationTemplate?) -> Void) {
      var template: CLKComplicationTemplate? = nil
      switch complication.family {
      case .ModularSmall:
        template = createModularSmall("--:--")
      case .ModularLarge:
        template = createModularLarge("Hälsa på Petter",
          originTime: "--:--", originName: "Centralen",
          destinationTime: "--:--",destinationName:  "Spånga")
      case .UtilitarianSmall:
        template = createUtilitarianSmall("--:--")
      case .UtilitarianLarge:
        template = createUtilitarianLarge("--:-- Hälsa på Petter")
      case .CircularSmall:
        template = nil
      }
      handler(template)
  }
  
  // MARK: Private
  
  /**
  * Create template for ModularSmall
  */
  private func createModularSmall(timeString: String) -> CLKComplicationTemplate {
    let modTemplate = CLKComplicationTemplateModularSmallStackImage()
    modTemplate.highlightLine2 = false
    modTemplate.line1ImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "CompModSmallIcon")!)
    modTemplate.line2TextProvider = CLKSimpleTextProvider(text: timeString)
    modTemplate.tintColor = tintColor
    return modTemplate
  }
  
  /**
   * Create template for ModularLarge
   */
  private func createModularLarge(title: String,
    originTime: String, originName: String,
    destinationTime: String, destinationName: String) -> CLKComplicationTemplate {
      
      let modTemplate = CLKComplicationTemplateModularLargeTable()
      modTemplate.headerImageProvider = CLKImageProvider(onePieceImage: UIImage(named: "CompModLargeIcon")!)
      modTemplate.headerTextProvider = CLKSimpleTextProvider(text: title)
      modTemplate.row1Column1TextProvider = CLKSimpleTextProvider(text: originTime)
      modTemplate.row1Column2TextProvider = CLKSimpleTextProvider(text: originName)
      modTemplate.row2Column1TextProvider = CLKSimpleTextProvider(text: destinationTime)
      modTemplate.row2Column2TextProvider = CLKSimpleTextProvider(text: destinationName)
      modTemplate.tintColor = tintColor
      return modTemplate
  }
  
  /**
   * Create template for UtilitarianSmall
   */
  private func createUtilitarianSmall(timeString: String) -> CLKComplicationTemplate {
    let modTemplate = CLKComplicationTemplateUtilitarianSmallFlat()
    modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "CompUtilIcon")!)
    modTemplate.textProvider = CLKSimpleTextProvider(text: timeString)
    modTemplate.tintColor = tintColor
    return modTemplate
  }
  
  /**
   * Create template for UtilitarianLarge
   */
  private func createUtilitarianLarge(message: String) -> CLKComplicationTemplate {
    let modTemplate = CLKComplicationTemplateUtilitarianLargeFlat()
    modTemplate.textProvider = CLKSimpleTextProvider(text: message)
    modTemplate.tintColor = tintColor
    return modTemplate
  }
}

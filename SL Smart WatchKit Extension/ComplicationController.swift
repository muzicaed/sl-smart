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
      template = createModularSmall()
    case .ModularLarge:
      template = nil
    case .UtilitarianSmall:
      template = createUtilitarianSmall()
    case .UtilitarianLarge:
      template = nil
    case .CircularSmall:
      template = createCircularSmall()
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
    handler(nil)
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
        template = createModularSmall()
      case .ModularLarge:
        template = nil
      case .UtilitarianSmall:
        template = createUtilitarianSmall()
      case .UtilitarianLarge:
        template = nil
      case .CircularSmall:
        template = createCircularSmall()
      }
      handler(template)
  }
  
  // MARK: Private
  
  /**
  * Create template for ModularSmall
  */
  private func createModularSmall() -> CLKComplicationTemplate {
    let modTemplate = CLKComplicationTemplateModularSmallSimpleImage()
    modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "CompModSmallIcon")!)
    modTemplate.tintColor = tintColor
    return modTemplate
  }

  /**
   * Create template for UtilitarianSmall
   */
  private func createUtilitarianSmall() -> CLKComplicationTemplate {
    let modTemplate = CLKComplicationTemplateUtilitarianSmallSquare()
    modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "CompUtilIcon")!)
    modTemplate.tintColor = tintColor
    return modTemplate
  }
  
  /**
   * Create template for CircularSmall
   */
  private func createCircularSmall() -> CLKComplicationTemplate {
    let modTemplate = CLKComplicationTemplateCircularSmallSimpleImage()
    modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "CompCircIcon")!)
    modTemplate.tintColor = tintColor
    return modTemplate
  }
}

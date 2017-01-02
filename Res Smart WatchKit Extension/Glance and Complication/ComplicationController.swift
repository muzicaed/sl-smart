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
  
  func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
    //handler([.Forward])
    handler([])
  }
  
  func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
    handler(nil)
  }
  
  func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
    handler(nil)
  }
  
  func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
    handler(.showOnLockScreen)
  }
  
  // MARK: - Timeline Population
  
  /**
   * Call the handler with the current timeline entry
   */
  func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: (@escaping (CLKComplicationTimelineEntry?) -> Void)) {

    var template: CLKComplicationTemplate? = nil
    switch complication.family {
    case .modularSmall:
      template = createModularSmall()
    case .modularLarge:
      template = nil
    case .utilitarianSmall:
      template = createUtilitarianSmall()
    case .utilitarianLarge:
      template = nil
    case .circularSmall:
      template = createCircularSmall()
    default:
      template = nil
    }
    
    if let template = template {
      handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
      return
    }
    handler(nil)
  }
  
  func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: (@escaping ([CLKComplicationTimelineEntry]?) -> Void)) {
    // Call the handler with the timeline entries prior to the given date
    handler(nil)
  }
  
  func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: (@escaping ([CLKComplicationTimelineEntry]?) -> Void)) {
    // Call the handler with the timeline entries after to the given date
    handler(nil)
  }
  
  // MARK: - Update Scheduling
  
  /**
  * Schedule next data update
  */
  func getNextRequestedUpdateDate(handler: @escaping (Date?) -> Void) {
    handler(nil)
  }
  
  // MARK: - Placeholder Templates
  
  /**
  * This method will be called once per supported complication,
  * and the results will be cached
  */
  func getPlaceholderTemplate(
    for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
      var template: CLKComplicationTemplate? = nil
      switch complication.family {
      case .modularSmall:
        template = createModularSmall()
      case .modularLarge:
        template = nil
      case .utilitarianSmall:
        template = createUtilitarianSmall()
      case .utilitarianLarge:
        template = nil
      case .circularSmall:
        template = createCircularSmall()
      default:
        template = nil
      }
      handler(template)
  }
  
  // MARK: Private
  
  /**
  * Create template for ModularSmall
  */
  fileprivate func createModularSmall() -> CLKComplicationTemplate {
    let modTemplate = CLKComplicationTemplateModularSmallSimpleImage()
    modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "CompModSmallIcon")!)
    modTemplate.tintColor = tintColor
    return modTemplate
  }

  /**
   * Create template for UtilitarianSmall
   */
  fileprivate func createUtilitarianSmall() -> CLKComplicationTemplate {
    let modTemplate = CLKComplicationTemplateUtilitarianSmallSquare()
    modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "CompUtilIcon")!)
    modTemplate.tintColor = tintColor
    return modTemplate
  }
  
  /**
   * Create template for CircularSmall
   */
  fileprivate func createCircularSmall() -> CLKComplicationTemplate {
    let modTemplate = CLKComplicationTemplateCircularSmallSimpleImage()
    modTemplate.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "CompCircIcon")!)
    modTemplate.tintColor = tintColor
    return modTemplate
  }
}

//
//  ScorePostHelper.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-29.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class ScorePostHelper {
  
  
  /**
   * Creates the score posts to represent a newly
   * created routine trip.
   */
  static func createScorePostForNewRoutine(routineTrip: RoutineTrip) {
    let scorePosts = DataStore.sharedInstance.retrieveScoreListFromStore()
    if routineTrip.routine != nil {
      scoreForNewRoutineTrip(routineTrip, scorePosts: scorePosts)
    }
    
    DataStore.sharedInstance.writeScoreListToStore(scorePosts)
  }
  
  /**
   * Handles changes to rotine for modified routine trip
   */
  static func handleRoutineChange(routineTrip: RoutineTrip,
    oldWeek: RoutineWeek, oldTime: RoutineTime) {
      
  }
  
  static func modifyScoreForPost()
  
  //MARK: Private
  
  
  /**
  * Handles score for new routine trip.
  */
  private static func scoreForNewRoutineTrip(routineTrip: RoutineTrip, scorePosts: [ScorePost]) {
    for dayInWeek in createWeekRange(routineTrip.routine!.week) {
      for hourOfDay in createHourRange(routineTrip.routine!.time) {
        print("Day: \(dayInWeek)")
        print(" - Hour: \(hourOfDay)")
      }
      // Add after midnight hours..
      if routineTrip.routine!.time == .Night {
        for hourOfDay in 0...4 {
          print("-----")
          print("Day: \(dayInWeek)")
          print(" - Hour: \(hourOfDay)")
        }
      }
    }
  }
  
  
  /**
   * Creates a day-in-week integer range based on RoutineWeek.
   */
  private static func createWeekRange(routineWeek: RoutineWeek) -> Range<Int> {
    if routineWeek == .WeekDays {
      return 1...5
    }
    return 6...7
  }
  
  /**
   * Creates a hour-of-day integer range based on RoutineWeek.
   */
  private static func createHourRange(routineTime: RoutineTime) -> Range<Int> {
    switch routineTime {
    case .Morning:
      return 5...10
    case .Day:
      return 11...17
    case .Evening:
      return 18...21
    case .Night:
      return 22...24
    }
  }
}
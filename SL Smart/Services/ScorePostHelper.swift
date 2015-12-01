//
//  ScorePostHelper.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-29.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class ScorePostHelper {
  
  static let NewRoutineTripScore = Float(5)
  static let TapCountScore = Float(2)
  static let NotBestTripScore = Float(-1)
  
  
  /**
   * Creates the score posts to represent a newly
   * created routine trip.
   */
  static func giveScoreForNewRoutineTrip(routineTrip: RoutineTrip) {
    var scorePosts = DataStore.sharedInstance.retrieveScorePosts()
    if routineTrip.routine != nil {
      scoreForRoutineTrip(routineTrip, scorePosts: &scorePosts, scoreMod: NewRoutineTripScore)
    }
    
    DataStore.sharedInstance.writeScorePosts(scorePosts)
  }
  
  /**
   * Handles changes to rotine for modified routine trip
   */
  static func giveScoreForUpdatedRoutineTrip(
    updatedRoutineTrip: RoutineTrip, oldRoutineTrip: RoutineTrip) {
      
      var scorePosts = DataStore.sharedInstance.retrieveScorePosts()
      if oldRoutineTrip.routine != nil {
        scoreForRoutineTrip(oldRoutineTrip, scorePosts: &scorePosts, scoreMod: (NewRoutineTripScore * -1))
      }
      if updatedRoutineTrip.routine != nil {
        scoreForRoutineTrip(updatedRoutineTrip, scorePosts: &scorePosts, scoreMod: NewRoutineTripScore)
      }
      
      DataStore.sharedInstance.writeScorePosts(scorePosts)
  }
  
  /**
   * Handles score for new routine trip.
   */
  static func scoreForRoutineTrip(
    routineTrip: RoutineTrip, inout scorePosts: [ScorePost], scoreMod: Float) {
      for dayInWeek in createWeekRange(routineTrip.routine!.week) {
        for hourOfDay in createHourRange(routineTrip.routine!.time) {
          changeScore(
            dayInWeek, hourOfDay: hourOfDay,
            siteId: routineTrip.origin!.siteId,
            isOrigin: true, scoreMod: scoreMod, scorePosts: &scorePosts)
          changeScore(
            dayInWeek, hourOfDay: hourOfDay,
            siteId: routineTrip.destination!.siteId,
            isOrigin: false, scoreMod: scoreMod, scorePosts: &scorePosts)
          
        }
        // Add after midnight hours..
        if routineTrip.routine!.time == .Night {
          for hourOfDay in 0...4 {
            changeScore(
              dayInWeek, hourOfDay: hourOfDay,
              siteId: routineTrip.origin!.siteId,
              isOrigin: true, scoreMod: scoreMod, scorePosts: &scorePosts)
            changeScore(
              dayInWeek, hourOfDay: hourOfDay,
              siteId: routineTrip.destination!.siteId,
              isOrigin: false, scoreMod: scoreMod, scorePosts: &scorePosts)
          }
        }
      }
  }
  
  //MARK: Private
  
  
  /**
  * Change (or create) score for matching score post.
  */
  private static func changeScore(
    dayInWeek: Int, hourOfDay: Int,
    siteId: Int, isOrigin: Bool, scoreMod: Float, inout scorePosts: [ScorePost]) {
      
      if !modifyScorePost(
        dayInWeek, hourOfDay: hourOfDay, siteId: siteId,
        isOrigin: isOrigin, allPosts: &scorePosts, scoreMod: scoreMod) {
          
          let newScorePost = ScorePost(
            dayInWeek: dayInWeek, hourOfDay: hourOfDay,
            siteId: siteId, score: scoreMod, isOrigin: isOrigin)
          scorePosts.append(newScorePost)
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
      return 22...23
    }
  }
  
  /**
   * Finds existing score post
   */
  private static func modifyScorePost(
    dayInWeek: Int, hourOfDay: Int, siteId: Int, isOrigin: Bool,
    inout allPosts: [ScorePost], scoreMod: Float) -> Bool {
      
      for post in allPosts {
        if post.dayInWeek == dayInWeek && post.hourOfDay == hourOfDay &&
          post.siteId == siteId && post.isOrigin == isOrigin {
            
            post.score += scoreMod
            return true
        }
      }
      
      return false
  }
}
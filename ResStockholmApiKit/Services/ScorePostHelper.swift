//
//  ScorePostHelper.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-29.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class ScorePostHelper {
  
  static let NewRoutineTripScore = Float(5)
  static let TapCountScore = Float(2)
  static let NotBestTripScore = Float(-1)
  static let RequiredDistance = Double(400)
  
  
  /**
   * Creates the score posts to represent a newly
   * created routine trip.
   */
  public static func giveScoreForNewRoutineTrip(routineTrip: RoutineTrip) {
    var scorePosts = DataStore.sharedInstance.retrieveScorePosts()
    if routineTrip.routine != nil {
      scoreForRoutineTrip(routineTrip, scorePosts: &scorePosts,
        scoreMod: NewRoutineTripScore, location: nil)
    }
    
    DataStore.sharedInstance.writeScorePosts(scorePosts)
  }
  
  /**
   * Handles changes to rotine for modified routine trip
   */
  public static func giveScoreForUpdatedRoutineTrip(
    updatedRoutineTrip: RoutineTrip, oldRoutineTrip: RoutineTrip) {
      
      var scorePosts = DataStore.sharedInstance.retrieveScorePosts()
      if oldRoutineTrip.routine != nil {
        scoreForRoutineTrip(oldRoutineTrip, scorePosts: &scorePosts,
          scoreMod: (NewRoutineTripScore * -1), location: nil)
      }
      if updatedRoutineTrip.routine != nil {
        scoreForRoutineTrip(updatedRoutineTrip, scorePosts: &scorePosts,
          scoreMod: NewRoutineTripScore, location: nil)
      }
      
      DataStore.sharedInstance.writeScorePosts(scorePosts)
  }
  
  /**
   * Change (or create) score for matching score post.
   */
  public static func changeScore(
    dayInWeek: Int, hourOfDay: Int,
    siteId: Int, isOrigin: Bool, scoreMod: Float,
    location: CLLocation?, inout scorePosts: [ScorePost]) {
      
      if !modifyScorePost(
        dayInWeek, hourOfDay: hourOfDay, siteId: siteId,
        isOrigin: isOrigin, location: location,
        allPosts: &scorePosts, scoreMod: scoreMod) {
          
          let newScorePost = ScorePost(
            dayInWeek: dayInWeek, hourOfDay: hourOfDay,
            siteId: siteId, score: scoreMod, isOrigin: isOrigin, location: location)
          print("Created new score post (Score: \(scoreMod)).")
          print(" - DW: \(dayInWeek), HD: \(hourOfDay), ID: \(siteId), isOri: \(isOrigin)")
          scorePosts.append(newScorePost)
      }
  }
  
  /**
   * Adds score for selected routine trip.
   */
  public static func addScoreForSelectedRoutineTrip(originId: Int, destinationId: Int) {
    var scorePosts = DataStore.sharedInstance.retrieveScorePosts()
    let currentLocation = MyLocationHelper.sharedInstance.currentLocation
    let dayOfWeek = DateUtils.getDayOfWeek()
    let hourOfDay = DateUtils.getHourOfDay()
    let originId = originId
    let destinationId = destinationId
    
    ScorePostHelper.changeScore(dayOfWeek, hourOfDay: hourOfDay,
      siteId: originId, isOrigin: true, scoreMod: 2,
      location: currentLocation, scorePosts: &scorePosts)
    ScorePostHelper.changeScore(dayOfWeek, hourOfDay: hourOfDay,
      siteId: destinationId, isOrigin: false, scoreMod: 3,
      location: currentLocation, scorePosts: &scorePosts)
    DataStore.sharedInstance.writeScorePosts(scorePosts)
  }
  
  //MARK: Private
  
  /**
  * Handles score for new routine trip.
  */
  static private func scoreForRoutineTrip(
    routineTrip: RoutineTrip, inout scorePosts: [ScorePost],
    scoreMod: Float, location: CLLocation?) {
      for dayInWeek in createWeekRange(routineTrip.routine!.week) {
        for hourOfDay in createHourRange(routineTrip.routine!.time) {
          changeScore(
            dayInWeek, hourOfDay: hourOfDay,
            siteId: routineTrip.criterions.origin!.siteId,
            isOrigin: true, scoreMod: scoreMod,
            location: location, scorePosts: &scorePosts)
          changeScore(
            dayInWeek, hourOfDay: hourOfDay,
            siteId: routineTrip.criterions.dest!.siteId,
            isOrigin: false, scoreMod: scoreMod,
            location: location, scorePosts: &scorePosts)
          
        }
        // Add after midnight hours..
        if routineTrip.routine!.time == .Night {
          for hourOfDay in 0...4 {
            changeScore(
              dayInWeek, hourOfDay: hourOfDay,
              siteId: routineTrip.criterions.origin!.siteId,
              isOrigin: true, scoreMod: scoreMod,
              location: location, scorePosts: &scorePosts)
            changeScore(
              dayInWeek, hourOfDay: hourOfDay,
              siteId: routineTrip.criterions.dest!.siteId,
              isOrigin: false, scoreMod: scoreMod,
              location: location, scorePosts: &scorePosts)
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
      return 22...23
    }
  }
  
  /**
   * Finds existing score post
   */
  private static func modifyScorePost(
    dayInWeek: Int, hourOfDay: Int, siteId: Int, isOrigin: Bool,
    location: CLLocation?, inout allPosts: [ScorePost], scoreMod: Float) -> Bool {
      
      for post in allPosts {
        if post.dayInWeek == dayInWeek && post.hourOfDay == hourOfDay &&
          post.siteId == siteId && post.isOrigin == isOrigin {
            print("Found post on id & time")
            if let location = location, postLocation = post.location {
              if location.distanceFromLocation(postLocation) < RequiredDistance {
                print("Found post within distance")
                post.score += scoreMod
                print("Modified score post (Score: \(post.score)).")
                return true
              }
            }
        }
      }
      
      return false
  }
}
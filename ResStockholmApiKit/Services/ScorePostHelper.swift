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
  
  public static let BestTapCountScore = Float(0.6)
  public static let OtherTapCountScore = Float(0.5)
  public static let NotBestTripScore = Float(-0.5)
  public static let WideScoreMod = Float(0.25)
  private static let RequiredDistance = Double(400)
  
  /**
   * Adds score for selected routine trip.
   */
  public static func changeScoreForRoutineTrip(
    originId: String, destinationId: String, score: Float) {
      
      print("CHANGE SCORE: \(score)")
      
      var scorePosts = ScorePostStore.sharedInstance.retrieveScorePosts()
      let currentLocation = MyLocationHelper.sharedInstance.currentLocation
      let dayOfWeek = DateUtils.getDayOfWeek()
      let hourOfDay = DateUtils.getHourOfDay()
      
      ScorePostHelper.changeScore(dayOfWeek, hourOfDay: hourOfDay,
        originId: originId, destId: destinationId, score: score,
        location: currentLocation, scorePosts: &scorePosts)
      ScorePostStore.sharedInstance.writeScorePosts(scorePosts)
  }
  
  /**
   * Change (or create) score for matching score post.
   */
  private static func changeScore(
    dayInWeek: Int, hourOfDay: Int,
    originId: String, destId: String, score: Float,
    location: CLLocation?, inout scorePosts: [ScorePost]) {
      
      applyScore(dayInWeek, hourOfDay: hourOfDay,
        originId: originId, destId: destId, score: score,
        location: location, scorePosts: &scorePosts)
      
      var daysRange = 1...5
      if dayInWeek > 5 {
        daysRange = 6...7
      }
      
      for day in daysRange {
        for hour in (hourOfDay-1)...(hourOfDay+1) {
          if hour > 0 && hour <= 24 {
            applyScore(day, hourOfDay: hour,
              originId: originId, destId: destId, score: (score * WideScoreMod),
              location: location, scorePosts: &scorePosts)
          }
        }
      }
  }
  
  //MARK: Private
  
  /**
  * Applys the score modifier.
  * Will modify if existing post is found, else
  * create a new one.
  */
  private static func applyScore(
    dayInWeek: Int, hourOfDay: Int,
    originId: String, destId: String, score: Float,
    location: CLLocation?, inout scorePosts: [ScorePost]) {
      if !modifyScorePost(
        dayInWeek, hourOfDay: hourOfDay, originId: originId,
        destId: destId, location: location,
        allPosts: &scorePosts, score: score) {
          
          let newScorePost = ScorePost(
            dayInWeek: dayInWeek, hourOfDay: hourOfDay,
            originId: originId, destId: destId, score: score, location: location)
          scorePosts.append(newScorePost)
      }
  }
  
  /**
   * Finds existing score post
   */
  private static func modifyScorePost(
    dayInWeek: Int, hourOfDay: Int, originId: String, destId: String,
    location: CLLocation?, inout allPosts: [ScorePost], score: Float) -> Bool {
      
      for post in allPosts {
        if isMatch(post, dayInWeek: dayInWeek, hourOfDay: hourOfDay, originId: originId, destId: destId) {
          if let location = location, postLocation = post.location {
            if location.distanceFromLocation(postLocation) < RequiredDistance {
              post.score += score
              post.score = min(post.score, 8)
              return true
            }
          }
        }
      }
      return false
  }
  
  /**
   * Check if score post is a match.
   */
  private static func isMatch(post: ScorePost, dayInWeek: Int,
    hourOfDay: Int, originId: String, destId: String) -> Bool {
      return (post.dayInWeek == dayInWeek && post.hourOfDay == hourOfDay &&
        post.originId == originId && post.destId == destId)
  }
}
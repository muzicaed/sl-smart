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

  public static let BestTapCountScore = Float(3)
  public static let OtherTapCountScore = Float(2)
  public static let NotBestTripScore = Float(-0.5)
  public static let WideScoreMod = Float(0.5)
  private static let RequiredDistance = Double(400)
  
  /**
   * Adds score for selected routine trip.
   */
  public static func changeScoreForRoutineTrip(originId: Int, destinationId: Int, score: Float) {
    var scorePosts = DataStore.sharedInstance.retrieveScorePosts()
    let currentLocation = MyLocationHelper.sharedInstance.currentLocation
    let dayOfWeek = DateUtils.getDayOfWeek()
    let hourOfDay = DateUtils.getHourOfDay()
    let originId = originId
    let destinationId = destinationId
    
    ScorePostHelper.changeScore(dayOfWeek, hourOfDay: hourOfDay,
      siteId: originId, isOrigin: true, score: score,
      location: currentLocation, scorePosts: &scorePosts)
    ScorePostHelper.changeScore(dayOfWeek, hourOfDay: hourOfDay,
      siteId: destinationId, isOrigin: false, score: score,
      location: currentLocation, scorePosts: &scorePosts)
    DataStore.sharedInstance.writeScorePosts(scorePosts)
  }
  
  /**
   * Change (or create) score for matching score post.
   */
  private static func changeScore(
    dayInWeek: Int, hourOfDay: Int,
    siteId: Int, isOrigin: Bool, score: Float,
    location: CLLocation?, inout scorePosts: [ScorePost]) {
      
      applyScore(dayInWeek, hourOfDay: hourOfDay,
        siteId: siteId, isOrigin: isOrigin, score: score,
        location: location, scorePosts: &scorePosts)
      
      var daysRange = 1...5
      if dayInWeek > 5 {
        daysRange = 6...7
      }
      
      for day in daysRange {
        for hour in (hourOfDay-1)...(hourOfDay+1) {
          if hour > 0 && hour <= 24 {
            print("Extra score: D:\(day) H:\(hour)")
            applyScore(day, hourOfDay: hour,
              siteId: siteId, isOrigin: isOrigin, score: (score * WideScoreMod),
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
    siteId: Int, isOrigin: Bool, score: Float,
    location: CLLocation?, inout scorePosts: [ScorePost]) {
      if !modifyScorePost(
        dayInWeek, hourOfDay: hourOfDay, siteId: siteId,
        isOrigin: isOrigin, location: location,
        allPosts: &scorePosts, score: score) {
          
          let newScorePost = ScorePost(
            dayInWeek: dayInWeek, hourOfDay: hourOfDay,
            siteId: siteId, score: score, isOrigin: isOrigin, location: location)
          print("Created new score post (Score: \(score)).")
          print(" - DW: \(dayInWeek), HD: \(hourOfDay), ID: \(siteId), isOri: \(isOrigin)")
          scorePosts.append(newScorePost)
      }
  }
  
  
  /**
   * Finds existing score post
   */
  private static func modifyScorePost(
    dayInWeek: Int, hourOfDay: Int, siteId: Int, isOrigin: Bool,
    location: CLLocation?, inout allPosts: [ScorePost], score: Float) -> Bool {
      
      for post in allPosts {
        if post.dayInWeek == dayInWeek && post.hourOfDay == hourOfDay &&
          post.siteId == siteId && post.isOrigin == isOrigin {
            print("Found post on id & time")
            if let location = location, postLocation = post.location {
              if location.distanceFromLocation(postLocation) < RequiredDistance {
                print("Found post within distance")
                post.score += score
                print("Modified score post (Score: \(post.score)).")
                return true
              }
            }
        }
      }
      
      return false
  }
}
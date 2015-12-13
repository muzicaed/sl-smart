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
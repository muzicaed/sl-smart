//
//  StyleHelper.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class StyleHelper {
  
  static let sharedInstance = StyleHelper()
  let tintColor = UIColor(red: 22/255, green: 173/255, blue: 126/255, alpha: 1.0)
  let mainGreen = UIColor(red: 22/255, green: 173/255, blue: 126/255, alpha: 1.0)
  
  let highlight = UIColor(red: 229/255, green: 255/255, blue: 255/255, alpha: 0.95)
  let background = UIColor(red: 231/255, green: 237/255, blue: 238/255, alpha: 1.0)
  let cardBackground = UIColor(red: 63/255, green: 73/255, blue: 62/255, alpha: 0.8)
  let warningColor = UIColor(red: 255/255, green: 75/255, blue: 0/255, alpha: 1.0)
  let realtimeColor = UIColor(red: 0/255, green: 113/255, blue: 218/255, alpha: 1.0)
  
  func setupCustomStyle() {
    let navAppearance = UINavigationBar.appearance()
    navAppearance.translucent = false
    navAppearance.tintColor = UIColor.whiteColor()
    navAppearance.barTintColor = mainGreen
    navAppearance.titleTextAttributes = [
      NSForegroundColorAttributeName: UIColor.whiteColor(),
      NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 18)!]
    
    UIBarButtonItem.appearance().setTitleTextAttributes(
      [
        NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16)!
      ], forState: .Normal)
    
    UIBarButtonItem.appearance().setTitleTextAttributes(
      [
        NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 16)!
      ], forState: .Highlighted)
    
    UISegmentedControl.appearance().setTitleTextAttributes(
      [
        NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 14)!
      ], forState: .Normal)
    
    UISegmentedControl.appearance().setTitleTextAttributes(
      [
        NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 14)!
      ], forState: .Highlighted)
    
    let tabBarAppearance = UITabBar.appearance()
    tabBarAppearance.tintColor = mainGreen
    
    let searchBarAppearance = UISearchBar.appearance()
    searchBarAppearance.tintColor = tintColor
    searchBarAppearance.barTintColor = mainGreen
    
    UITabBarItem.appearance().setTitleTextAttributes(
      [
        NSForegroundColorAttributeName: UIColor(white: 0.0, alpha: 0.75),
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 12)!
      ], forState: .Normal)
    
    UITabBarItem.appearance().setTitleTextAttributes(
      [
        NSForegroundColorAttributeName: mainGreen,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 12)!
      ], forState: .Selected)
    
    UIApplication.sharedApplication().statusBarStyle = .LightContent
    (UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self])).tintColor = UIColor.whiteColor()
  }
  
  func tintImage(image: UIImage, color: UIColor) -> UIImage {
    let size = image.size
    
    UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()
    image.drawAtPoint(CGPointZero, blendMode: CGBlendMode.Normal, alpha: 1.0)
    
    CGContextSetFillColorWithColor(context, color.CGColor)
    CGContextSetBlendMode(context, CGBlendMode.SourceIn)
    CGContextSetAlpha(context, 1.0)
    
    let rect = CGRectMake(
      CGPointZero.x,
      CGPointZero.y,
      image.size.width,
      image.size.height)
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect)
    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return tintedImage
  }
}

extension UIImage {
  func imageWithColor(color1: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
    
    let context = UIGraphicsGetCurrentContext()! as CGContextRef
    CGContextTranslateCTM(context, 0, self.size.height)
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, CGBlendMode.Normal)
    
    let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
    CGContextClipToMask(context, rect, self.CGImage)
    color1.setFill()
    CGContextFillRect(context, rect)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
    UIGraphicsEndImageContext()
    
    return newImage
  }
}
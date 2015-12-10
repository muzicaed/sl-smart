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
  let mainGreen = UIColor(red: 51/255, green: 143/255, blue: 89/255, alpha: 1.0)
  let mainGreenLight = UIColor(red: 51/255, green: 143/255, blue: 89/255, alpha: 0.4)
  let background = UIColor(red: 219/255, green: 235/255, blue: 227/255, alpha: 1.0)
  let cardBackground = UIColor(red: 63/255, green: 73/255, blue: 62/255, alpha: 0.8)

  func setupCustomStyle() {
    let navAppearance = UINavigationBar.appearance()
    navAppearance.tintColor = UIColor.whiteColor()
    navAppearance.barTintColor = mainGreen
    navAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    
    let tabBarAppearance = UITabBar.appearance()
    tabBarAppearance.tintColor = mainGreen

    let searchBarAppearance = UISearchBar.appearance()
    searchBarAppearance.tintColor = tintColor
    searchBarAppearance.barTintColor = mainGreen

    UITabBarItem.appearance().setTitleTextAttributes(
      [NSForegroundColorAttributeName: UIColor(white: 0.0, alpha: 0.75)],
      forState: UIControlState.Normal)
    
    UITabBarItem.appearance().setTitleTextAttributes(
      [NSForegroundColorAttributeName: mainGreen],
      forState: UIControlState.Selected)
    
    UIApplication.sharedApplication().statusBarStyle = .LightContent
    (UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self])).tintColor = UIColor.whiteColor()
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
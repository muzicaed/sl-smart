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
  let tintColor = UIColor(red: 0.521, green: 0.709, blue: 0.043, alpha: 1.0)
  let lightTintColor = UIColor(red: 0.905, green: 1.0, blue: 0.815, alpha: 1.0)

  func setupCustomStyle() {
    let navAppearance = UINavigationBar.appearance()
    navAppearance.tintColor = UIColor.whiteColor()
    navAppearance.barTintColor = tintColor
    navAppearance.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
    
    let tabBarAppearance = UITabBar.appearance()
    tabBarAppearance.tintColor = UIColor.whiteColor()
    tabBarAppearance.barTintColor = tintColor

    let searchBarAppearance = UISearchBar.appearance()
    searchBarAppearance.tintColor = UIColor.whiteColor()
    searchBarAppearance.barTintColor = tintColor

    UITabBarItem.appearance().setTitleTextAttributes(
      [NSForegroundColorAttributeName:UIColor(white: 0.0, alpha: 0.75)],
      forState: UIControlState.Normal)
    
    UITabBarItem.appearance().setTitleTextAttributes(
      [NSForegroundColorAttributeName:UIColor.whiteColor()],
      forState: UIControlState.Selected)
    
    UIApplication.sharedApplication().statusBarStyle = .LightContent
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
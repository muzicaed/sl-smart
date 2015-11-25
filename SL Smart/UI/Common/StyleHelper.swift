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
  let tintColor = UIColor(red: 203/255, green: 62/255, blue: 148/255, alpha: 1.0)
  let mainGreen = UIColor(red: 125/255, green: 183/255, blue: 14/255, alpha: 1.0)

  func setupCustomStyle() {
    let navAppearance = UINavigationBar.appearance()
    navAppearance.tintColor = tintColor
    navAppearance.barTintColor = mainGreen
    navAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    
    let tabBarAppearance = UITabBar.appearance()
    tabBarAppearance.tintColor = tintColor
    tabBarAppearance.barTintColor = mainGreen

    let searchBarAppearance = UISearchBar.appearance()
    searchBarAppearance.tintColor = tintColor
    searchBarAppearance.barTintColor = mainGreen

    UITabBarItem.appearance().setTitleTextAttributes(
      [NSForegroundColorAttributeName: UIColor(white: 0.0, alpha: 0.75)],
      forState: UIControlState.Normal)
    
    UITabBarItem.appearance().setTitleTextAttributes(
      [NSForegroundColorAttributeName: tintColor],
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
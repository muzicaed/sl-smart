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
  let popColor = UIColor(red: 203/255, green: 62/255, blue: 148/255, alpha: 1.0)
  let tintColor = UIColor(red: 22/255, green: 173/255, blue: 126/255, alpha: 1.0)
  let mainGreen = UIColor(red: 51/255, green: 143/255, blue: 89/255, alpha: 1.0)

  func setupCustomStyle() {
    let navAppearance = UINavigationBar.appearance()
    navAppearance.tintColor = UIColor.whiteColor()
    navAppearance.barTintColor = mainGreen
    navAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    
    let tabBarAppearance = UITabBar.appearance()
    tabBarAppearance.tintColor = UIColor.whiteColor()
    tabBarAppearance.barTintColor = mainGreen

    let searchBarAppearance = UISearchBar.appearance()
    searchBarAppearance.tintColor = tintColor
    searchBarAppearance.barTintColor = mainGreen

    UITabBarItem.appearance().setTitleTextAttributes(
      [NSForegroundColorAttributeName: UIColor(white: 0.0, alpha: 0.75)],
      forState: UIControlState.Normal)
    
    UITabBarItem.appearance().setTitleTextAttributes(
      [NSForegroundColorAttributeName: UIColor.whiteColor()],
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
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
    navAppearance.isTranslucent = false
    navAppearance.tintColor = UIColor.white
    navAppearance.barTintColor = mainGreen
    navAppearance.titleTextAttributes = [
      NSForegroundColorAttributeName: UIColor.white]
    
    let tabBarAppearance = UITabBar.appearance()
    tabBarAppearance.tintColor = mainGreen
    
    let searchBarAppearance = UISearchBar.appearance()
    searchBarAppearance.tintColor = tintColor
    searchBarAppearance.barTintColor = mainGreen
    
    UITabBarItem.appearance().setTitleTextAttributes(
      [
        NSForegroundColorAttributeName: UIColor(white: 0.0, alpha: 0.75)
      ], for: UIControlState())
    
    UITabBarItem.appearance().setTitleTextAttributes(
      [
        NSForegroundColorAttributeName: mainGreen
      ], for: .selected)
    
    UIApplication.shared.statusBarStyle = .lightContent
    (UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])).tintColor = UIColor.white
  }
  
  func tintImage(_ image: UIImage, color: UIColor) -> UIImage {
    let size = image.size
    
    UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()
    image.draw(at: CGPoint.zero, blendMode: CGBlendMode.normal, alpha: 1.0)
    
    context?.setFillColor(color.cgColor)
    context?.setBlendMode(CGBlendMode.sourceIn)
    context?.setAlpha(1.0)
    
    let rect = CGRect(
      x: CGPoint.zero.x,
      y: CGPoint.zero.y,
      width: image.size.width,
      height: image.size.height)
    UIGraphicsGetCurrentContext()?.fill(rect)
    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return tintedImage!
  }
}

extension UIImage {
  func imageWithColor(_ color1: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
    
    let context = UIGraphicsGetCurrentContext()! as CGContext
    context.translateBy(x: 0, y: self.size.height)
    context.scaleBy(x: 1.0, y: -1.0);
    context.setBlendMode(CGBlendMode.normal)
    
    let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
    context.clip(to: rect, mask: self.cgImage!)
    color1.setFill()
    context.fill(rect)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
    UIGraphicsEndImageContext()
    
    return newImage
  }
}

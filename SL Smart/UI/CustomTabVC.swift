//
//  CustomTabVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class CustomTabVC: UITabBarController {
  
  override func viewDidLoad() {
    for item in self.tabBar.items! as [UITabBarItem] {
      if let image = item.image {
        item.image = image.imageWithColor(UIColor(white: 0.0, alpha: 0.75)).imageWithRenderingMode(.AlwaysOriginal)
      }
    }
  }
}
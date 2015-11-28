//
//  StandardGradient.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-25.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class StandardGradient {
  static let colorTop = UIColor(
    red: 232/255.0, green: 236/255.0, blue: 224/255.0, alpha: 1.0)
  static let colorBottom = UIColor(
    red: 242/255.0, green: 244/255.0, blue: 236/255.0, alpha: 1.0)
  
  /**
   * Adds a gradient background layer.
   */
  static func addLayer(view: UIView) {
    let gl = CAGradientLayer()
    gl.colors = [StandardGradient.colorTop.CGColor, StandardGradient.colorBottom.CGColor]
    gl.locations = [0.0, 1.0]
    gl.frame = view.bounds
    gl.startPoint = CGPoint(x: 0.0, y: 0.0)
    gl.endPoint = CGPoint(x: 1.0, y: 1.0)
    
    view.layer.insertSublayer(gl, atIndex: 0)
  }
}
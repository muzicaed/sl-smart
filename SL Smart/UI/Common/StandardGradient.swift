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
  static private let colorTop = UIColor(
    red: 200/255.0, green: 219/255.0, blue: 153/255.0, alpha: 1.0).CGColor
  static private let colorBottom = UIColor(
    red: 173/255.0, green: 198/255.0, blue: 111/255.0, alpha: 1.0).CGColor
  
  /**
   * Adds a gradient background layer.
   */
  static func addLayer(view: UIView) {
    let gl = CAGradientLayer()
    gl.colors = [StandardGradient.colorTop, StandardGradient.colorBottom]
    gl.locations = [0.0, 1.0]
    gl.frame = view.bounds
    gl.startPoint = CGPoint(x: 0.0, y: 0.0)
    gl.endPoint = CGPoint(x: 1.0, y: 1.0)
    
    view.layer.insertSublayer(gl, atIndex: 0)
  }
}
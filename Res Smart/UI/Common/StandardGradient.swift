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
        red: 211/255.0, green: 235/255.0, blue: 227/255.0, alpha: 1.0)
    static let colorBottom = UIColor(
        red: 228/255.0, green: 240/255.0, blue: 211/255.0, alpha: 1.0)
    
    /**
     * Adds a gradient background layer.
     */
    static func addLayer(_ view: UIView) {
        let gl = CAGradientLayer()
        gl.colors = [StandardGradient.colorTop.cgColor, StandardGradient.colorBottom.cgColor]
        gl.locations = [0.0, 1.0]
        gl.frame = view.bounds
        gl.startPoint = CGPoint(x: 0.5, y: 0.0)
        gl.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        view.layer.insertSublayer(gl, at: 0)
    }
}

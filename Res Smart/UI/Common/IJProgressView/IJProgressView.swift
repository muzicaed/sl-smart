//
//  IJProgressView.swift
//  IJProgressView
//
//  Created by Isuru Nanayakkara on 1/14/15.
//  Copyright (c) 2015 Appex. All rights reserved.
//

import UIKit

open class IJProgressView {
    
    var containerView = UIView()
    var progressView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var isDisplayed  = false
    
    open class var shared: IJProgressView {
        struct Static {
            static let instance: IJProgressView = IJProgressView()
        }
        return Static.instance
    }
    
    open func showProgressView(_ view: UIView) {
        if (!isDisplayed) {
            isDisplayed = true
            containerView.frame = view.frame
            containerView.center = view.center
            containerView.isUserInteractionEnabled = true
            containerView.alpha = 0.0
            
            progressView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            progressView.center = view.center
            progressView.clipsToBounds = true
            progressView.layer.cornerRadius = 10
            progressView.isUserInteractionEnabled = false
            let blurEffect = UIBlurEffect(style: .dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = progressView.bounds
            progressView.addSubview(blurView)
            
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            activityIndicator.style = .whiteLarge
            activityIndicator.center = CGPoint(x: progressView.bounds.width / 2, y: progressView.bounds.height / 2)
            
            progressView.addSubview(activityIndicator)
            containerView.addSubview(progressView)
            view.addSubview(containerView)
            
            activityIndicator.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.containerView.alpha = 1.0
            })
        }
    }
    
    open func hideProgressView() {
        if (isDisplayed) {
            isDisplayed = false
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.containerView.alpha = 0.0
            }, completion: { (finished: Bool) -> Void in
                self.activityIndicator.stopAnimating()
                self.containerView.removeFromSuperview()
            })
        }
    }
}

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

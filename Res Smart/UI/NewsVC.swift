//
//  NewsVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-14.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class NewsVC: UIViewController {
  @IBAction func onCloseButton(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
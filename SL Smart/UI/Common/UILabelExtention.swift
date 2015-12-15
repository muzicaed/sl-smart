//
//  UILabelExtention.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-15.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
  
  func boldRange(range: Range<String.Index>) {
    if let text = self.attributedText {
      let attr = NSMutableAttributedString(attributedString: text)
      let start = text.string.startIndex.distanceTo(range.startIndex)
      let length = range.startIndex.distanceTo(range.endIndex)
      attr.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(self.font.pointSize)], range: NSMakeRange(start, length))
      self.attributedText = attr
    }
  }
  
  func boldSubstring(substr: String) {
    let range = self.text?.rangeOfString(substr)
    if let r = range {
      boldRange(r)
    }
  }
}
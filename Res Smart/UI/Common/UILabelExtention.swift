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
  
  func boldRange(_ range: Range<String.Index>) {
    if let text = self.attributedText {
      let attr = NSMutableAttributedString(attributedString: text)
      let start = text.string.characters.distance(from: text.string.startIndex, to: range.lowerBound)
      let length = <#T##String.CharacterView corresponding to your index##String.CharacterView#>.distance(from: range.lowerBound, to: range.upperBound)
      attr.addAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: self.font.pointSize)], range: NSMakeRange(start, length))
      self.attributedText = attr
    }
  }
  
  func boldSubstring(_ substr: String) {
    let range = self.text?.range(of: substr)
    if let r = range {
      boldRange(r)
    }
  }
}

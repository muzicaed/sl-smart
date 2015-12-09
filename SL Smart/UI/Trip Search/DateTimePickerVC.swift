//
//  DateTimePickerVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-09.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class DateTimePickerVC: UIViewController {
  
  @IBOutlet weak var dateTimePicker: UIDatePicker!
  
  var delegate: DateTimePickResponder?
  var selectedDate: NSDate?
  
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    if let date = selectedDate {
      dateTimePicker.date = date
    }
  }
  
  /**
   * On close button tap
   */
  @IBAction func onCloseButtonTap(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
    
  }
  
  /**
   * On pick time button tap
   */
  @IBAction func onPickTimeButtonTap(sender: AnyObject) {
    delegate?.pickedDate(dateTimePicker.date)
    dismissViewControllerAnimated(true, completion: nil)
  }
}


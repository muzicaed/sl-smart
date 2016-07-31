//
//  TimePickerVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-07-16.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class TimePickerVC: UIViewController {
  
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
    delegate?.pickedDate(nil)
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

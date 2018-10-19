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
    var selectedDate: Date?
    
    
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
    @IBAction func onCloseButtonTap(_ sender: AnyObject) {
        delegate?.pickedDate(nil)
        dismiss(animated: true, completion: nil)
        
    }
    
    /**
     * On pick time button tap
     */
    @IBAction func onPickTimeButtonTap(_ sender: AnyObject) {
        delegate?.pickedDate(dateTimePicker.date)
        dismiss(animated: true, completion: nil)
    }
}


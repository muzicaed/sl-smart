//
//  LinePickerVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-05-08.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class LinePickerVC: UITableViewController {
  
  @IBOutlet weak var lineTypeSegmentedControl: UISegmentedControl!
  @IBOutlet weak var lineTextField: UITextField!
  
  var delegate: LinePickerResponder?
  
  var incText: String?
  var excText: String?
  var selectedSegment = 0
  
  /**
   * When view is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    if incText != nil {
      lineTextField.text = "\(incText!)"
      lineTypeSegmentedControl.selectedSegmentIndex = 1
      lineTextField.isEnabled = true
    } else if excText != nil {
      lineTextField.text = "\(excText!)"
      lineTypeSegmentedControl.selectedSegmentIndex = 2
      lineTextField.isEnabled = true
    }
    selectedSegment = lineTypeSegmentedControl.selectedSegmentIndex
  }
  
  /**
   * User changed line type segmented control
   */
  @IBAction func onLineTypeValueChanged(_ sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      lineTextField.isEnabled = false
      lineTextField.text = nil
      incText = nil
      excText = nil
    } else {
      lineTextField.isEnabled = true
    }
    selectedSegment = sender.selectedSegmentIndex
    updateIncExcTexts()
  }
  
  /**
   * User stoped editing line text field.
   */
  @IBAction func onLineTextFieldEditEnd(_ sender: UITextField) {
    updateIncExcTexts()
  }
  
  // MARK: UITableViewController
  
  override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  // MARK: Private
  
  /**
   * Updates included / excluded parameters.
   */
  fileprivate func updateIncExcTexts() {
    switch selectedSegment {
    case 1:
      incText = lineTextField.text
      excText = nil
    case 2:
      incText = nil
      excText = lineTextField.text
    default:
      incText = nil
      excText = nil
    }
    delegate?.pickedLines(incText, excluded: excText)
  }
}

//
//  GenericValuePickerVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-05-03.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class GenericValuePickerVC: UITableViewController {
  
  var delegate: PickGenericValueResponder?
  
  private var currentValue: Int?
  private var valueType: ValueType?
  private var values = [(value: Int, displayText: String)]()
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRectZero)
    values = generateValues()
  }
  
  /**
   * Sets the value and value type
   * for the picker to use.
   */
  func setValue(value: Int, valueType: ValueType) {
    self.valueType = valueType
    self.currentValue = value
  }
  
  // MARK: UITableViewController
  
  /**
   * Row count
   */
  override func tableView(
    tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return values.count
  }
  
  /**
   * Cell for index
   */
  override func tableView(
    tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let rowData = values[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(
      "WalkDistanceRow", forIndexPath: indexPath)
    cell.textLabel?.text = rowData.displayText
    
    cell.accessoryType = .None
    cell.selectionStyle = .None
    if rowData.value == currentValue {
      cell.accessoryType = .Checkmark
    }
    return cell
  }
  
  /**
   * User selects a row
   */
  override func tableView(
    tableView: UITableView,
    didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    currentValue = values[indexPath.row].value
    tableView.reloadData()
    if let del = delegate, valType = valueType {
      del.pickedValue(valType, value: values[indexPath.row].value)
    }
  }
  
  // MARK: Private
  
  private func generateValues() -> [(value: Int, displayText: String)] {
    if let type = valueType {
      switch type {
      case .WalkDistance:
        return [
          (200, "Högst 200 m"),
          (500, "Högst 500 m"),
          (1000, "Högst 1 km"),
          (2000, "Högst 2 km")
        ]
      case .NoOfChanges:
        return [
          (-1, "Inga begränsningar"),
          (0, "Inga byten"),
          (1, "Högst 1 byte"),
          (2, "Högst 2 byten"),
          (3, "Högst 3 byten")
        ]
      case .TimeForChange:
        return [
          (0, "Ingen extra tid vid byte"),
          (2, "2 minuter extra"),
          (5, "5 minuter extra"),
          (10, "10 minuter extra"),
          (15, "15 minuter extra")
        ]
      }
    }
    
    return []
  }
  
  /**
   * Value type enum
   */
  enum ValueType: String {
    case WalkDistance = "WALK_DISTANCE"
    case NoOfChanges = "NO_OF_CHANGES"
    case TimeForChange = "TIME_FOR_CHANGE"
  }
  
  //
}
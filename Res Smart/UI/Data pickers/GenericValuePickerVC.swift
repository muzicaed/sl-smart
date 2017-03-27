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
  
  fileprivate var currentValue: Int?
  fileprivate var valueType: ValueType?
  fileprivate var values = [(value: Int, displayText: String)]()
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    values = generateValues()
  }
  
  /**
   * Sets the value and value type
   * for the picker to use.
   */
  func setValue(_ value: Int, valueType: ValueType) {
    self.valueType = valueType
    self.currentValue = value
  }
  
  // MARK: UITableViewController
  
  /**
   * Row count
   */
  override func tableView(
    _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return values.count
  }
  
  /**
   * Cell for index
   */
  override func tableView(
    _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let rowData = values[indexPath.row]
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "WalkDistanceRow", for: indexPath)
    cell.textLabel?.text = rowData.displayText
    
    cell.accessoryType = .none
    cell.selectionStyle = .none
    if rowData.value == currentValue {
      cell.accessoryType = .checkmark
    }
    return cell
  }
  
  /**
   * User selects a row
   */
  override func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath) {
    
    currentValue = values[indexPath.row].value
    tableView.reloadData()
    if let del = delegate, let valType = valueType {
      del.pickedValue(valType, value: values[indexPath.row].value)
    }
  }
  
  // MARK: Private
  
  fileprivate func generateValues() -> [(value: Int, displayText: String)] {
    if let type = valueType {
      switch type {
      case .WalkDistance:
        return [
          (100, "Högst 100 m".localized),
          (250, "Högst 250 m".localized),
          (500, "Högst 500 m".localized),
          (1000, "Högst 1 km".localized),
          (2000, "Högst 2 km".localized)
        ]
      case .NoOfChanges:
        return [
          (-1, "Inga begränsningar".localized),
          (0, "Inga byten".localized),
          (1, "Högst 1 byte".localized),
          (2, "Högst 2 byten".localized),
          (3, "Högst 3 byten".localized)
        ]
      case .TimeForChange:
        return [
          (0, "Ingen extra tid vid byte".localized),
          (2, "2 minuter extra".localized),
          (5, "5 minuter extra".localized),
          (10, "10 minuter extra".localized),
          (15, "15 minuter extra".localized)
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

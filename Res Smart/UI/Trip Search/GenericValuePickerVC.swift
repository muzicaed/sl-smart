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
  
  var valueType: ValueType?
  var values = [(value: Int, displayText: String)]()
  var delegate: PickGenericValueResponder?
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRectZero)
    values = generateValues()
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
    return cell
  }
  
  /**
   * User selects a row
   */
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if let del = delegate, val = valueType {
      del.pickedValue(val, value: values[indexPath.row].value)
    }
    performSegueWithIdentifier("unwindToGenericValuePickerParent", sender: self)
  }
  
  /**
   * Green highlight on selected row.
   */
  override func tableView(
    tableView: UITableView, willDisplayCell cell: UITableViewCell,
    forRowAtIndexPath indexPath: NSIndexPath) {
    
    let bgColorView = UIView()
    bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
    cell.selectedBackgroundView = bgColorView
  }
  
  // MARK: Private
  
  private func generateValues() -> [(value: Int, displayText: String)] {
    if let type = valueType {
      switch type {
      case .WalkDistance:
        return [
          (200, "200 m"),
          (500, "500 m"),
          (1000, "1 km"),
          (2000, "2 km")
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
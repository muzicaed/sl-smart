//
//  TravelTypesVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-14.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class TravelTypesVC: UITableViewController {
  
  var delegate: TravelTypesResponder?
  private var checkArr = [false, true, false, true, false]
  private let titels = ["Tunnelbana", "Pendeltåg", "Lokalbana/Spårvagn", "Bussar", "Båtar"]
  
  /**
   * Set initial data.
   */
  func setData(criterions: TripSearchCriterion) {
    checkArr = [
      criterions.useMetro,
      criterions.useTrain,
      criterions.useTram,
      criterions.useBus,
      criterions.useFerry
    ]
  }
  
  // MARK: UITableViewController
  
  /**
  * Number of rows for section
  */
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  /**
   * Cells for rows
   */
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(
      "TripTypeRow", forIndexPath: indexPath)
    
    if checkArr[indexPath.row] {
      cell.accessoryType = .Checkmark
    } else {
      cell.accessoryType = .None
    }
  
    cell.selectionStyle = .None
    cell.textLabel?.text = titels[indexPath.row]    
    return cell
  }
  
  /**
   * User selects a row
   */
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    checkArr[indexPath.row] = !checkArr[indexPath.row]
    delegate?.selectedTravelType(
      checkArr[0], useTrain: checkArr[1],
      useTram: checkArr[2], useBus: checkArr[3],
      useBoat: checkArr[4])
    tableView.reloadData()
  }
  
  /**
   * Green highlight on selected row.
   */
  override func tableView(tableView: UITableView,
    willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      let bgColorView = UIView()
      bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
      cell.selectedBackgroundView = bgColorView
  }
}

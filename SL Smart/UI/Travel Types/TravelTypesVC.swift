//
//  TravelTypesVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-14.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class TravelTypesVC: UITableViewController {
  
  var checkArr = [false, true, false, true, false]
  var titels = ["Tunnelbana", "Pendeltåg", "Lokalbana", "Bussar", "Båtar"]
  
  // MARK: UITableViewController
  
  /**
  * Number of rows for section
  */
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(
      "TripTypeRow", forIndexPath: indexPath)
    
    if checkArr[indexPath.row] {
      cell.accessoryType = .Checkmark
    } else {
      cell.accessoryType = .None
    }
    
    cell.textLabel?.text = titels[indexPath.row]    
    return cell
  }
}

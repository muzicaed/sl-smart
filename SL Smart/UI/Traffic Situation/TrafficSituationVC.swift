//
//  TrafficSituationVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-10.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class TrafficSituationVC: UITableViewController {
  
  var situationGroups = [SituationGroup]()
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    loadData()
  }
  
  
  // MARK: UITableViewController
  
  /**
  * Number of sections
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return situationGroups.count
  }
  
  /**
   * Number of rows in a section
   */
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if situationGroups.count == 0 {
      return 1
    }
    return situationGroups[section].situations.count + 1
  }
  
  /**
   * Cell for index.
   */
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCellWithIdentifier(
          "SituationHeader", forIndexPath: indexPath) as! SituationHeader
        cell.setupData(situationGroups[indexPath.section])
        return cell
      }
      
      let cell = tableView.dequeueReusableCellWithIdentifier(
        "SituationRow", forIndexPath: indexPath) as! SituationRow
      cell.setupData(situationGroups[indexPath.section].situations[indexPath.row - 1])
      return cell
  }
  
  /**
   * Before displaying cell
   */
  override func tableView(tableView: UITableView,
    willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      cell.layoutMargins = UIEdgeInsetsZero
      cell.preservesSuperviewLayoutMargins = false
  }
  
  // MARK: Private
  
  private func setupTableView() {
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 130
  }
  
  
  /**
   * Loads traffic situation data.
   */
  private func loadData() {
    if situationGroups.count == 0 {
      print("search data")
      TrafficSituationService.fetchInformation() {data, error in
        dispatch_async(dispatch_get_main_queue()) {
          print("got data")
          if error != nil {
            // TODO: Better error handeling here
            fatalError("ERROR!!")
          }
          
          self.situationGroups = data
          self.tableView.reloadData()
        }
      }
    }
    
  }
}
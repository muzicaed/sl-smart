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
  var lastUpdated = NSDate(timeIntervalSince1970: NSTimeInterval(0.0))
  let refreshController = UIRefreshControl()
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    refreshController.addTarget(self, action: Selector("loadData"), forControlEvents: UIControlEvents.ValueChanged)
    refreshController.tintColor = UIColor.lightGrayColor()
    tableView.addSubview(refreshController)
    tableView.alwaysBounceVertical = true
  }
  
  /**
   * View did to appear
   */
  override func viewDidAppear(animated: Bool) {
    super.viewWillAppear(animated)
    loadData()
  }
  
  // MARK: UITableViewController
  
  /**
  * Number of sections
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if situationGroups.count > 0 {
      return situationGroups.count
    }
    return 0
  }
  
  /**
   * Number of rows in a section
   */
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count = 2
    let group = situationGroups[section]
    count += group.situations.count
    return count
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
      
      // TODO: Refactoring here...

      let cell = tableView.dequeueReusableCellWithIdentifier(
        "SituationRow", forIndexPath: indexPath) as! SituationRow
      
      let group = situationGroups[indexPath.section]
      var message = ""
      if group.plannedSituations.count > 0 {
        if group.plannedSituations.count == 1 {
          message = "\(group.plannedSituations.count) plannerad störning."
        } else {
          message = "\(group.plannedSituations.count) plannerade störningar."
        }
        message += (group.deviations.count > 0) ? "\n" : ""
      }
      if group.deviations.count > 0 {
        if group.deviations.count == 1 {
          message += "\(group.deviations.count) mindre avvikelse."
        } else {
          message += "\(group.deviations.count) mindre avvikelser."
        }
      }
      
      if group.deviations.count == 0 && group.plannedSituations.count == 0 && group.situations.count == 0 {
        message = "Inga störningar."
        cell.accessoryType = .None
      }
      
      cell.messageLabel.text = message
      return cell
  }
  
  /**
   * Before displaying cell
   */
  override func tableView(tableView: UITableView,
    willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      if indexPath.row == 0 {
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
      } else {
        cell.layoutMargins = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 0)
      }
      let bgColorView = UIView()
      bgColorView.backgroundColor = StyleHelper.sharedInstance.mainGreenLight
      cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * User selected row
   */
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == situationGroups.count {
      performSegueWithIdentifier("ShowReports", sender: nil)
    }
  }
  
  // MARK: Private
  
  private func setupView() {
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 130
  }
  
  /**
   * Loads traffic situation data.
   */
  func loadData() {
    if shouldReload() {
      NetworkActivity.displayActivityIndicator(true)
      TrafficSituationService.fetchInformation() {data, error in
        NetworkActivity.displayActivityIndicator(false)
        dispatch_async(dispatch_get_main_queue()) {
          if error != nil {
            return
          }
          
          self.lastUpdated = NSDate()
          self.situationGroups = data
          self.refreshController.endRefreshing()
          self.tableView.reloadData()
        }
      }
    }
    else {
      self.refreshController.endRefreshing()
    }
  }
  
  /**
   * Checks if data should be reloaded.
   */
  private func shouldReload() -> Bool {
    return situationGroups.count == 0 || (NSDate().timeIntervalSinceDate(lastUpdated) > 60)
  }
}
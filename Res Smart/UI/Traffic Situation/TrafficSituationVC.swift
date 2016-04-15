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
  var selectedGroup: SituationGroup?
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
  
  /**
   * Prepares for segue
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowReports" {
      let vc = segue.destinationViewController as! ReportsVC
      if let group = selectedGroup {
        vc.title = group.name
        vc.situations = group.plannedSituations
        vc.deviations = group.deviations
      }
    } else if segue.identifier == "ShowBusFilter" {
      let vc = segue.destinationViewController as! BusFilterVC
      if let group = selectedGroup {
        vc.title = group.name
        vc.deviations = group.deviations
        vc.situations = group.plannedSituations
      }
    }
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
        return createHeaderCell(indexPath)
      }
      
      if (indexPath.row - 1) < situationGroups[indexPath.section].situations.count {
        return createSituationCell(indexPath)
      }
      return createSummaryCell(indexPath)
  }
  
  /**
   * Before displaying cell
   */
  override func tableView(tableView: UITableView,
    willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      let bgColorView = UIView()
      bgColorView.backgroundColor = StyleHelper.sharedInstance.mainGreenLight
      cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * User selected row
   */
  override func tableView(tableView: UITableView,
    didSelectRowAtIndexPath indexPath: NSIndexPath) {
      selectedGroup = situationGroups[indexPath.section]
      if selectedGroup?.tripType == TripType.Bus {
        performSegueWithIdentifier("ShowBusFilter", sender: nil)
        return
      }
      performSegueWithIdentifier("ShowReports", sender: nil)
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
  
  /**
   * Creates a header row
   */
  private func createHeaderCell(indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(
      "SituationHeader", forIndexPath: indexPath) as! SituationHeader
    cell.setupData(situationGroups[indexPath.section])
    return cell
  }
  
  /**
   * Creates a unplanned situation row
   */
  private func createSituationCell(indexPath: NSIndexPath) -> UITableViewCell {
    let situation = situationGroups[indexPath.section].situations[indexPath.row - 1]
    let cell = tableView.dequeueReusableCellWithIdentifier(
      "SituationRow", forIndexPath: indexPath) as! SituationRow
    
    cell.messageLabel.text = situation.message
    cell.messageLabel.textColor = UIColor(red: 232/255, green: 22/255, blue: 34/255, alpha: 1.0)
    cell.accessoryType = .None
    cell.userInteractionEnabled = false
    return cell
  }
  
  /**
   * Creates a situation summary row
   */
  private func createSummaryCell(indexPath: NSIndexPath) -> UITableViewCell {
    let group = situationGroups[indexPath.section]
    let cell = tableView.dequeueReusableCellWithIdentifier(
      "SituationRow", forIndexPath: indexPath) as! SituationRow
    
    if group.deviations.count == 0 && group.plannedSituations.count == 0 && group.situations.count == 0 {
      cell.messageLabel.text = "Inga störningar."
      cell.accessoryType = .None
      cell.userInteractionEnabled = false
      return cell
    }
    
    var message = ""
    if group.plannedSituations.count > 0 {
      if group.plannedSituations.count == 1 {
        message = "\(group.plannedSituations.count) planerad störning."
      } else {
        message = "\(group.plannedSituations.count) planerade störningar."
      }
      message += (group.deviations.count > 0) ? "\n" : ""
    }
    if group.deviations.count > 0 {
      if group.deviations.count == 1 {
        message += "\(group.deviations.count) lokal avvikelse."
      } else {
        message += "\(group.deviations.count) lokala avvikelser."
      }
    }
    
    cell.messageLabel.text = message
    cell.userInteractionEnabled = true
    cell.accessoryType = .DisclosureIndicator
    cell.messageLabel.textColor = UIColor.darkGrayColor()
    return cell
  }
}
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
  var filteredSituationGroups = [SituationGroup]()
  var showPlanned = false
  var lastUpdated = NSDate(timeIntervalSince1970: NSTimeInterval(0.0))
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  /** 
   * View did to appear
   */
  override func viewDidAppear(animated: Bool) {
    super.viewWillAppear(animated)
    let items = self.tabBarController?.tabBar.items!
    items![2].badgeValue = nil
    loadData()
  }
  
  /**
   * Toggle show planned situations
   */
  @IBAction func onTogglePlannedButtonTap(sender: UIBarButtonItem) {
    if showPlanned {
      sender.title = "Visa planerade"
    } else {
      sender.title = "Dölj planerade"
    }
    showPlanned = !showPlanned
    
    var indexPaths = [NSIndexPath]()
    for (index, group) in situationGroups.enumerate() {
      let diff = group.situations.count - filteredSituationGroups[index].situations.count
      if diff > 0 {
        for i in 1...diff {
          indexPaths.append(NSIndexPath(forItem: i, inSection: index))
        }
      }
    }
    
    tableView.beginUpdates()
    if showPlanned {
      tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    } else {
      tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
    tableView.endUpdates()
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
    } else if showPlanned {
      return situationGroups[section].situations.count + 1
    }
    
    return situationGroups[section].countSituationsExclPlanned() + 1
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
      
      var data: Situation?
      if showPlanned {
        data = situationGroups[indexPath.section].situations[indexPath.row - 1]
      } else {
        data = filteredSituationGroups[indexPath.section].situations[indexPath.row - 1]
      }
      let cell = tableView.dequeueReusableCellWithIdentifier(
        "SituationRow", forIndexPath: indexPath) as! SituationRow
      cell.setupData(data!)
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
  private func loadData() {
    if shouldReload() {
      print("Reload!")
      TrafficSituationService.fetchInformation() {data, error in
        dispatch_async(dispatch_get_main_queue()) {
          if error != nil {
            // TODO: Better error handeling here
            fatalError("ERROR!!")
          }
          
          self.lastUpdated = NSDate()
          self.situationGroups = data
          self.filteredSituationGroups = self.filterSituationsOnPlanned(data)
          self.tableView.reloadData()
        }
      }
    }
  }
  
  /**
   * Checks if data should be reloaded.
   */
  private func shouldReload() -> Bool {
    return situationGroups.count == 0 || (NSDate().timeIntervalSinceDate(lastUpdated) > 60)
  }
  
  /**
   * Filter situations on planned or not.
   */
  private func filterSituationsOnPlanned(
    situationGroups: [SituationGroup]) -> [SituationGroup] {
      
      var filtredGroups = [SituationGroup]()
      for group in situationGroups {
        let filterGroup = SituationGroup(
          statusIcon: group.statusIcon, hasPlannedEvent: group.hasPlannedEvent,
          name: group.name, tripType: group.type,
          situations: filterSituations(group.situations))
        filtredGroups.append(filterGroup)
      }
      
      return filtredGroups
  }
  
  /**
   * Filter situations on planned or not.
   */
  private func filterSituations(
    situations: [Situation]) -> [Situation] {
      
      var filtredSituations = [Situation]()
      for situation in situations {
        if !situation.planned {
          filtredSituations.append(situation)
        }
      }
      
      return filtredSituations
  }
}
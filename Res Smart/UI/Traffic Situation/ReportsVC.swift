//
//  ReportsVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-03-20.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class ReportsVC: UITableViewController {
  
  var situationGroup: SituationGroup?
  var selectedDeviation: Deviation?
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    tableView.alwaysBounceVertical = true
  }
  
  /**
   * Prepares for segue
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowDeviation" {
      let vc = segue.destinationViewController as! DeviationVC
      if let deviation = selectedDeviation {
        vc.deviation = deviation
      }
    }
  }
  
  // MARK: UITableViewController
  
  /**
  * Number of sections
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if isBothSituationsAndDeviations() {
      return 2
    }
    return 1
  }
  
  /**
   * Item count for section
   */
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      if let group = situationGroup {
        if isBothSituationsAndDeviations() {
          return (section == 0) ? group.plannedSituations.count : group.deviations.count
        } else if group.plannedSituations.count > 0 {
          return group.plannedSituations.count
        }
        return group.deviations.count
      }
      return 0
  }
  
  /**
   * Cell for index.
   */
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      if let group = situationGroup {
        if isBothSituationsAndDeviations() {
          return (indexPath.section == 0) ? createSituationCell(indexPath) : createDeviationCell(indexPath)
        } else if group.plannedSituations.count > 0 {
          return createSituationCell(indexPath)
        }
        return createDeviationCell(indexPath)
      }
      return UITableViewCell()
  }
  
  /**
   * View for header
   */
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 25))
    let label = UILabel(frame: CGRectMake(10, 0, tableView.frame.size.width - 10, 25))
    label.font = UIFont.systemFontOfSize(12)
    label.textColor = UIColor.whiteColor()
    label.text = createHeaderTitle(section)
    view.addSubview(label)
    
    let color = StyleHelper.sharedInstance.mainGreen
    view.backgroundColor = color.colorWithAlphaComponent(0.95)
    return view
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
      selectedDeviation = situationGroup!.deviations[indexPath.row]
      performSegueWithIdentifier("ShowDeviation", sender: nil)
  }
  
  // MARK: Private
  
  /**
  * Create the header title.
  */
  private func createHeaderTitle(section: Int) -> String {
    if let group = situationGroup {
      if isBothSituationsAndDeviations() {
        return (section == 0) ? "Plannerade störningar" : "Lokala avvikelser"
      } else {
        return (group.plannedSituations.count > 0) ? "Plannerade störningar" : "Lokala avvikelser"
      }
    }
    return ""
  }
  
  /**
   * Setup view properties
   */
  private func setupView() {
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 130
  }
  
  /**
   * Checks if there is both situations and deviations.
   */
  private func isBothSituationsAndDeviations() -> Bool {
    return (situationGroup!.plannedSituations.count > 0 && situationGroup!.deviations.count > 0)
  }
  
  /**
   * Create a situation row
   */
  private func createSituationCell(indexPath: NSIndexPath) -> UITableViewCell {
    let situation = situationGroup!.plannedSituations[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(
      "SituationRow", forIndexPath: indexPath) as! ReportSituationRow
    cell.titleLabel.text = situation.trafficLine
    cell.messageLabel.text = situation.message
    return cell
  }
  
  /**
   * Create a deviation row
   */
  private func createDeviationCell(indexPath: NSIndexPath) -> UITableViewCell {
    let deviation = situationGroup!.deviations[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(
      "DeviationRow", forIndexPath: indexPath) as! ReportDeviationRow
    cell.titleLabel.text = deviation.scope
    cell.messageLabel.text = deviation.title
    cell.dateLabel.text = "Gäller från: " + DateUtils.friendlyDateAndTime(deviation.fromDate)
    return cell
  }
}
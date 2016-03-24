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
  
  var situations = [Situation]()
  var deviations = [Deviation]()
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
      if isBothSituationsAndDeviations() {
        return (section == 0) ? situations.count : deviations.count
      } else if situations.count > 0 {
        return situations.count
      }
      return deviations.count
  }
  
  /**
   * Cell for index.
   */
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
      if isBothSituationsAndDeviations() {
        return (indexPath.section == 0) ? createSituationCell(indexPath) : createDeviationCell(indexPath)
      } else if situations.count > 0 {
        return createSituationCell(indexPath)
      }
      return createDeviationCell(indexPath)
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
      selectedDeviation = deviations[indexPath.row]
      performSegueWithIdentifier("ShowDeviation", sender: nil)
  }
  
  // MARK: Private
  
  /**
  * Create the header title.
  */
  private func createHeaderTitle(section: Int) -> String {
    if isBothSituationsAndDeviations() {
      return (section == 0) ? "Planerade störningar" : "Lokala avvikelser"
    } else {
      return (situations.count > 0) ? "Planerade störningar" : "Lokala avvikelser"
    }
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
    return (situations.count > 0 && deviations.count > 0)
  }
  
  /**
   * Create a situation row
   */
  private func createSituationCell(indexPath: NSIndexPath) -> UITableViewCell {
    let situation = situations[indexPath.row]
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
    let deviation = deviations[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(
      "DeviationRow", forIndexPath: indexPath) as! ReportDeviationRow
    cell.titleLabel.text = deviation.scope
    cell.messageLabel.text = deviation.title
    cell.dateLabel.text = "Gäller från: " + DateUtils.friendlyDateAndTime(deviation.fromDate)
    return cell
  }
}
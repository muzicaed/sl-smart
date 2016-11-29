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
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowDeviation" {
      let vc = segue.destination as! DeviationVC
      if let deviation = selectedDeviation {
        vc.deviation = deviation
      }
    }
  }
  
  // MARK: UITableViewController
  
  /**
  * Number of sections
  */
  override func numberOfSections(in tableView: UITableView) -> Int {
    if isBothSituationsAndDeviations() {
      return 2
    }
    return 1
  }
  
  /**
   * Item count for section
   */
  override func tableView(_ tableView: UITableView,
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
  override func tableView(_ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
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
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
    let label = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.frame.size.width - 10, height: 25))
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = UIColor.white
    label.text = createHeaderTitle(section)
    view.addSubview(label)
    
    let color = StyleHelper.sharedInstance.mainGreen
    view.backgroundColor = color.withAlphaComponent(0.95)
    return view
  }
  
  /**
   * Before displaying cell
   */
  override func tableView(_ tableView: UITableView,
    willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      let bgColorView = UIView()
      bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
      cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * User selected row
   */
  override func tableView(_ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath) {
      selectedDeviation = deviations[indexPath.row]
      performSegue(withIdentifier: "ShowDeviation", sender: nil)
  }
  
  // MARK: Private
  
  /**
  * Create the header title.
  */
  fileprivate func createHeaderTitle(_ section: Int) -> String {
    if isBothSituationsAndDeviations() {
      return (section == 0) ? "Planerade störningar" : "Lokala avvikelser"
    } else {
      return (situations.count > 0) ? "Planerade störningar" : "Lokala avvikelser"
    }
  }
  
  /**
   * Setup view properties
   */
  fileprivate func setupView() {
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.separatorInset = UIEdgeInsets.zero
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 130
  }
  
  /**
   * Checks if there is both situations and deviations.
   */
  fileprivate func isBothSituationsAndDeviations() -> Bool {
    return (situations.count > 0 && deviations.count > 0)
  }
  
  /**
   * Create a situation row
   */
  fileprivate func createSituationCell(_ indexPath: IndexPath) -> UITableViewCell {
    let situation = situations[indexPath.row]
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "SituationRow", for: indexPath) as! ReportSituationRow
    cell.titleLabel.text = situation.trafficLine
    cell.messageLabel.text = situation.message
    return cell
  }
  
  /**
   * Create a deviation row
   */
  fileprivate func createDeviationCell(_ indexPath: IndexPath) -> UITableViewCell {
    let deviation = deviations[indexPath.row]
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "DeviationRow", for: indexPath) as! ReportDeviationRow
    cell.titleLabel.text = deviation.scope
    cell.messageLabel.text = deviation.title
    cell.dateLabel.text = "Gäller från: " + DateUtils.friendlyDateAndTime(deviation.fromDate)
    return cell
  }
}

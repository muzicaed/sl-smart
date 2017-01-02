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
  var lastUpdated = Date(timeIntervalSince1970: TimeInterval(0.0))
  let refreshController = UIRefreshControl()
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    refreshController.addTarget(
      self, action: #selector(loadData), for: UIControlEvents.valueChanged)
    refreshController.tintColor = UIColor.lightGray
    tableView.addSubview(refreshController)
    tableView.alwaysBounceVertical = true
  }
  
  /**
   * View did to appear
   */
  override func viewDidAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    loadData()
  }
  
  /**
   * Prepares for segue
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowReports" {
      let vc = segue.destination as! ReportsVC
      if let group = selectedGroup {
        vc.title = group.name
        vc.situations = group.plannedSituations
        vc.deviations = group.deviations
      }
    } else if segue.identifier == "ShowBusFilter" {
      let vc = segue.destination as! BusFilterVC
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
  override func numberOfSections(in tableView: UITableView) -> Int {
    if situationGroups.count > 0 {
      return situationGroups.count
    }
    return 0
  }
  
  /**
   * Number of rows in a section
   */
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var count = 2
    let group = situationGroups[section]
    count += group.situations.count
    return count
  }
  
  /**
   * Cell for index.
   */
  override func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
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
  override func tableView(
    _ tableView: UITableView, willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath) {
    
    let bgColorView = UIView()
    bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
    cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * User selected row
   */
  override func tableView(
    _ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    selectedGroup = situationGroups[indexPath.section]
    if selectedGroup?.tripType == TripType.Bus {
      performSegue(withIdentifier: "ShowBusFilter", sender: nil)
      return
    }
    performSegue(withIdentifier: "ShowReports", sender: nil)
  }
  
  // MARK: Private
  
  fileprivate func setupView() {
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.separatorInset = UIEdgeInsets.zero
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
        DispatchQueue.main.async {
          if error != nil {
            return
          }
          
          self.lastUpdated = Date()
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
  fileprivate func shouldReload() -> Bool {
    return situationGroups.count == 0 || (Date().timeIntervalSince(lastUpdated) > 60)
  }
  
  /**
   * Creates a header row
   */
  fileprivate func createHeaderCell(_ indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "SituationHeader", for: indexPath) as! SituationHeader
    cell.setupData(situationGroups[indexPath.section])
    return cell
  }
  
  /**
   * Creates a unplanned situation row
   */
  fileprivate func createSituationCell(_ indexPath: IndexPath) -> UITableViewCell {
    let situation = situationGroups[indexPath.section].situations[indexPath.row - 1]
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "SituationRow", for: indexPath) as! SituationRow
    
    cell.messageLabel.text = situation.message
    cell.messageLabel.accessibilityLabel = "Trafikstörning: " + situation.message
    cell.messageLabel.textColor = StyleHelper.sharedInstance.warningColor
    cell.accessoryType = .none
    cell.isUserInteractionEnabled = false
    cell.setData(situation)
    return cell
  }
  
  /**
   * Creates a situation summary row
   */
  fileprivate func createSummaryCell(_ indexPath: IndexPath) -> UITableViewCell {
    let group = situationGroups[indexPath.section]
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "SituationRow", for: indexPath) as! SituationRow
    
    if group.deviations.count == 0 && group.plannedSituations.count == 0 {
      cell.messageLabel.text = "Inga störningar."
      if group.situations.count != 0 {
        cell.messageLabel.text = "Inga övriga störningar."
      }
      
      cell.accessoryType = .none
      cell.isUserInteractionEnabled = false
      cell.messageLabel.textColor = UIColor.darkGray
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
    cell.isUserInteractionEnabled = true
    cell.accessoryType = .disclosureIndicator
    cell.messageLabel.textColor = UIColor.darkGray
    return cell
  }
}

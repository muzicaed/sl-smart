//
//  BusFilterVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-03-21.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class BusFilterVC: UITableViewController {
  
  var deviations = [Deviation]()
  var situations = [Situation]()
  var organisedDeviations = Dictionary<String, [Deviation]>()
  var sortedKeys = [String]()
  var selectedKey: String?
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    tableView.alwaysBounceVertical = true
    prepareData()
  }
  
  /**
   * Prepares for segue
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowReports" {
      let vc = segue.destination as! ReportsVC
      if let dictKey = selectedKey {
        vc.deviations = organisedDeviations[dictKey]!
      }
    }
  }
  
  // MARK: UITableViewController
  
  /**
   * Number of sections
   */
  override func numberOfSections(in tableView: UITableView) -> Int {
    return (deviations.count > 0 && situations.count > 0) ? 2 : 1
  }
  
  /**
   * Item count for section
   */
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if hasBothDeviationsAndSituations() {
      if section == 0 {
        return situations.count
      }
      return sortedKeys.count
    }
    
    return (situations.count > 0) ? situations.count : sortedKeys.count
  }
  
  /**
   * Cell for index.
   */
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if hasBothDeviationsAndSituations() {
      if indexPath.section == 0 {
        return createSituationRow(indexPath)
      }
      return createDeviationRow(indexPath)
    }
    
    return (situations.count > 0) ? createSituationRow(indexPath) : createDeviationRow(indexPath)
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
    selectedKey = sortedKeys[indexPath.row]
    performSegue(withIdentifier: "ShowReports", sender: nil)
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
  
  // MARK: Private
  
  /**
   * Prepares the data for bus filter
   */
  fileprivate func prepareData() {
    for deviation in deviations {
      organiseDeviation(deviation)
    }
    sortedKeys = Array(organisedDeviations.keys).sorted() {
      if $0 == "STOPS" || $1 == "STOPS" {
        return $0 == "STOPS"
      }
      if $0.characters.count != $1.characters.count {
        return $0.characters.count < $1.characters.count
      }
      return $0 < $1
    }
  }
  
  /**
   * Organise deviation
   */
  fileprivate func organiseDeviation(_ deviation: Deviation) {
    if isBusDeviation(deviation) {
      let lines = extractLines(deviation)
      for line in lines {
        addToOrganised(line, deviation: deviation)
      }
      return
    }
    
    addToOrganised("STOPS", deviation: deviation)
  }
  
  /**
   * Check if deviation is about bus.
   * (else about station/stop)
   */
  fileprivate func isBusDeviation(_ deviation: Deviation) -> Bool {
    return deviation.scope.lowercased().range(of: "bus") != nil ||
      deviation.scope.lowercased().range(of: "närtrafiken") != nil ||
      deviation.scope.lowercased().range(of: "blå") != nil
  }
  
  /**
   * Adds to organised dictionary on key.
   */
  fileprivate func addToOrganised(_ key: String, deviation: Deviation) {
    if organisedDeviations[key] == nil {
      organisedDeviations[key] = [Deviation]()
    }
    organisedDeviations[key]?.append(deviation)
  }
  
  /**
   * Extracts all line numbers from deviation scope.
   */
  fileprivate func extractLines(_ deviation: Deviation) -> [String] {
    var scope = deviation.scope.lowercased()
    scope = scope.replacingOccurrences(of: "buss", with: "")
    scope = scope.replacingOccurrences(of: "närtrafiken", with: "")
    scope = scope.replacingOccurrences(of: "blå", with: "")
    scope = scope.replacingOccurrences(of: ";", with: "")
    scope = scope.replacingOccurrences(of: " ", with: "")
    return scope.components(separatedBy: ",")
  }
  
  /**
   * Setup view properties
   */
  fileprivate func setupView() {
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.separatorInset = UIEdgeInsets.zero
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 130
  }
  
  /**
   * Creates a deviation row.
   */
  fileprivate func createDeviationRow(_ indexPath: IndexPath) -> UITableViewCell {
    let key = sortedKeys[indexPath.row]
    let deviations = organisedDeviations[key]
    let countText = (deviations!.count > 1) ? "\(deviations!.count) avikelser" : "1 avvikelse"
    
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "DeviationRow", for: indexPath)
    if key == "STOPS" {
      cell.textLabel?.text = "Avvikelser för hållplatser"
      cell.imageView?.image = nil
    } else {
      cell.textLabel?.text = "Linje \(key)"
      cell.imageView?.image = UIImage(named: "BUS-NEUTRAL")
    }
    
    cell.detailTextLabel?.text = countText
    return cell
  }
  
  /**
   * Creates a situation row.
   */
  fileprivate func createSituationRow(_ indexPath: IndexPath) -> UITableViewCell {
    let situation = situations[indexPath.row]
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "SituationRow", for: indexPath) as! ReportSituationRow
    cell.titleLabel.text = situation.trafficLine
    cell.messageLabel.text = situation.message
    return cell
  }
  
  /**
   * Check if both deviations and situations are present.
   */
  fileprivate func hasBothDeviationsAndSituations() -> Bool {
    return (deviations.count > 0 && situations.count > 0)
  }
  
  /**
   * Create the header title.
   */
  fileprivate func createHeaderTitle(_ section: Int) -> String {
    if hasBothDeviationsAndSituations() {
      return (section == 0) ? "Planerade störningar" : "Lokala avvikelser"
    } else {
      return (situations.count > 0) ? "Planerade störningar" : "Lokala avvikelser"
    }
  }
}

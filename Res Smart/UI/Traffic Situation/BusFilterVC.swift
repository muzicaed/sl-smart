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
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowReports" {
      let vc = segue.destinationViewController as! ReportsVC
      if let dictKey = selectedKey {
        vc.deviations = organisedDeviations[dictKey]!
      }
    }
  }
  
  // MARK: UITableViewController
  
  /**
  * Number of sections
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  /**
   * Item count for section
   */
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      return sortedKeys.count
  }
  
  /**
   * Cell for index.
   */
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let key = sortedKeys[indexPath.row]
      let deviations = organisedDeviations[key]
      let countText = (deviations!.count > 1) ? "\(deviations!.count) avikelser" : "1 avvikelse"
      
      let cell = tableView.dequeueReusableCellWithIdentifier(
        "DeviationRow", forIndexPath: indexPath)
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
      selectedKey = sortedKeys[indexPath.row]
      performSegueWithIdentifier("ShowReports", sender: nil)
  }
  
  // MARK: Private
  
  /**
  * Prepares the data for bus filter
  */
  private func prepareData() {
    for deviation in deviations {
      organiseDeviation(deviation)
    }
    sortedKeys = Array(organisedDeviations.keys).sort() {
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
  private func organiseDeviation(deviation: Deviation) {
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
  private func isBusDeviation(deviation: Deviation) -> Bool {
    return deviation.scope.lowercaseString.rangeOfString("bus") != nil ||
      deviation.scope.lowercaseString.rangeOfString("närtrafiken") != nil ||
      deviation.scope.lowercaseString.rangeOfString("blå") != nil
  }
  
  /**
   * Adds to organised dictionary on key.
   */
  private func addToOrganised(key: String, deviation: Deviation) {
    if organisedDeviations[key] == nil {
      organisedDeviations[key] = [Deviation]()
    }
    organisedDeviations[key]?.append(deviation)
  }
  
  /**
   * Extracts all line numbers from deviation scope.
   */
  private func extractLines(deviation: Deviation) -> [String] {
    var scope = deviation.scope.lowercaseString
    scope = scope.stringByReplacingOccurrencesOfString("buss", withString: "")
    scope = scope.stringByReplacingOccurrencesOfString("närtrafiken", withString: "")
    scope = scope.stringByReplacingOccurrencesOfString("blå", withString: "")
    scope = scope.stringByReplacingOccurrencesOfString(";", withString: "")
    scope = scope.stringByReplacingOccurrencesOfString(" ", withString: "")
    return scope.componentsSeparatedByString(",")
  }
  
  /**
   * Setup view properties
   */
  private func setupView() {
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.separatorInset = UIEdgeInsetsZero
  }
}
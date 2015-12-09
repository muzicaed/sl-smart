//
//  TripSearchVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class TripSearchVC: UITableViewController, StationSearchResponder, DateTimePickResponder {
  
  var isSearchingOriginStation = false
  var selectedDate = NSDate()
  let criterions = TripSearchCriterion(originId: 0, destId: 0)
  
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = StyleHelper.sharedInstance.background
    pickedDate(NSDate())
  }
  
  /**
   * Before seque is triggred.
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "SearchOriginStation" {
      isSearchingOriginStation = true
      let vc = segue.destinationViewController as! SearchLocationVC
      vc.delegate = self
    } else if segue.identifier == "SearchDestinationStation" {
      isSearchingOriginStation = false
      let vc = segue.destinationViewController as! SearchLocationVC
      vc.delegate = self
    } else if segue.identifier == "ShowTripList" {
      let vc = segue.destinationViewController as! TripListVC
      vc.criterions = criterions
    } else if segue.identifier == "ShowDateTimePicker" {
      let vc = segue.destinationViewController as! DateTimePickerVC
      vc.selectedDate = selectedDate
      vc.delegate = self
    }
  }
  
  @IBAction func unwindToStationSearchParent(segue: UIStoryboardSegue) {}
  
  // MARK: StationSearchResponder
  
  /**
  * Triggered whem station is selected on station search VC.
  */
  func selectedStationFromSearch(station: Station) {
    
    if isSearchingOriginStation {
      criterions.originId = station.siteId
      originLabel.text = station.name
    } else {
      criterions.destId = station.siteId
      destinationLabel.text = station.name
    }
  }
  
  // MARK: StationSearchResponder
  
  /**
  * Triggered whem date and time is picked
  */
  func pickedDate(date: NSDate) -> Void {
    let dateTimeTuple = DateUtils.dateAsStringTuple(date)
    criterions.date = dateTimeTuple.date
    criterions.time = dateTimeTuple.time
    timeLabel.text = DateUtils.friendlyDateAndTime(date)
    selectedDate = date
  }
  
  // MARK: UITableViewController
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    let bgColorView = UIView()
    bgColorView.backgroundColor = StyleHelper.sharedInstance.mainGreenLight
    cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * Deselect selected row.
   */
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}
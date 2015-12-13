//
//  TripSearchVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class TripSearchVC: UITableViewController, LocationSearchResponder, DateTimePickResponder {
  
  var searchLocationType: String?
  var selectedDate = NSDate()
  var criterions: TripSearchCriterion?
  var dimmer: UIView?
  var isViaSelected = false
  var isAdvancedMode = false
  
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var viaLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var destinationArrivalSegmented: UISegmentedControl!
  @IBOutlet weak var advancedToggleButton: UIBarButtonItem!
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.editing = true
    view.backgroundColor = StyleHelper.sharedInstance.background
    criterions = DataStore.sharedInstance.retrieveSearchCriterions()
    restoreUIFromCriterions()
    createDimmer()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if let crit = criterions {
      crit.searchForArrival = (destinationArrivalSegmented.selectedSegmentIndex == 1)
      let dateTimeTuple = DateUtils.dateAsStringTuple(selectedDate)
      crit.date = dateTimeTuple.date
      crit.time = dateTimeTuple.time
    }
  }
  
  /**
   * Before seque is triggred.
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "SearchOriginLocation" {
      let vc = segue.destinationViewController as! SearchLocationVC
      vc.delegate = self
      vc.searchOnlyForStations = false
      searchLocationType = "Origin"
      
    } else if segue.identifier == "SearchDestinationLocation" {
      let vc = segue.destinationViewController as! SearchLocationVC
      vc.delegate = self
      vc.searchOnlyForStations = false
      searchLocationType = "Destination"
      
    } else if segue.identifier == "SearchViaLocation" {
      let vc = segue.destinationViewController as! SearchLocationVC
      vc.delegate = self
      vc.searchOnlyForStations = true
      searchLocationType = "Via"
      
    } else if segue.identifier == "ShowTripList" {
      let vc = segue.destinationViewController as! TripListVC
      vc.criterions = criterions
      if let crit = criterions {
        DataStore.sharedInstance.writeLastSearchCriterions(crit)
      }
      
    } else if segue.identifier == "ShowDateTimePicker" {
      let vc = segue.destinationViewController as! DateTimePickerVC
      vc.selectedDate = selectedDate
      vc.delegate = self
      UIView.animateWithDuration(0.45, animations: {
        self.dimmer?.alpha = 0.7
      })
    }
  }
  
  /**
   * Validate if segue should be performed.
   */
  override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
    if identifier == "ShowTripList" {
      if criterions?.dest == nil || criterions?.origin == nil ||
        (criterions?.origin?.siteId == criterions?.dest?.siteId && criterions?.origin?.siteId != 0) {
          showInvalidLocationAlert()
          return false
      }
    }
    return true
  }
  
  @IBAction func onAdvancedButtonTap(sender: UIBarButtonItem) {
    isAdvancedMode = !isAdvancedMode
    sender.title = (isAdvancedMode) ? "Enkel" : "Avancerad"
    criterions?.isAdvanced = isAdvancedMode
    if !isAdvancedMode {
      resetViaStation()
    }
    
    tableView.reloadData()
  }
  /**
   * Changed if departure time or arrival time
   */
  @IBAction func onDepartureArrivalChanged(sender: UISegmentedControl) {
    if let crit = criterions {
      crit.searchForArrival = (destinationArrivalSegmented.selectedSegmentIndex == 1)
    }
  }
  
  
  @IBAction func unwindToStationSearchParent(segue: UIStoryboardSegue) {}
  
  // MARK: LocationSearchResponder
  
  /**
  * Triggered when location is selected on location search VC.
  */
  func selectedLocationFromSearch(location: Location) {
    if let crit = criterions, locationType = searchLocationType {
      switch locationType {
      case "Origin":
        crit.origin = location
        originLabel.text = location.name
      case "Destination":
        crit.dest = location
        destinationLabel.text = location.name
      case "Via":
        crit.via = location
        viaLabel.text = location.name
        isViaSelected = true
        tableView.reloadData()
      default:
        print("Error: searchLocationType")
      }
    }
    searchLocationType = nil
  }
  
  // MARK: DateTimePickResponder
  
  /**
  * Triggered whem date and time is picked
  */
  func pickedDate(date: NSDate?) -> Void {
    if let crit = criterions, let date = date {
      let dateTimeTuple = DateUtils.dateAsStringTuple(date)
      crit.date = dateTimeTuple.date
      crit.time = dateTimeTuple.time
      timeLabel.text = DateUtils.friendlyDateAndTime(date)
      selectedDate = date
    }
    UIView.animateWithDuration(0.2, animations: {
      self.dimmer?.alpha = 0.0
    })
  }
  
  // MARK: UITableViewController
  
  /**
  * Height for rows.
  * (Will hide some rows when in simple mode)
  */
  override func tableView(tableView: UITableView,
    heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      if !isAdvancedMode {
        if indexPath.section == 0 && indexPath.row == 2 {
          return 0
        }
      }
      return 44
  }
  
  /**
   * Can row be edited?
   */
  override func tableView(tableView: UITableView,
    canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      return (indexPath.section == 0 && indexPath.row == 2 && isViaSelected)
  }
  
  /**
   * Editing style
   */
  override func tableView(tableView: UITableView,
    editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
      return (indexPath.section == 0 && indexPath.row == 2) ? .Delete : .None
  }
  
  /**
   * Green highlight on selected row.
   */
  override func tableView(tableView: UITableView,
    willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      let bgColorView = UIView()
      bgColorView.backgroundColor = StyleHelper.sharedInstance.mainGreenLight
      cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * Edit actions. (Only used for clear Via station)
   */
  override func tableView(tableView: UITableView,
    editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
      return [UITableViewRowAction(
        style: UITableViewRowActionStyle.Normal,
        title: "Rensa") { (_, _) -> Void in
          self.resetViaStation()
          tableView.reloadData()
        }]
  }
  
  /**
   * Deselect selected row.
   */
  override func tableView(tableView: UITableView,
    didSelectRowAtIndexPath indexPath: NSIndexPath) {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  // MARK: Private
  
  /**
  * Restores UI from criterions.
  */
  private func restoreUIFromCriterions() {
    if let crit = criterions {
      isAdvancedMode = crit.isAdvanced
      advancedToggleButton.title = (isAdvancedMode) ? "Enkel" : "Avancerad"
      if crit.origin != nil {
        originLabel.text = crit.origin!.name
      }
      if crit.dest != nil {
        destinationLabel.text = crit.dest!.name
      }
      if crit.via != nil {
        viaLabel.text = crit.via!.name
        isViaSelected = true
      }
    }
    
    criterions?.searchForArrival = false
    pickedDate(NSDate())
    tableView.reloadData()
  }
  
  /**
   * Show a invalid location alert
   */
  private func showInvalidLocationAlert() {
    let invalidLocationAlert = UIAlertController(
      title: "Station saknas",
      message: "Du behöver ange två olika stationer för \"från\" och \"till\".",
      preferredStyle: UIAlertControllerStyle.Alert)
    invalidLocationAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.Default, handler: nil))
    
    presentViewController(invalidLocationAlert, animated: true, completion: nil)
  }
  
  /**
   * Creates a screen dimmer for date/time picker.
   */
  private func createDimmer() {
    dimmer = UIView(frame: CGRect(origin: CGPoint.zero, size: view.bounds.size))
    dimmer!.userInteractionEnabled = false
    dimmer!.backgroundColor = UIColor.blackColor()
    dimmer!.alpha = 0.0
    view.addSubview(dimmer!)
  }
  
  /**
   * Resets the via station selector.
   */
  private func resetViaStation() {
    self.isViaSelected = false
    self.viaLabel.text = "(Välj station)"
    self.criterions?.via = nil
  }
}
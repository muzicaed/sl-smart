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

class TripSearchVC: UITableViewController, LocationSearchResponder,
DateTimePickResponder, PickLocationResponder, TravelTypesResponder, PickGenericValueResponder {
  
  let notificationCenter = NSNotificationCenter.defaultCenter()
  var searchLocationType: String?
  var selectedDate = NSDate()
  var criterions: TripSearchCriterion?
  var dimmer: UIView?
  var isViaSelected = false
  var isAdvancedMode = false
  
  @IBOutlet weak var viaLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var destinationArrivalSegmented: UISegmentedControl!
  @IBOutlet weak var advancedToggleButton: UIBarButtonItem!
  @IBOutlet weak var locationPickerRow: LocationPickerRow!
  @IBOutlet weak var travelTypePicker:  TravelTypesPickerRow!
  
  @IBOutlet weak var isAlternative: UITableViewCell!
  @IBOutlet weak var maxWalkLabel: UILabel!
  @IBOutlet weak var numberOfChangesLabel: UILabel!
  @IBOutlet weak var changeTimeLabel: UILabel!
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.editing = true
    view.backgroundColor = StyleHelper.sharedInstance.background
    criterions = SearchCriterionStore.sharedInstance.retrieveSearchCriterions()
    restoreUIFromCriterions()
    createDimmer()
    createNotificationListners()
    locationPickerRow.delegate = self
    locationPickerRow.prepareGestures()
  }
  
  /**
   * Before seque is triggred.
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if let crit = criterions {
      if segue.identifier == "SearchOriginLocation" {
        let vc = segue.destinationViewController as! SearchLocationVC
        vc.delegate = self
        vc.searchOnlyForStations = false
        vc.allowCurrentPosition = true
        vc.allowNearbyStations = true
        vc.title = "Välj från"
        searchLocationType = "Origin"
        
      } else if segue.identifier == "SearchDestinationLocation" {
        let vc = segue.destinationViewController as! SearchLocationVC
        vc.delegate = self
        vc.searchOnlyForStations = false
        vc.allowCurrentPosition = true
        vc.allowNearbyStations = true
        vc.title = "Välj till"
        searchLocationType = "Destination"
        
      } else if segue.identifier == "SearchViaLocation" {
        let vc = segue.destinationViewController as! SearchLocationVC
        vc.delegate = self
        vc.searchOnlyForStations = true
        vc.title = "Välj via station"
        searchLocationType = "Via"
        
      } else if segue.identifier == "ShowTripList" {
        let vc = segue.destinationViewController as! TripListVC
        vc.criterions = criterions?.copy() as? TripSearchCriterion
        SearchCriterionStore.sharedInstance.writeLastSearchCriterions(crit)
        RoutineService.addHabitRoutine(crit)
        
      } else if segue.identifier == "ShowDateTimePicker" {
        let vc = segue.destinationViewController as! DateTimePickerVC
        vc.selectedDate = selectedDate
        vc.delegate = self
        UIView.animateWithDuration(0.45, animations: {
          self.dimmer?.alpha = 0.7
        })
        
      } else if segue.identifier == "ShowTravelTypesPicker" {
        let vc = segue.destinationViewController as! TravelTypesVC
        vc.delegate = self
        if let crit = criterions {
          vc.setData(crit)
        }
        
      } else if segue.identifier == "MaxWalkDistance" {
        let vc = segue.destinationViewController as! GenericValuePickerVC
        vc.delegate = self
        vc.title = "Max gångavstånd"
        vc.setValue(crit.maxWalkDist, valueType: .WalkDistance)
        
      } else if segue.identifier == "NumberOfChanges" {
        let vc = segue.destinationViewController as! GenericValuePickerVC
        vc.delegate = self
        vc.title = "Antal byten"
        vc.setValue(crit.numChg, valueType: .NoOfChanges)
        
      } else if segue.identifier == "ChangeTime" {
        let vc = segue.destinationViewController as! GenericValuePickerVC
        vc.delegate = self
        vc.title = "Extra tid vid byte"
        vc.setValue(crit.minChgTime, valueType: .TimeForChange)
      }
    }
  }
  
  /**
   * Validate if segue should be performed.
   */
  override func shouldPerformSegueWithIdentifier(
    identifier: String, sender: AnyObject?)
    -> Bool {
      if identifier == "ShowTripList" {
        if criterions?.dest == nil || criterions?.origin == nil ||
          (criterions?.origin?.siteId == criterions?.dest?.siteId && criterions?.origin?.siteId != "0") {
          showInvalidLocationAlert()
          return false
        } else if criterions?.via != nil && (
          criterions?.via?.siteId == criterions?.origin?.siteId ||
            criterions?.via?.siteId == criterions?.dest?.siteId) {
          showInvalidViaAlert()
        }
      }
      return true
  }
  
  @IBAction func onAdvancedButtonTap(sender: UIBarButtonItem) {
    isAdvancedMode = !isAdvancedMode
    sender.title = (isAdvancedMode) ? "Enkel" : "Avancerad"
    criterions?.isAdvanced = isAdvancedMode
    travelTypePicker.updateLabel(criterions!)
    if isAdvancedMode {
      viaLabel.text = "(Välj station)"
    } else {
      resetViaStation()
      criterions?.resetAdvancedTripTypes()
      updateGenericValues()
    }
    
    animateAdvancedToggle()
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
        locationPickerRow.setOriginLabelLocation(location)
      case "Destination":
        crit.dest = location
        locationPickerRow.setDestinationLabelLocation(location)
      case "Via":
        crit.via = location
        viaLabel.text = location.name
        isViaSelected = true
        tableView.reloadData()
      default: break
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
  
  // MARK: PickLocationResponder
  
  /**
   * Called when user taped on orign or destination row.
   */
  func pickLocation(isOrigin: Bool) {
    if isOrigin {
      performSegueWithIdentifier("SearchOriginLocation", sender: self)
    } else {
      performSegueWithIdentifier("SearchDestinationLocation", sender: self)
    }
  }
  
  /**
   * User tapped switch location.
   */
  func switchTapped() {
    tableView.beginUpdates()
    if let crit = criterions {
      let oldOrigin = crit.origin
      let oldOriginId = crit.originId
      crit.origin = crit.dest
      crit.originId = crit.destId
      crit.dest = oldOrigin
      crit.destId = oldOriginId
      
      locationPickerRow.setOriginLabelLocation(crit.origin)
      locationPickerRow.setDestinationLabelLocation(crit.dest)
    }
    tableView.endUpdates()
  }
  
  // MARK: PickGenericValueResponder
  
  /**
   * User picked a value using the generic value picker.
   */
  func pickedValue(type: GenericValuePickerVC.ValueType, value: Int) {
    if let crit = criterions {
      switch type {
      case .WalkDistance:
        crit.maxWalkDist = value
      case .NoOfChanges:
        crit.numChg = value
      case .TimeForChange:
        crit.minChgTime = value
      }
      updateGenericValues()
    }
  }
  
  // MARK: TravelTypesResponder
  
  func selectedTravelType(
    useMetro: Bool, useTrain: Bool,
    useTram: Bool, useBus: Bool,
    useBoat: Bool
    ) {
    criterions?.useMetro = useMetro
    criterions?.useTrain = useTrain
    criterions?.useTram = useTram
    criterions?.useBus = useBus
    criterions?.useFerry = useBoat
    criterions?.useShip = useBoat
    if let crit = criterions {
      travelTypePicker.updateLabel(crit)
    }
  }
  
  // MARK: UITableViewController
  
  /**
   * Section count
   */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return (isAdvancedMode) ? 6 : 3
  }
  
  /**
   * Row count in section
   */
  override func tableView(
    tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if section == 0 {
      return (isAdvancedMode) ? 2 : 1
    } else if section > 2 {
      return 2
    }
    
    return 1
  }
  
  /**
   * User selected row
   */
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 4 && indexPath.row == 1 {
      if let crit = criterions {
        crit.unsharp = !crit.unsharp
        updateGenericValues()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
      }
    } else if indexPath.section == 2 {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
  }
  
  /**
   * Height for rows.
   */
  override func tableView(
    tableView: UITableView,
    heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
    if indexPath.section == 0 && indexPath.row == 0 {
      return 88
    }
    return 44
  }
  
  /**
   * Can row be edited?
   */
  override func tableView(
    tableView: UITableView,
    canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
    return (indexPath.section == 0 && indexPath.row == 1 && isViaSelected && isAdvancedMode)
  }
  
  /**
   * Editing style
   */
  override func tableView(
    tableView: UITableView,
    editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    return (indexPath.section == 0 && indexPath.row == 1) ? .Delete : .None
  }
  
  /**
   * Green highlight on selected row.
   */
  override func tableView(
    tableView: UITableView, willDisplayCell cell: UITableViewCell,
    forRowAtIndexPath indexPath: NSIndexPath) {
    
    let bgColorView = UIView()
    bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
    cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * Edit actions. (Only used for clear Via station)
   */
  override func tableView(
    tableView: UITableView,
    editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    
    return [UITableViewRowAction(
      style: UITableViewRowActionStyle.Normal,
    title: "Rensa") { (_, _) -> Void in
      self.resetViaStation()
      tableView.reloadData()
      }]
  }
  
  /**
   * Restores UI from criterions.
   */
  func restoreUIFromCriterions() {
    if let crit = criterions {
      isAdvancedMode = crit.isAdvanced
      advancedToggleButton.title = (isAdvancedMode) ? "Enkel" : "Avancerad"
      locationPickerRow.setOriginLabelLocation(crit.origin)
      locationPickerRow.setDestinationLabelLocation(crit.dest)
      
      if crit.via != nil {
        viaLabel.text = crit.via!.name
        isViaSelected = true
      }
      
      // TODO: For migration purpose can be removed with version 1.4
      if !isAdvancedMode {
        crit.resetAdvancedTripTypes()
      }
      
      travelTypePicker.updateLabel(crit)
      updateGenericValues()
      crit.searchForArrival = false
      destinationArrivalSegmented.selectedSegmentIndex = (crit.searchForArrival) ? 1 : 0
      pickedDate(NSDate())
    }
    tableView.reloadData()
  }
  
  // MARK: Private
  
  /**
   * Animates the table view on advanced toggle.
   */
  private func animateAdvancedToggle() {
    tableView.beginUpdates()
    if isAdvancedMode {
      tableView.insertRowsAtIndexPaths(
        [NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Automatic)
      tableView.insertSections(NSIndexSet(index: 3), withRowAnimation: .Automatic)
      tableView.insertSections(NSIndexSet(index: 4), withRowAnimation: .Automatic)
      tableView.insertSections(NSIndexSet(index: 5), withRowAnimation: .Automatic)
    } else {
      tableView.deleteRowsAtIndexPaths(
        [NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Automatic)
      tableView.deleteSections(NSIndexSet(index: 3), withRowAnimation: .Automatic)
      tableView.deleteSections(NSIndexSet(index: 4), withRowAnimation: .Automatic)
      tableView.deleteSections(NSIndexSet(index: 5), withRowAnimation: .Automatic)
    }
    tableView.endUpdates()
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
   * Show a invalid via location alert
   */
  private func showInvalidViaAlert() {
    let invalidLocationAlert = UIAlertController(
      title: "Felaktig \"Via station\"",
      message: "Via kan ej vara samma station som Från eller Till station.",
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
    self.criterions?.via = nil
    self.viaLabel.text = "(Välj station)"
  }
  
  /**
   * Updates generic value picker labels
   */
  private func updateGenericValues() {
    if let crit = criterions {
      switch crit.maxWalkDist {
      case 1000, 2000:
        maxWalkLabel.text = "Högst \(crit.maxWalkDist / 1000) km"
      default:
        maxWalkLabel.text = "Högst \(crit.maxWalkDist) m"
      }
      
      switch crit.numChg {
      case -1:
        numberOfChangesLabel.text = "Inga begränsningar för antal byten"
      case 0:
        numberOfChangesLabel.text = "Inga byten"
      case 1:
        numberOfChangesLabel.text = "Högst 1 byte"
      default:
        numberOfChangesLabel.text = "Högst \(crit.numChg) byten"
      }
      
      switch crit.minChgTime {
      case 0:
        changeTimeLabel.text = "Ingen extra tid vid byte"
      default:
        changeTimeLabel.text = "\(crit.minChgTime) minuter extra vid byte"
      }
      
      isAlternative.accessoryType = .None
      if crit.unsharp {
        isAlternative.accessoryType = .Checkmark
      }
    }
  }
  
  /**
   * Add listners for notfication events.
   */
  private func createNotificationListners() {
    notificationCenter.addObserver(
      self,
      selector: #selector(restoreUIFromCriterions),
      name: UIApplicationDidBecomeActiveNotification, object: nil)
  }
  
  /**
   * Deinit
   */
  deinit {
    notificationCenter.removeObserver(self)
  }
}
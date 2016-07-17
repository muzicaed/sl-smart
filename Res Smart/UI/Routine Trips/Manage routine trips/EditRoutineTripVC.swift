//
//  EditRoutineTripVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class EditRoutineTripVC: UITableViewController, LocationSearchResponder, UITextFieldDelegate,
  TravelTypesResponder, PickLocationResponder, PickGenericValueResponder, LinePickerResponder,
DateTimePickResponder {
  
  @IBOutlet weak var locationPickerRow: LocationPickerRow!
  @IBOutlet weak var viaLabel: UILabel!
  @IBOutlet weak var tripTitleTextField: UITextField!
  @IBOutlet weak var travelTypesPickerRow: TravelTypesPickerRow!
  
  var routineTrip: RoutineTrip?
  var routineTripCopy: RoutineTrip?
  var locationSearchType: String?
  var isNewTrip = true
  var hasChanged = false
  var isViaSelected = false
  var isMakeRoutine = false
  var selectedDate: NSDate?
  var dimmer: UIView?
  
  @IBOutlet weak var isAlternative: UITableViewCell!
  @IBOutlet weak var maxWalkLabel: UILabel!
  @IBOutlet weak var numberOfChangesLabel: UILabel!
  @IBOutlet weak var changeTimeLabel: UILabel!
  @IBOutlet weak var linesLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  
  /**
   * When view is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.editing = true
    view.backgroundColor = StyleHelper.sharedInstance.background
    createFakeBackButton()
    updateGenericValues()
    createDimmer()
    
    // TODO: Refactoring, make function
    if routineTrip == nil && !isMakeRoutine {
      title = "Ny rutin"
      isNewTrip = true
      routineTrip = RoutineTrip()
      routineTrip?.criterions.unsharp = false
      locationPickerRow.setOriginLabelLocation(nil)
      locationPickerRow.setDestinationLabelLocation(nil)
      
    } else if isMakeRoutine {
      routineTrip?.criterions.unsharp = false
      routineTripCopy = routineTrip!.copy() as? RoutineTrip
      setupEditData()
      title = "Ny rutin"
      isNewTrip = true
      
    } else {
      routineTrip?.criterions.unsharp = false
      routineTripCopy = routineTrip!.copy() as? RoutineTrip
      setupEditData()
      isNewTrip = false
      title = routineTrip!.title
      self.navigationItem.rightBarButtonItems!.removeFirst()
    }
    
    locationPickerRow.delegate = self
    locationPickerRow.prepareGestures()
    tripTitleTextField.delegate = self
    tripTitleTextField.addTarget(
      self, action: #selector(textFieldDidChange(_:)),
      forControlEvents: UIControlEvents.EditingChanged)
  }
  
  /**
   * When view is about to disappear.
   */
  override func viewWillDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    if !isNewTrip && routineTrip != nil && hasChanged && !isMakeRoutine {
      RoutineTripsStore.sharedInstance.updateRoutineTrip(routineTrip!)
    }
  }
  
  /**
   * Before seque is triggred.
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    tripTitleTextField.resignFirstResponder()
    if segue.identifier == "SearchOriginLocation" {
      locationSearchType = "Origin"
      let vc = segue.destinationViewController as! SearchLocationVC
      vc.searchOnlyForStations = false
      vc.allowNearbyStations = true
      vc.delegate = self
      
    } else if segue.identifier == "SearchDestinationLocation" {
      locationSearchType = "Destination"
      let vc = segue.destinationViewController as! SearchLocationVC
      vc.searchOnlyForStations = false
      vc.allowNearbyStations = true
      vc.delegate = self
      
    } else if segue.identifier == "SearchViaLocation" {
      locationSearchType = "Via"
      let vc = segue.destinationViewController as! SearchLocationVC
      vc.delegate = self
      
    } else if segue.identifier == "ShowTravelTypesPicker" {
      let vc = segue.destinationViewController as! TravelTypesVC
      vc.delegate = self
      if let crit = routineTrip?.criterions {
        vc.setData(crit)
      }
    } else if segue.identifier == "MaxWalkDistance" {
      let vc = segue.destinationViewController as! GenericValuePickerVC
      vc.delegate = self
      vc.title = "Max gångavstånd"
      vc.setValue(routineTrip!.criterions.maxWalkDist, valueType: .WalkDistance)
      
    } else if segue.identifier == "NumberOfChanges" {
      let vc = segue.destinationViewController as! GenericValuePickerVC
      vc.delegate = self
      vc.title = "Antal byten"
      vc.setValue(routineTrip!.criterions.numChg, valueType: .NoOfChanges)
      
    } else if segue.identifier == "ChangeTime" {
      let vc = segue.destinationViewController as! GenericValuePickerVC
      vc.delegate = self
      vc.title = "Extra tid vid byte"
      vc.setValue(routineTrip!.criterions.minChgTime, valueType: .TimeForChange)
      
    } else if segue.identifier == "PickLines" {
      let vc = segue.destinationViewController as! LinePickerVC
      vc.delegate = self
      vc.incText = routineTrip!.criterions.lineInc
      vc.excText = routineTrip!.criterions.lineExc
      
    } else if segue.identifier == "ShowTimePicker" {
      let vc = segue.destinationViewController as! TimePickerVC
      vc.selectedDate = selectedDate
      vc.delegate = self
      UIView.animateWithDuration(0.45, animations: {
        self.dimmer?.alpha = 0.7
      })
    }
  }
  
  /**
   * Tap on Add Routine Trip button in navigation bar
   */
  @IBAction func onRoutineTripNavAddTap(sender: UIBarButtonItem) {
    createRoutineTrip()
  }
  
  /**
   * On trip title text field change.
   */
  func textFieldDidChange(textField: UITextField) {
    hasChanged = true
    routineTrip?.title = tripTitleTextField.text
    if !isNewTrip {
      title = routineTrip!.title
    }
  }
  
  /**
   * On navbar back tap.
   */
  func onBackTap() {
    if !isNewTrip && !isMakeRoutine {
      if tripTitleTextField.text == nil || tripTitleTextField.text == "" {
        showInvalidTitleAlert()
        return
      } else if isInvalidLocationData() {
        showInvalidLocationAlert()
        return
      } else if isInvalidViaLocation() {
        showInvalidViaAlert()
      }
      routineTrip?.criterions.isAdvanced = isAdvacedCriterions()
    }
    navigationController?.popViewControllerAnimated(true)
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
    hasChanged = true
    tableView.beginUpdates()
    let crit = routineTrip!.criterions
    let oldOrigin = crit.origin
    let oldOriginId = crit.originId
    crit.origin = crit.dest
    crit.originId = crit.destId
    crit.dest = oldOrigin
    crit.destId = oldOriginId
    
    locationPickerRow.setOriginLabelLocation(crit.origin)
    locationPickerRow.setDestinationLabelLocation(crit.dest)
    tableView.endUpdates()
  }
  
  @IBAction func unwindToStationSearchParent(segue: UIStoryboardSegue) {}
  @IBAction func unwindToTripTypePickerParent(segue: UIStoryboardSegue) {}
  
  // MARK: PickGenericValueResponder
  
  /**
   * User picked a value using the generic value picker.
   */
  func pickedValue(type: GenericValuePickerVC.ValueType, value: Int) {
    if let routine = routineTrip {
      switch type {
      case .WalkDistance:
        routine.criterions.maxWalkDist = value
      case .NoOfChanges:
        routine.criterions.numChg = value
      case .TimeForChange:
        routine.criterions.minChgTime = value
      }
      hasChanged = true
      updateGenericValues()
    }
  }
  
  // MARK: LinePickerResponder
  
  func pickedLines(included: String?, excluded: String?) {
    if let routine = routineTrip {
      routine.criterions.lineInc = included
      routine.criterions.lineExc = excluded
      hasChanged = true
      updateGenericValues()
    }
  }
  
  // MARK: LocationSearchResponder
  
  /**
   * Triggered whem location is selected on location search VC.
   */
  func selectedLocationFromSearch(location: Location) {
    hasChanged = true
    if locationSearchType == "Origin" {
      routineTrip?.criterions.origin = location
      locationPickerRow.setOriginLabelLocation(location)
    } else if locationSearchType == "Destination" {
      routineTrip?.criterions.dest = location
      locationPickerRow.setDestinationLabelLocation(location)
    } else if locationSearchType == "Via" {
      routineTrip?.criterions.via = location
      viaLabel.text = location.name
      isViaSelected = true
      tableView.reloadData()
    }
  }
  
  // MARK: TravelTypesResponder
  
  /**
   * User selected travel types.
   */
  func selectedTravelType(
    useMetro: Bool, useTrain: Bool, useTram: Bool,
    useBus: Bool, useBoat: Bool) {
    if let crit = routineTrip?.criterions {
      hasChanged = true
      crit.useMetro = useMetro
      crit.useTrain = useTrain
      crit.useTram = useTram
      crit.useBus = useBus
      crit.useFerry = useBoat
      crit.useShip = useBoat
      travelTypesPickerRow.updateLabel(crit)
    }
  }
  
  // MARK: DateTimePickResponder
  
  /**
   * Triggered whem date and time is picked
   */
  func pickedDate(date: NSDate?) -> Void {
    if let routine = routineTrip, let date = date {
      hasChanged = true
      let dateTimeTuple = DateUtils.dateAsStringTuple(date)
      routine.criterions.date = nil
      routine.criterions.time = dateTimeTuple.time
      arrivalTimeLabel.text = "Klockan \(dateTimeTuple.time)"
      selectedDate = date
      tableView.reloadData()
    }
    UIView.animateWithDuration(0.2, animations: {
      self.dimmer?.alpha = 0.0
    })
  }
  
  // MARK: UITableViewController
  
  /**
   * Row count for section
   */
  override func tableView(tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if section == 0 || section == 2 {
      return 1
    }
    return 2
  }
  
  /**
   * Will select row at index.
   */
  override func tableView(tableView: UITableView,
                          willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0) {
      return nil
    }
    return indexPath
  }
  
  /**
   * Can row be edited?
   */
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return (
      (indexPath.section == 1 && indexPath.row == 1 && isViaSelected) ||
        (indexPath.section == 2 && selectedDate != nil)
    )
  }
  
  /**
   * Editing style
   */
  override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    return (indexPath.section == 1 && indexPath.row == 1) || (indexPath.section == 2) ? .Delete : .None
  }
  
  /**
   * Edit actions. (Only used for clear Via station & Arrival time)
   */
  override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    if indexPath.section == 1 && indexPath.row == 1 {
      return [
        UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Rensa") { (_, _) -> Void in
          self.resetViaStation()
          tableView.reloadData()
        }]
    } else if indexPath.section == 2 {
      return [
        UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Rensa") { (_, _) -> Void in
          self.selectedDate = nil
          self.arrivalTimeLabel.text = "När som helst"
          tableView.reloadData()
        }]
    }
    return nil
  }
  
  /**
   * Will display row at index
   */
  override func tableView(
    tableView: UITableView, willDisplayCell cell: UITableViewCell,
    forRowAtIndexPath indexPath: NSIndexPath) {
    
    let bgColorView = UIView()
    bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
    cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * User selected row
   */
  override func tableView(
    tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 4 && indexPath.row == 1 {
      hasChanged = true
      if let routine = routineTrip {
        routine.criterions.unsharp = !routine.criterions.unsharp
        updateGenericValues()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
      }
    } else if indexPath.section == 2 && indexPath.row == 0 {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
  }
  
  // MARK: UITextFieldDelegate
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    tripTitleTextField.resignFirstResponder()
    return true
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                 replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }
    
    let newLength = text.characters.count + string.characters.count - range.length
    return newLength <= 200
  }
  
  // MARK: Private methods
  
  /**
   * Fills form with location data for edit.
   */
  private func setupEditData() {
    if let trip = routineTrip {
      tripTitleTextField.text = trip.title
      locationPickerRow.setOriginLabelLocation(trip.criterions.origin)
      locationPickerRow.setDestinationLabelLocation(trip.criterions.dest)
      travelTypesPickerRow.updateLabel(trip.criterions)
      
      if trip.criterions.via != nil {
        isViaSelected = true
        viaLabel.text = trip.criterions.via?.name
      }
    }
  }
  
  /**
   * Show a invalid title alert
   */
  private func showInvalidTitleAlert() {
    let invalidTitleAlert = UIAlertController(
      title: "Titel saknas",
      message: "Du behöver ange en titel för din resa.",
      preferredStyle: UIAlertControllerStyle.Alert)
    invalidTitleAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.Default, handler: nil))
    
    presentViewController(invalidTitleAlert, animated: true, completion: nil)
  }
  
  /**
   * Show a invalid location alert
   */
  private func showInvalidLocationAlert() {
    let invalidLocationAlert = UIAlertController(
      title: "Station saknas",
      message: "Du behöver ange två olika stationerna som du brukar åka mellan.",
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
   * Creats and persists a routine trip based
   * on data on current form. Also navigates back.
   */
  private func createRoutineTrip() {
    tripTitleTextField.resignFirstResponder()
    if tripTitleTextField.text == nil || tripTitleTextField.text == "" {
      showInvalidTitleAlert()
      return
    } else {
      routineTrip?.title = tripTitleTextField.text
    }
    
    if isInvalidLocationData() {
      showInvalidLocationAlert()
      return
    }
    
    if isInvalidViaLocation() {
      showInvalidViaAlert()
      return
    }
    
    routineTrip?.criterions.isAdvanced = isAdvacedCriterions()
    routineTrip?.isSmartSuggestion = false
    RoutineTripsStore.sharedInstance.addRoutineTrip(routineTrip!)
    performSegueWithIdentifier("unwindToManageRoutineTrips", sender: self)
  }
  
  /**
   * Checks if user entred location data is valid.
   */
  private func isInvalidLocationData() -> Bool {
    return (routineTrip == nil ||
      routineTrip?.criterions.origin == nil ||
      routineTrip?.criterions.dest == nil ||
      (
        routineTrip?.criterions.origin?.siteId == routineTrip?.criterions.dest?.siteId &&
          routineTrip?.criterions.origin?.siteId != "0"
      )
    )
  }
  
  /**
   * Checks if user entred via location is valid.
   */
  private func isInvalidViaLocation() -> Bool {
    if let crit = routineTrip?.criterions {
      return (crit.via != nil &&
        (
          crit.via?.siteId == crit.origin?.siteId ||
            crit.via?.siteId == crit.dest?.siteId
        )
      )
    }
    return true
  }
  
  /**
   * Replaces the navbar back button so
   * that it is possible to trap back tap event.
   */
  private func createFakeBackButton() {
    let backButton = UIBarButtonItem(
      title: "Tillbaka", style: .Plain, target: self, action: #selector(onBackTap))
    self.navigationItem.leftBarButtonItem = backButton
  }
  
  /**
   * Clear via location
   */
  private func resetViaStation() {
    hasChanged = true
    isViaSelected = false
    routineTrip?.criterions.via = nil
    self.viaLabel.text = "(Välj station) - Valfri"
  }
  
  /**
   * Checks if any advanced settings are actually used.
   * If not automatically set advanced flag to false.
   */
  private func isAdvacedCriterions() -> Bool {
    if let crit = routineTrip?.criterions {
      return (
        !isTravelTypeDefault(crit) ||
          crit.via != nil ||
          crit.unsharp == true ||
          crit.maxWalkDist != 1000 ||
          crit.minChgTime != 0 ||
          crit.numChg != -1)
    }
    return false
  }
  
  /**
   * Checks if any travel types
   * are used.
   */
  private func isTravelTypeDefault(crit: TripSearchCriterion) -> Bool {
    return (crit.useBus && crit.useFerry && crit.useMetro &&
      crit.useShip && crit.useTrain && crit.useTram)
  }
  
  /**
   * Updates generic value picker labels
   */
  private func updateGenericValues() {
    if let routine = routineTrip {
      switch routine.criterions.maxWalkDist {
      case 1000, 2000:
        maxWalkLabel.text = "Högst \(routine.criterions.maxWalkDist / 1000) km"
      default:
        maxWalkLabel.text = "Högst \(routine.criterions.maxWalkDist) m"
      }
      
      switch routine.criterions.numChg {
      case -1:
        numberOfChangesLabel.text = "Inga begränsningar för antal byten"
      case 0:
        numberOfChangesLabel.text = "Inga byten"
      case 1:
        numberOfChangesLabel.text = "Högst 1 byte"
      default:
        numberOfChangesLabel.text = "Högst \(routine.criterions.numChg) byten"
      }
      
      switch routine.criterions.minChgTime {
      case 0:
        changeTimeLabel.text = "Ingen extra tid vid byte"
      default:
        changeTimeLabel.text = "\(routine.criterions.minChgTime) minuter extra vid byte"
      }
      
      isAlternative.accessoryType = .None
      if routine.criterions.unsharp {
        isAlternative.accessoryType = .Checkmark
      }
      
      if routine.criterions.lineInc == nil && routine.criterions.lineExc == nil {
        linesLabel.text = "Alla linjer"
      } else if routine.criterions.lineInc != nil {
        linesLabel.text = "Använd endast: \(routine.criterions.lineInc!)"
      } else if routine.criterions.lineExc != nil {
        linesLabel.text = "Använd inte: \(routine.criterions.lineExc!)"
      }
    }
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
}
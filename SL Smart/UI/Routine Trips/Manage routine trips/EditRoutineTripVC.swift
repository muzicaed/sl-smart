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
TravelTypesResponder, PickLocationResponder {
  
  @IBOutlet weak var locationPickerRow: LocationPickerRow!
  @IBOutlet weak var viaLabel: UILabel!
  @IBOutlet weak var tripTitleTextField: UITextField!
  @IBOutlet weak var travelTypesPickerRow: TravelTypesPickerRow!
  
  var routineTrip: RoutineTrip?
  var routineTripCopy: RoutineTrip?
  var routineTripIndex = -1
  var locationSearchType: String?
  var isNewTrip = true
  var hasChanged = false
  var isViaSelected = false
  
  
  /**
   * When view is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.editing = true
    view.backgroundColor = StyleHelper.sharedInstance.background
    createFakeBackButton()
    
    if routineTrip == nil {
      title = "Ny vanlig resa"
      routineTrip = RoutineTrip()
      isNewTrip = true
    } else {
      routineTripCopy = routineTrip!.copy() as? RoutineTrip
      title = routineTrip!.title
      setupEditData()
      isNewTrip = false
      self.navigationItem.rightBarButtonItems!.removeFirst()
    }
    
    locationPickerRow.delegate = self
    locationPickerRow.prepareGestures()
    tripTitleTextField.delegate = self
    tripTitleTextField.addTarget(self,
      action: "textFieldDidChange:",
      forControlEvents: UIControlEvents.EditingChanged)
  }
  
  /**
   * When view is about to disappear.
   */
  override func viewWillDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    if !isNewTrip && routineTrip != nil && hasChanged {
      DataStore.sharedInstance.updateRoutineTrip(routineTripIndex, trip: routineTrip!)
    }
  }
  
  /**
   * Before seque is triggred.
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    print(segue.identifier)
    tripTitleTextField.resignFirstResponder()
    if segue.identifier == "SearchOriginLocation" {
      locationSearchType = "Origin"
      let vc = segue.destinationViewController as! SearchLocationVC
      vc.delegate = self
      
    } else if segue.identifier == "SearchDestinationLocation" {
      locationSearchType = "Destination"
      let vc = segue.destinationViewController as! SearchLocationVC
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
    if !isNewTrip {
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
    locationPickerRow.originLabel.text = crit.origin?.name
    locationPickerRow.destinationLabel.text = crit.dest?.name
    if locationPickerRow.originLabel.text == nil {
      locationPickerRow.originLabel.text = "(Välj station)"
    }
    if locationPickerRow.destinationLabel.text == nil {
      locationPickerRow.destinationLabel.text = "(Välj station)"
    }
    
    tableView.endUpdates()
  }
  
  @IBAction func unwindToStationSearchParent(segue: UIStoryboardSegue) {}
  @IBAction func unwindToTripTypePickerParent(segue: UIStoryboardSegue) {}
  
  // MARK: LocationSearchResponder
  
  /**
  * Triggered whem location is selected on location search VC.
  */
  func selectedLocationFromSearch(location: Location) {
    hasChanged = true
    if locationSearchType == "Origin" {
      routineTrip?.criterions.origin = location
      locationPickerRow.originLabel.text = location.name
    } else if locationSearchType == "Destination" {
      routineTrip?.criterions.dest = location
      locationPickerRow.destinationLabel.text = location.name
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
  
  // MARK: UITableViewController
  
  /**
  * Row count for section
  */
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      if section == 1 {
        return 2
      }
      return 1
  }
  
  /**
   * Will select row at index.
   */
  override func tableView(tableView: UITableView,
    willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
      if indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 1) {
        return nil
      }
      return indexPath
  }
  
  /**
   * Can row be edited?
   */
  override func tableView(tableView: UITableView,
    canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      return (indexPath.section == 1 && indexPath.row == 1 && isViaSelected)
  }
  
  /**
   * Editing style
   */
  override func tableView(tableView: UITableView,
    editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
      return (indexPath.section == 1 && indexPath.row == 1) ? .Delete : .None
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
   * Will display row at index
   */
  override func tableView(tableView: UITableView,
    willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      let bgColorView = UIView()
      bgColorView.backgroundColor = StyleHelper.sharedInstance.mainGreenLight
      cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * Deselect selected row.
   */
  override func tableView(tableView: UITableView,
    didSelectRowAtIndexPath indexPath: NSIndexPath) {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  // MARK: UITextFieldDelegate
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    tripTitleTextField.resignFirstResponder()
    return true
  }
  
  func textField(textField: UITextField,
    shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
      guard let text = textField.text else { return true }
      
      let newLength = text.characters.count + string.characters.count - range.length
      return newLength <= 30
  }
  
  // MARK: Private methods
  
  /**
  * Fills form with location data for edit.
  */
  private func setupEditData() {
    if let trip = routineTrip {
      tripTitleTextField.text = trip.title
      locationPickerRow.originLabel.text = trip.criterions.origin?.name
      locationPickerRow.destinationLabel.text = trip.criterions.dest?.name
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
      title: "Title saknas",
      message: "Du behöver ange en title för din resa.",
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
    DataStore.sharedInstance.addRoutineTrip(routineTrip!)
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
          routineTrip?.criterions.origin?.siteId != 0
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
      title: "Tillbaka", style: .Plain, target: self, action: Selector("onBackTap"))
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
   * Resets the tabel type criterions
   */
  private func resetTravelType() {
    routineTrip?.criterions.useBus = true
    routineTrip?.criterions.useFerry = true
    routineTrip?.criterions.useMetro = true
    routineTrip?.criterions.useShip = true
    routineTrip?.criterions.useTrain = true
    routineTrip?.criterions.useTram = true
  }
  
  /**
   * Checks if any advanced settings are actually used.
   * If not automatically set advanced flag to false.
   */
  private func isAdvacedCriterions() -> Bool {
    if let crit = routineTrip?.criterions {
      return (!isTravelTypeDefault(crit) || crit.via != nil)
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
  
  deinit {
    print("Deinit: EditRoutineTripVC")
  }
}
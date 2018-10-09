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
  var selectedDate: Date?
  var dimmer: UIView?
  
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
    tableView.isEditing = true
    createFakeBackButton()
    updateGenericValues()
    createDimmer()
    prepareFields()
  }
  
  /**
   * When view is about to disappear.
   */
  override func viewWillDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if !isNewTrip && routineTrip != nil && hasChanged && !isMakeRoutine {
      RoutineTripsStore.sharedInstance.updateRoutineTrip(routineTrip!)
    }
  }
  
  /**
   * Before seque is triggred.
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    tripTitleTextField.resignFirstResponder()
    if segue.identifier == "SearchOriginLocation" {
      locationSearchType = "Origin"
      let vc = segue.destination as! SearchLocationVC
      vc.searchOnlyForStations = false
      vc.allowNearbyStations = true
      vc.allowCurrentPosition = false
      vc.delegate = self
      
    } else if segue.identifier == "SearchDestinationLocation" {
      locationSearchType = "Destination"
      let vc = segue.destination as! SearchLocationVC
      vc.searchOnlyForStations = false
      vc.allowNearbyStations = true
      vc.delegate = self
      
    } else if segue.identifier == "SearchViaLocation" {
      locationSearchType = "Via"
      let vc = segue.destination as! SearchLocationVC
      vc.delegate = self
      
    } else if segue.identifier == "ShowTravelTypesPicker" {
      let vc = segue.destination as! TravelTypesVC
      vc.delegate = self
      if let crit = routineTrip?.criterions {
        vc.setData(crit)
      }
    } else if segue.identifier == "MaxWalkDistance" {
      let vc = segue.destination as! GenericValuePickerVC
      vc.delegate = self
      vc.title = "Max walk distance".localized
      vc.setValue(routineTrip!.criterions.maxWalkDist, valueType: .WalkDistance)
      
    } else if segue.identifier == "NumberOfChanges" {
      let vc = segue.destination as! GenericValuePickerVC
      vc.delegate = self
      vc.title = "No of transfers".localized
      vc.setValue(routineTrip!.criterions.numChg, valueType: .NoOfChanges)
      
    } else if segue.identifier == "ChangeTime" {
      let vc = segue.destination as! GenericValuePickerVC
      vc.delegate = self
      vc.title = "Extra transfer time".localized
      vc.setValue(routineTrip!.criterions.minChgTime, valueType: .TimeForChange)
      
    } else if segue.identifier == "PickLines" {
      let vc = segue.destination as! LinePickerVC
      vc.delegate = self
      vc.incText = routineTrip!.criterions.lineInc
      vc.excText = routineTrip!.criterions.lineExc
      
    } else if segue.identifier == "ShowTimePicker" {
      let vc = segue.destination as! TimePickerVC
      vc.selectedDate = selectedDate
      vc.delegate = self
      UIView.animate(withDuration: 0.45, animations: {
        self.dimmer?.alpha = 0.7
      })
    }
  }
  
  /**
   * Tap on Add Routine Trip button in navigation bar
   */
  @IBAction func onRoutineTripNavAddTap(_ sender: UIBarButtonItem) {
    createRoutineTrip()
  }
  
  /**
   * On trip title text field change.
   */
  @objc func textFieldDidChange(_ textField: UITextField) {
    hasChanged = true
    routineTrip?.title = tripTitleTextField.text
    if !isNewTrip {
      title = routineTrip!.title
    }
  }
  
  /**
   * On navbar back tap.
   */
  @objc func onBackTap() {
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
    let _ = navigationController?.popViewController(animated: true)
  }
  
  // MARK: PickLocationResponder
  
  /**
   * Called when user taped on orign or destination row.
   */
  func pickLocation(_ isOrigin: Bool) {
    if isOrigin {
      performSegue(withIdentifier: "SearchOriginLocation", sender: self)
    } else {
      performSegue(withIdentifier: "SearchDestinationLocation", sender: self)
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
  
  @IBAction func unwindToStationSearchParent(_ segue: UIStoryboardSegue) {}
  @IBAction func unwindToTripTypePickerParent(_ segue: UIStoryboardSegue) {}
  
  // MARK: PickGenericValueResponder
  
  /**
   * User picked a value using the generic value picker.
   */
  func pickedValue(_ type: GenericValuePickerVC.ValueType, value: Int) {
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
  
  func pickedLines(_ included: String?, excluded: String?) {
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
  func selectedLocationFromSearch(_ location: Location) {
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
    _ useMetro: Bool, useTrain: Bool, useTram: Bool,
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
  func pickedDate(_ date: Date?) -> Void {
    if let routine = routineTrip, let date = date {
      hasChanged = true
      let dateTimeTuple = DateUtils.dateAsStringTuple(date)
      routine.criterions.date = nil
      routine.criterions.time = dateTimeTuple.time
      arrivalTimeLabel.text = "\("At".localized) \(dateTimeTuple.time)"
      selectedDate = date
      tableView.reloadData()
    }
    UIView.animate(withDuration: 0.2, animations: {
      self.dimmer?.alpha = 0.0
    })
  }
  
  // MARK: UITableViewController
  
  /**
   * Row count for section
   */
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    if section == 0 || section == 2 || section == 4 {
      return 1
    }
    return 2
  }
  
  /**
   * Will select row at index.
   */
  override func tableView(_ tableView: UITableView,
                          willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0) {
      return nil
    }
    return indexPath
  }
  
  /**
   * Can row be edited?
   */
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return (
      (indexPath.section == 1 && indexPath.row == 1 && isViaSelected) ||
        (indexPath.section == 2 && selectedDate != nil)
    )
  }
  
  /**
   * Editing style
   */
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return (indexPath.section == 1 && indexPath.row == 1) || (indexPath.section == 2) ? .delete : .none
  }
  
  /**
   * Edit actions. (Only used for clear Via station & Arrival time)
   */
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    if indexPath.section == 1 && indexPath.row == 1 {
      hasChanged = true
      return [
        UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Clear".localized) { (_, _) -> Void in
          self.resetViaStation()
          tableView.reloadData()
        }]
    } else if indexPath.section == 2 {
      return [
        UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Clear".localized) { (_, _) -> Void in
          self.resetArrivalTime()
          tableView.reloadData()
        }]
    }
    return nil
  }
  
  /**
   * Will display row at index
   */
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                          forRowAt indexPath: IndexPath) {
    let bgColorView = UIView()
    bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
    cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * User selected row
   */
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 2 && indexPath.row == 0 {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  /**
   * User taps accessory button on row
   */
  override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    if indexPath.section == 2 {
      showArrivalTimeAlert()
    }
  }
  
  // MARK: UITextFieldDelegate
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    tripTitleTextField.resignFirstResponder()
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    guard let text = textField.text else { return true }
    
    let newLength = text.characters.count + string.characters.count - range.length
    return newLength <= 200
  }
  
  // MARK: Private methods
  
  /**
   * Prepares the fields.
   */
  fileprivate func prepareFields() {
    if routineTrip == nil && !isMakeRoutine {
      title = "New routine".localized
      isNewTrip = true
      routineTrip = RoutineTrip()
      locationPickerRow.setOriginLabelLocation(nil)
      locationPickerRow.setDestinationLabelLocation(nil)
      
    } else if isMakeRoutine {
      routineTripCopy = routineTrip!.copy() as? RoutineTrip
      setupEditData()
      title = "New routine".localized
      isNewTrip = true
      
    } else {
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
      for: UIControlEvents.editingChanged)
  }
  
  /**
   * Fills form with location data for edit.
   */
  fileprivate func setupEditData() {
    if let trip = routineTrip {
      tripTitleTextField.text = trip.title
      locationPickerRow.setOriginLabelLocation(trip.criterions.origin)
      locationPickerRow.setDestinationLabelLocation(trip.criterions.dest)
      travelTypesPickerRow.updateLabel(trip.criterions)
      
      if let time = trip.criterions.time {
        let today = Date()
        selectedDate = DateUtils.convertDateString("\(DateUtils.dateAsDateString(today)) \(time)")
        arrivalTimeLabel.text = "\("At".localized) \(time)"
      }
      
      if trip.criterions.via != nil {
        isViaSelected = true
        viaLabel.text = trip.criterions.via?.name
      }
    }
  }
  
  /**
   * Show a invalid title alert
   */
  fileprivate func showInvalidTitleAlert() {
    let invalidTitleAlert = UIAlertController(
      title: "Title missing".localized,
      message: "You need to give you routine a title".localized,
      preferredStyle: UIAlertControllerStyle.alert)
    invalidTitleAlert.addAction(
      UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.default, handler: nil))
    
    present(invalidTitleAlert, animated: true, completion: nil)
  }
  
  /**
   * Show a invalid title alert
   */
  fileprivate func showArrivalTimeAlert() {
    let arrivalTimeAlert = UIAlertController(
      title: "Latest arrival".localized,
      message: "You can enter when at the latests you need to arrive.\n\nThis works perfect with routines like \"Go to work\" or \"Soccer practise\"".localized,
      preferredStyle: UIAlertControllerStyle.alert)
    arrivalTimeAlert.addAction(
      UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.default, handler: nil))
    
    present(arrivalTimeAlert, animated: true, completion: nil)
  }
  
  /**
   * Show a arrival time info alert
   */
  fileprivate func showInvalidLocationAlert() {
    let invalidLocationAlert = UIAlertController(
      title: "Stop missing".localized,
      message: "\"from\" and \"to\" needs to be two different stations.".localized,
      preferredStyle: UIAlertControllerStyle.alert)
    invalidLocationAlert.addAction(
      UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.default, handler: nil))
    
    present(invalidLocationAlert, animated: true, completion: nil)
  }
  
  /**
   * Show a invalid via location alert
   */
  fileprivate func showInvalidViaAlert() {
    let invalidLocationAlert = UIAlertController(
      title: "Incorrect \"Via stop\"".localized,
      message: "Via can not be the same station as \"from\" or \"to\".".localized,
      preferredStyle: UIAlertControllerStyle.alert)
    invalidLocationAlert.addAction(
      UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.default, handler: nil))
    
    present(invalidLocationAlert, animated: true, completion: nil)
  }
  
  /**
   * Creats and persists a routine trip based
   * on data on current form. Also navigates back.
   */
  fileprivate func createRoutineTrip() {
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
    performSegue(withIdentifier: "unwindToManageRoutineTrips", sender: self)
  }
  
  /**
   * Checks if user entred location data is valid.
   */
  fileprivate func isInvalidLocationData() -> Bool {
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
  fileprivate func isInvalidViaLocation() -> Bool {
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
  fileprivate func createFakeBackButton() {
    let backButton = UIBarButtonItem(
      title: "Tillbaka".localized, style: .plain, target: self, action: #selector(onBackTap))
    self.navigationItem.leftBarButtonItem = backButton
  }
  
  /**
   * Clear via location
   */
  fileprivate func resetViaStation() {
    hasChanged = true
    isViaSelected = false
    routineTrip?.criterions.via = nil
    self.viaLabel.text = "(Choose stop)".localized
  }
  
  /**
   * Clear arrival time
   */
  fileprivate func resetArrivalTime() {
    hasChanged = true
    self.selectedDate = nil
    routineTrip?.criterions.time = nil
    self.arrivalTimeLabel.text = "Any time".localized
  }
  
  /**
   * Checks if any advanced settings are actually used.
   * If not automatically set advanced flag to false.
   */
  fileprivate func isAdvacedCriterions() -> Bool {
    if let crit = routineTrip?.criterions {
      return (
        !isTravelTypeDefault(crit) ||
          crit.via != nil ||
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
  fileprivate func isTravelTypeDefault(_ crit: TripSearchCriterion) -> Bool {
    return (crit.useBus && crit.useFerry && crit.useMetro &&
      crit.useShip && crit.useTrain && crit.useTram)
  }
  
  /**
   * Updates generic value picker labels
   */
  fileprivate func updateGenericValues() {
    if let routine = routineTrip {
      switch routine.criterions.maxWalkDist {
      case 1000, 2000:
        maxWalkLabel.text = String(format: "Max %d km".localized, routine.criterions.maxWalkDist / 1000)
      default:
        maxWalkLabel.text = String(format: "Max %d m".localized, routine.criterions.maxWalkDist)
      }
      
      switch routine.criterions.numChg {
      case -1:
        numberOfChangesLabel.text = "No limitations for no. of transfers".localized
      case 0:
        numberOfChangesLabel.text = "No transfers".localized
      case 1:
        numberOfChangesLabel.text = "Max 1 transfer".localized
      default:
        numberOfChangesLabel.text = String(format: "Max %d transfers".localized, routine.criterions.numChg)
      }
      
      switch routine.criterions.minChgTime {
      case 0:
        changeTimeLabel.text = "No extra time for transfer".localized
      default:
        changeTimeLabel.text = String(format: "%d minutes extra for transfer".localized, routine.criterions.minChgTime)
      }
      
      if routine.criterions.lineInc == nil && routine.criterions.lineExc == nil {
        linesLabel.text = "All lines".localized
      } else if routine.criterions.lineInc != nil {
        linesLabel.text = "\("Only use:".localized) \(routine.criterions.lineInc!)"
      } else if routine.criterions.lineExc != nil {
        linesLabel.text = "\("Don't use:".localized) \(routine.criterions.lineExc!)"
      }
    }
  }
  
  /**
   * Creates a screen dimmer for date/time picker.
   */
  fileprivate func createDimmer() {
    dimmer = UIView(frame: CGRect(origin: CGPoint.zero, size: view.bounds.size))
    dimmer!.isUserInteractionEnabled = false
    dimmer!.backgroundColor = UIColor.black
    dimmer!.alpha = 0.0
    view.addSubview(dimmer!)
  }
}

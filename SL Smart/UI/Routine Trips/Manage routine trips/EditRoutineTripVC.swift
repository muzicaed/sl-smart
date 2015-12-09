//
//  EditRoutineTripVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class EditRoutineTripVC: UITableViewController, StationSearchResponder, UITextFieldDelegate {
  
  @IBOutlet weak var timeSegmentControl: UISegmentedControl!
  @IBOutlet weak var weekRoutineSegmentControl: UISegmentedControl!
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var tripTitleTextField: UITextField!
  
  var routineTrip: RoutineTrip?
  var routineTripCopy: RoutineTrip?
  var routineTripIndex = -1
  var isSearchingOriginStation = true
  var isNewTrip = true
  var hasChanged = false
  
  
  /**
   * When view is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = StyleHelper.sharedInstance.background
    
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
      ScorePostHelper.giveScoreForUpdatedRoutineTrip(routineTrip!, oldRoutineTrip: routineTripCopy!)
      DataStore.sharedInstance.updateRoutineTrip(routineTripIndex, trip: routineTrip!)
    }
  }
  
  /**
   * Before seque is triggred.
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    tripTitleTextField.resignFirstResponder()
    if segue.identifier == "SearchOriginStation" {
      isSearchingOriginStation = true
      let vc = segue.destinationViewController as! SearchLocationVC
      vc.delegate = self
    } else if segue.identifier == "SearchDestinationStation" {
      isSearchingOriginStation = false
      let vc = segue.destinationViewController as! SearchLocationVC
      vc.delegate = self
    }
  }
  
  /**
   * Tap on Add Routine Trip button in navigation bar
   */
  @IBAction func onRoutineTripNavAddTap(sender: UIBarButtonItem) {
    createRoutineTrip()
  }
  
  /**
   * Time picker segment changed.
   */
  @IBAction func onTimeSegmentChange(sender: UISegmentedControl) {
    hasChanged = true
    routineTrip?.routine?.time = RoutineTime(
      rawValue: timeSegmentControl.selectedSegmentIndex)!
  }
  
  /**
   * Time picker segment changed.
   */
  @IBAction func onWeekSegmentChange(sender: UISegmentedControl) {
    hasChanged = true
    routineTrip?.routine?.week = RoutineWeek(
      rawValue: weekRoutineSegmentControl.selectedSegmentIndex)!
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
  
  // MARK: StationSearchResponder
  
  /**
  * Triggered whem station is selected on station search VC.
  */
  func selectedStationFromSearch(station: Station) {
    hasChanged = true
    if isSearchingOriginStation {
      routineTrip?.origin = station
      originLabel.text = station.name
    } else {
      routineTrip?.destination = station
      destinationLabel.text = station.name
    }
  }
  
  @IBAction func unwindToStationSearchParent(segue: UIStoryboardSegue) {}
  
  // MARK: UITableViewController
  
  override func tableView(tableView: UITableView,
    willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
      if indexPath.section != 1 {
        return nil
      }
      return indexPath
  }
  
  
  override func tableView(tableView: UITableView,
    accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
      if indexPath.section == 2 {
        if indexPath.row == 0 {
          showWeekInfoAlert()
        } else {
          showTimeInfoAlert()
        }
      }
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
  * Fills form with station data for edit.
  */
  private func setupEditData() {
    if let trip = routineTrip {
      tripTitleTextField.text = trip.title
      originLabel.text = trip.origin?.name
      destinationLabel.text = trip.destination?.name
      
      if let routine = trip.routine {
        weekRoutineSegmentControl.selectedSegmentIndex = routine.week.rawValue
        timeSegmentControl.selectedSegmentIndex = routine.time.rawValue
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
   * Show a invalid station alert
   */
  private func showInvalidStationAlert() {
    let invalidStationAlert = UIAlertController(
      title: "Station saknas",
      message: "Du behöver ange de två stationerna du åker till och från för din resa.",
      preferredStyle: UIAlertControllerStyle.Alert)
    invalidStationAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.Default, handler: nil))
    
    presentViewController(invalidStationAlert, animated: true, completion: nil)
  }
  
  /**
   * Show a week info alert
   */
  private func showWeekInfoAlert() {
    let invalidStationAlert = UIAlertController(
      title: "Förklaring",
      message: "Välj hur du oftast åker denna resa - vardagar eller helger.\n\nAppen lär sig dina vanor även när du reser utanför denna rutin. ",
      preferredStyle: UIAlertControllerStyle.Alert)
    invalidStationAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.Default, handler: nil))
    
    presentViewController(invalidStationAlert, animated: true, completion: nil)
  }
  
  /**
   * Show a time info alert
   */
  private func showTimeInfoAlert() {
    let invalidStationAlert = UIAlertController(
      title: "Förklaring",
      message: "Morgon: 05:00 - 10.59\nDag: 11:00 - 17:59\nKväll: 18:00 - 21:59\nNatt: 22:00 - 04:59\n\nAppen lär sig dina vanor även när du reser utanför dessa tider.",
      preferredStyle: UIAlertControllerStyle.Alert)
    invalidStationAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.Default, handler: nil))
    
    presentViewController(invalidStationAlert, animated: true, completion: nil)
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
    
    if routineTrip == nil || routineTrip?.origin == nil || routineTrip?.destination == nil {
      showInvalidStationAlert()
      return
    }
    
    DataStore.sharedInstance.addRoutineTrip(routineTrip!)
    ScorePostHelper.giveScoreForNewRoutineTrip(routineTrip!)
    performSegueWithIdentifier("unwindToManageRoutineTrips", sender: self)
  }
  
  deinit {
    print("Deinit: EditRoutineTripVC")
  }
}
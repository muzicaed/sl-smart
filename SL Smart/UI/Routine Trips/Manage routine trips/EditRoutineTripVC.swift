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

class EditRoutineTripVC: UITableViewController, LocationSearchResponder, UITextFieldDelegate {
  
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var tripTitleTextField: UITextField!
  @IBOutlet weak var advancedButton: UIButton!
  
  var routineTrip: RoutineTrip?
  var routineTripCopy: RoutineTrip?
  var routineTripIndex = -1
  var isSearchingOriginLocation = true
  var isNewTrip = true
  var hasChanged = false
  var isAdvanced = false
  
  
  /**
   * When view is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
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
      isSearchingOriginLocation = true
      let vc = segue.destinationViewController as! SearchLocationVC
      vc.delegate = self
    } else if segue.identifier == "SearchDestinationLocation" {
      isSearchingOriginLocation = false
      let vc = segue.destinationViewController as! SearchLocationVC
      vc.delegate = self
    }
  }
  
  /**
   * Tap on Show Advanced button.
   */
  @IBAction func onAdvancedButtonTap(sender: UIButton) {
    isAdvanced = !isAdvanced
    
    tableView.beginUpdates()
    if isAdvanced {
      tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 1)], withRowAnimation: .Automatic)
      advancedButton.setTitle("Dölj avancerade inställningar", forState: UIControlState.Normal)
    } else {
      tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 1)], withRowAnimation: .Automatic)
      advancedButton.setTitle("Visa avancerade inställningar", forState: UIControlState.Normal)
    }
    tableView.endUpdates()
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
      }
    }
    navigationController?.popViewControllerAnimated(true)
  }
  
  // MARK: LocationSearchResponder
  
  /**
  * Triggered whem location is selected on location search VC.
  */
  func selectedLocationFromSearch(location: Location) {
    hasChanged = true
    if isSearchingOriginLocation {
      routineTrip?.criterions.origin = location
      originLabel.text = location.name
    } else {
      routineTrip?.criterions.dest = location
      destinationLabel.text = location.name
    }
  }
  
  @IBAction func unwindToStationSearchParent(segue: UIStoryboardSegue) {}
  
  // MARK: UITableViewController
  
  /**
  * Section count
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 3
  }
  
  /**
   * Row count for section
   */
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      
      if section == 1 {
        return (isAdvanced) ? 3 : 2
      }
      
      return 1
  }
  
  /**
   * Will select row at index.
   */
  override func tableView(tableView: UITableView,
    willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
      if indexPath.section != 1 {
        return nil
      }
      return indexPath
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
      originLabel.text = trip.criterions.origin?.name
      destinationLabel.text = trip.criterions.dest?.name
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
      routineTrip?.criterions.origin?.siteId == routineTrip?.criterions.dest?.siteId)
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
  
  deinit {
    print("Deinit: EditRoutineTripVC")
  }
}
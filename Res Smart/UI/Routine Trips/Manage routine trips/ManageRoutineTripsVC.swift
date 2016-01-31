//
//  ManageRoutineTripsVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class ManageRoutineTripsVC: UITableViewController {
  
  let cellIdentifier = "MyRoutinTripCell"
  let emptyCellIdentifier = "NoRoutineCell"
  let showEditTripsSegue = "EditRoutineTrip"
  let showAddTripsSegue = "AddRoutineTrip"
  
  var trips = [RoutineTrip]()
  var selectedRoutineTrip: RoutineTrip?
  
  var addButton = UIBarButtonItem()
  var editButton = UIBarButtonItem()
  var doneButton = UIBarButtonItem()
  
  /**
   * View done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = StyleHelper.sharedInstance.background
    addButton = navigationItem.rightBarButtonItems![0]
    editButton = navigationItem.rightBarButtonItems![1]
    doneButton = navigationItem.rightBarButtonItems![2]
    navigationItem.rightBarButtonItems?.removeAtIndex(2)
    tableView.tableFooterView = UIView()
  }
  
  /**
   * View about to show
   */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    trips = RoutineTripsStore.sharedInstance.retriveRoutineTripsNoSuggestions()
    tableView.reloadData()
    if trips.count == 0 && navigationItem.rightBarButtonItems?.count > 1 {
      navigationItem.rightBarButtonItems?.removeAtIndex(1)
    } else if trips.count > 0 && navigationItem.rightBarButtonItems?.count == 1 && !tableView.editing {
      navigationItem.rightBarButtonItems?.insert(editButton, atIndex: 1)
    }
  }
  
  /**
   * Prepare for seque to another vc.
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == showEditTripsSegue {
      let vc = segue.destinationViewController as! EditRoutineTripVC
      vc.routineTrip = selectedRoutineTrip
    }
  }
  
  /**
   * User taps edit.
   */
  @IBAction func onEditTap(sender: UIBarButtonItem) {
    tableView.setEditing(true, animated: true)
    navigationItem.rightBarButtonItems?.removeAtIndex(1)
    navigationItem.rightBarButtonItems?.removeAtIndex(0)
    navigationItem.rightBarButtonItems?.insert(doneButton, atIndex: 0)
    self.navigationItem.setHidesBackButton(true, animated: true)
  }
  
  /**
   * User taps done (when editing).
   */
  @IBAction func onDoneTap(sender: UIBarButtonItem) {
    tableView.setEditing(false, animated: true)
    navigationItem.rightBarButtonItems?.removeAtIndex(0)
    navigationItem.rightBarButtonItems?.insert(addButton, atIndex: 0)
    navigationItem.rightBarButtonItems?.insert(editButton, atIndex: 1)
    self.navigationItem.setHidesBackButton(false, animated: true)
  }
  
  @IBAction func unwindToManageRoutineTripsVC(segue: UIStoryboardSegue) {
    selectedRoutineTrip = nil
  }
  
  // MARK: UITableViewController
  
  /**
  * Data source count
  */
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      if trips.count == 0 {
        return 1
      }
      return trips.count
  }
  
  /**
   * Height for cells
   */
  override func tableView(tableView: UITableView,
    heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      if trips.count == 0 {
        return 100
      }
      return 80
  }
  
  /**
   * Create cells for each data post.
   */
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
      if trips.count == 0 {
        let cell =  tableView.dequeueReusableCellWithIdentifier(
          emptyCellIdentifier, forIndexPath: indexPath)
        return cell
      }
      
      let trip = trips[indexPath.row]
      let cell =  tableView.dequeueReusableCellWithIdentifier(
        cellIdentifier, forIndexPath: indexPath) as! ManageRoutineTripCell
      
      cell.setData(trip)
      return cell
  }
  
  /**
   * On user confirms action
   */
  override func tableView(tableView: UITableView,
    commitEditingStyle editingStyle: UITableViewCellEditingStyle,
    forRowAtIndexPath indexPath: NSIndexPath) {
      switch editingStyle {
      case .Delete:
        let trip = trips[indexPath.row]
        RoutineTripsStore.sharedInstance.deleteRoutineTrip(trip.id)
        trips.removeAtIndex(indexPath.row)
        
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        if trips.count == 0 {
          tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        tableView.endUpdates()
      default:
        return
      }
  }
  
  /**
   * User moved a cell in the table view.
   */
  override func tableView(tableView: UITableView,
    moveRowAtIndexPath sourceIndexPath: NSIndexPath,
    toIndexPath destinationIndexPath: NSIndexPath) {
      RoutineTripsStore.sharedInstance.moveRoutineTrip(
        sourceIndexPath.row, targetIndex: destinationIndexPath.row)
      let moveTrip = trips.removeAtIndex(sourceIndexPath.row)
      trips.insert(moveTrip, atIndex: destinationIndexPath.row)
  }
  
  /**
   * When user selects a row.
   */
  override func tableView(tableView: UITableView,
    didSelectRowAtIndexPath indexPath: NSIndexPath) {
      if trips.count == 0 {
        performSegueWithIdentifier(showAddTripsSegue, sender: self)
        return
      }
      selectedRoutineTrip = trips[indexPath.row]
      performSegueWithIdentifier(showEditTripsSegue, sender: self)
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
   * Height for header section.
   */
  override func tableView(tableView: UITableView,
    heightForHeaderInSection section: Int) -> CGFloat {
    return 1
  }
  
  /**
   * Title for delete button.
   */
  override func tableView(tableView: UITableView,
    titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
      return "Ta bort"
  }
}
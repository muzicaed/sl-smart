//
//  ManageRoutineTripsVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class ManageRoutineTripsVC: UITableViewController {
  
  let cellIdentifier = "MyRoutinTripCell"
  let emptyCellIdentifier = "NoRoutineCell"
  let showEditTripsSegue = "EditRoutineTrip"
  let showAddTripsSegue = "AddRoutineTrip"
  
  var trips = [RoutineTrip]()
  var selectedRoutineTrip: RoutineTrip?
  var selectedRoutineTripIndex = -1
  
  var addButton = UIBarButtonItem()
  var editButton = UIBarButtonItem()
  var doneButton = UIBarButtonItem()
  
  /**
   * View done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    StandardGradient.addLayer(view)
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
    trips = DataStore.sharedInstance.retriveRoutineTrips()
    tableView.reloadData()
    if trips.count == 0 && navigationItem.rightBarButtonItems?.count > 1 {
      navigationItem.rightBarButtonItems?.removeAtIndex(1)
    } else if trips.count > 0 && navigationItem.rightBarButtonItems?.count == 1 {
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
      vc.routineTripIndex = selectedRoutineTripIndex
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
    selectedRoutineTripIndex = -1
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
      return 85
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
      
      cell.tripTitleLabel.text = trip.title
      cell.routeTextLabel.text = "\(trip.origin!.cleanName) » \(trip.destination!.cleanName)"
      if let routine = trip.routine {
        cell.scheduleLabel.text = "\(routine.time.toFriendlyString()) på \(routine.week.toFriendlyString())"
      }
      
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
        trips.removeAtIndex(indexPath.row)
        DataStore.sharedInstance.deleteRoutineTrip(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
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
      DataStore.sharedInstance.moveRoutineTrip(
        sourceIndexPath.row, targetIndex: destinationIndexPath.row)
      let moveTrip = trips.removeAtIndex(sourceIndexPath.row)
      trips.insert(moveTrip, atIndex: destinationIndexPath.row)
  }
  
  /**
   * When user selects a row.
   */
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if trips.count == 0 {
      performSegueWithIdentifier(showAddTripsSegue, sender: self)
      return
    }
    
    selectedRoutineTrip = trips[indexPath.row]
    selectedRoutineTripIndex = indexPath.row
    performSegueWithIdentifier(showEditTripsSegue, sender: self)
  }
  
  deinit {
    print("Deinit: ManageRoutineTripsVC")
  }
}
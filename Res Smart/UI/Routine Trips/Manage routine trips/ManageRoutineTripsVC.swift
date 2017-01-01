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
    navigationItem.rightBarButtonItems?.remove(at: 2)
    tableView.tableFooterView = UIView()
  }
  
  /**
   * View about to show
   */
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    trips = RoutineTripsStore.sharedInstance.retriveRoutineTripsNoSuggestions()
    tableView.reloadData()
    let buttonCount = (navigationItem.rightBarButtonItems != nil) ? navigationItem.rightBarButtonItems!.count : 0
    if trips.count == 0 && buttonCount > 1 {
      navigationItem.rightBarButtonItems?.remove(at: 1)
    } else if trips.count > 0 && navigationItem.rightBarButtonItems?.count == 1 && !tableView.isEditing {
      navigationItem.rightBarButtonItems?.insert(editButton, at: 1)
    }
  }
  
  /**
   * Prepare for seque to another vc.
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == showEditTripsSegue {
      let vc = segue.destination as! EditRoutineTripVC
      vc.routineTrip = selectedRoutineTrip
    }
  }
  
  /**
   * User taps edit.
   */
  @IBAction func onEditTap(_ sender: UIBarButtonItem) {
    tableView.setEditing(true, animated: true)
    navigationItem.rightBarButtonItems?.remove(at: 1)
    navigationItem.rightBarButtonItems?.remove(at: 0)
    navigationItem.rightBarButtonItems?.insert(doneButton, at: 0)
    self.navigationItem.setHidesBackButton(true, animated: true)
  }
  
  /**
   * User taps done (when editing).
   */
  @IBAction func onDoneTap(_ sender: UIBarButtonItem) {
    tableView.setEditing(false, animated: true)
    navigationItem.rightBarButtonItems?.remove(at: 0)
    navigationItem.rightBarButtonItems?.insert(addButton, at: 0)
    navigationItem.rightBarButtonItems?.insert(editButton, at: 1)
    self.navigationItem.setHidesBackButton(false, animated: true)
  }
  
  @IBAction func unwindToManageRoutineTripsVC(_ segue: UIStoryboardSegue) {
    selectedRoutineTrip = nil
  }
  
  // MARK: UITableViewController
  
  /**
  * Data source count
  */
  override func tableView(_ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      if trips.count == 0 {
        return 1
      }
      return trips.count
  }
  
  /**
   * Height for cells
   */
  override func tableView(_ tableView: UITableView,
    heightForRowAt indexPath: IndexPath) -> CGFloat {
      if trips.count == 0 {
        return 100
      }
      return 80
  }
  
  /**
   * Create cells for each data post.
   */
  override func tableView(_ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      if trips.count == 0 {
        let cell =  tableView.dequeueReusableCell(
          withIdentifier: emptyCellIdentifier, for: indexPath)
        return cell
      }
      
      let trip = trips[indexPath.row]
      let cell =  tableView.dequeueReusableCell(
        withIdentifier: cellIdentifier, for: indexPath) as! ManageRoutineTripCell
      
      cell.setData(trip)
      return cell
  }
  
  /**
   * On user confirms action
   */
  override func tableView(_ tableView: UITableView,
    commit editingStyle: UITableViewCellEditingStyle,
    forRowAt indexPath: IndexPath) {
      switch editingStyle {
      case .delete:
        let trip = trips[indexPath.row]
        RoutineTripsStore.sharedInstance.deleteRoutineTrip(trip.id)
        trips.remove(at: indexPath.row)
        
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if trips.count == 0 {
          tableView.insertRows(at: [indexPath], with: .automatic)
        }
        tableView.endUpdates()
      default:
        return
      }
  }
  
  /**
   * User moved a cell in the table view.
   */
  override func tableView(_ tableView: UITableView,
    moveRowAt sourceIndexPath: IndexPath,
    to destinationIndexPath: IndexPath) {
      RoutineTripsStore.sharedInstance.moveRoutineTrip(
        sourceIndexPath.row, targetIndex: destinationIndexPath.row)
      let moveTrip = trips.remove(at: sourceIndexPath.row)
      trips.insert(moveTrip, at: destinationIndexPath.row)
  }
  
  /**
   * When user selects a row.
   */
  override func tableView(_ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath) {
      if trips.count == 0 {
        performSegue(withIdentifier: showAddTripsSegue, sender: self)
        return
      }
      selectedRoutineTrip = trips[indexPath.row]
      performSegue(withIdentifier: showEditTripsSegue, sender: self)
  }
  
  /**
   * Green highlight on selected row.
   */
  override func tableView(_ tableView: UITableView,
    willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      let bgColorView = UIView()
      bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
      cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * Height for header section.
   */
  override func tableView(_ tableView: UITableView,
    heightForHeaderInSection section: Int) -> CGFloat {
    return 1
  }
  
  /**
   * Title for delete button.
   */
  override func tableView(_ tableView: UITableView,
    titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
      return "Ta bort"
  }
}

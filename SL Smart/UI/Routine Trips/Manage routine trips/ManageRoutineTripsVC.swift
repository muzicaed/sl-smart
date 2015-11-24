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
  var trips = [RoutineTrip]()
  var selectedRoutineTrip: RoutineTrip?
  var selectedRoutineTripIndex = -1

  /**
   * View done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(patternImage: UIImage(named: "GreenBackground")!)
  }
  
  /**
   * View about to show
   */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    trips = DataStore.sharedInstance.retriveRoutineTrips()
    tableView.reloadData()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "EditRoutineTripe" {
      let vc = segue.destinationViewController as! EditRoutineTripVC
      vc.routineTrip = selectedRoutineTrip
      vc.routineTripIndex = selectedRoutineTripIndex
    }
  }
  
  @IBAction func onDoneTap(sender: UIBarButtonItem) {
    performSegueWithIdentifier("unwindToRoutineTrips", sender: self)
  }
  
  @IBAction func unwindToManageRoutineTripsVC(segue: UIStoryboardSegue) {
    selectedRoutineTrip = nil
    selectedRoutineTripIndex = -1
  }
  
  // MARK: UICollectionViewDataSource
  
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
      print(trip.origin?.siteId)
      print(trip.destination?.siteId)
      let cell =  tableView.dequeueReusableCellWithIdentifier(
        cellIdentifier, forIndexPath: indexPath) as! ManageRoutineTripCell
      
      cell.tripTitleLabel.text = trip.title
      cell.routeTextLabel.text = "\(trip.origin!.name) ➙ \(trip.destination!.name)"
      if let routine = trip.routine {
        cell.scheduleLabel.text = "\(routine.time.toFriendlyString()) på \(routine.week.toFriendlyString())"
      }

      return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    selectedRoutineTrip = trips[indexPath.row]
    selectedRoutineTripIndex = indexPath.row
    performSegueWithIdentifier("EditRoutineTripe", sender: self)
  }
}
//
//  TripSearchVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class TripSearchVC: UITableViewController, StationSearchResponder {
  
  var isSearchingOriginStation = false
  let criterion = TripSearchCriterion(originId: 0, destId: 0)
  
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = StyleHelper.sharedInstance.background
    let dateTimeTuple = DateUtils.dateAsStringTuple(NSDate())
    criterion.date = dateTimeTuple.date
    criterion.time = dateTimeTuple.time
    timeLabel.text = DateUtils.friendlyDateAndTime(NSDate())
  }
  
  /**
   * Before seque is triggred.
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
  
  @IBAction func unwindToStationSearchParent(segue: UIStoryboardSegue) {}
  
  // MARK: StationSearchResponder
  
  /**
  * Triggered whem station is selected on station search VC.
  */
  func selectedStationFromSearch(station: Station) {
    
    if isSearchingOriginStation {
      criterion.originId = station.siteId
      originLabel.text = station.name
    } else {
      criterion.destId = station.siteId
      destinationLabel.text = station.name
    }
  }
  
  // MARK: UITableViewController
  
  override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    
    
    let bgColorView = UIView()
    bgColorView.backgroundColor = UIColor.lightGrayColor()
    cell.selectedBackgroundView = bgColorView
  }
}
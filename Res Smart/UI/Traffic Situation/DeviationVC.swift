//
//  DeviationVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-03-20.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class DeviationVC: UITableViewController {
  
  var deviation: Deviation?
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var lineLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    tableView.alwaysBounceVertical = true
    
    titleLabel.text = deviation!.title
    lineLabel.text = deviation!.scope
    dateLabel.text = "Gäller från: " + DateUtils.friendlyDateAndTime(deviation!.fromDate)
    messageLabel.text = deviation!.details
  }
  
  // MARK: UITableViewController
  
  /**
   * Height for row
   */
  override func tableView(tableView: UITableView,
    heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      
      return UITableViewAutomaticDimension
  }
  
  // MARK: Private
  
  /**
   * Setup view properties
   */
  private func setupView() {
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.separatorInset = UIEdgeInsetsZero
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 50
  }
}
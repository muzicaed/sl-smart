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
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    // MARK: Private
    
    /**
     * Setup view properties
     */
    fileprivate func setupView() {
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        view.backgroundColor = StyleHelper.sharedInstance.background
    }
}

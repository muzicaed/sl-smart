//
//  TravelTypesVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-14.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class TravelTypesVC: UITableViewController {
    
    var delegate: TravelTypesResponder?
    fileprivate var checkArr = [false, true, false, true, false]
    fileprivate let titels = ["Metro".localized, "Trains".localized,
                              "Trams".localized, "Buses".localized,
                              "Boats".localized]
    
    /**
     * View did load
     */
    override func viewDidLoad() {
        view.backgroundColor = StyleHelper.sharedInstance.background
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    /**
     * Set initial data.
     */
    func setData(_ criterions: TripSearchCriterion) {
        checkArr = [
            criterions.useMetro,
            criterions.useTrain,
            criterions.useTram,
            criterions.useBus,
            criterions.useFerry
        ]
    }
    
    // MARK: UITableViewController
    
    /**
     * Number of rows for section
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    /**
     * Cells for rows
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TripTypeRow", for: indexPath)
        
        if checkArr[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.selectionStyle = .none
        cell.textLabel?.text = titels[indexPath.row]    
        return cell
    }
    
    /**
     * User selects a row
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkArr[indexPath.row] = !checkArr[indexPath.row]
        delegate?.selectedTravelType(
            checkArr[0], useTrain: checkArr[1],
            useTram: checkArr[2], useBus: checkArr[3],
            useBoat: checkArr[4])
        tableView.reloadData()
    }
}

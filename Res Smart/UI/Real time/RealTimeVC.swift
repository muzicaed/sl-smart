//
//  RealTimeVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

/**
 * TODO: This VC could use a lot of refactoring...
 */
class RealTimeVC: UITableViewController, SMSegmentViewDelegate {
    
    @IBOutlet weak var topView: UIView!
    
    var realTimeDepartures: RealTimeDepartures?
    var isLoading = true
    var firstTimeLoad = true
    var siteId = 0
    var lastSelected = 0
    var busKeys = [String]()
    var metroKeys = [String]()
    var trainKeys = [String]()
    var tramKeys = [String]()
    var localTramKeys = [String]()
    var boatKeys = [String]()
    
    var tabTypesKeys = [String]()
    var segmentView = SMSegmentView()
    var refreshTimmer: Timer?
    var loadedTime = Date()
    var firstTime = true
    
    /**
     * On load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StyleHelper.sharedInstance.background
        topView.alpha = 0.0
        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(didBecomeInactive),
            name: UIApplication.willResignActiveNotification, object: nil)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.alwaysBounceVertical = true
    }
    
    /**
     * View will appear
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        loadData()
        startRefreshTimmer()
    }
    
    /**
     * View did unload
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRefreshTimmer()
        IJProgressView.shared.hideProgressView()
    }
    
    /**
     * Returned to the app.
     */
    @objc func didBecomeActive() {
        let now = Date()
        if now.timeIntervalSince(loadedTime) > (60 * 30) { // 30 minutes
            let _ = navigationController?.popToRootViewController(animated: false)
            return
        }
        tableView.reloadData()
        loadData()
        startRefreshTimmer()
    }
    
    /**
     * Backgrounded.
     */
    @objc func didBecomeInactive() {
        stopRefreshTimmer()
    }
    
    /**
     * Starts the refresh timmer
     */
    func startRefreshTimmer() {
        loadedTime = Date()
        stopRefreshTimmer()
        refreshTimmer = Timer.scheduledTimer(
            timeInterval: 15.0, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
    }
    
    /**
     * Stop the refresh timmer
     */
    func stopRefreshTimmer() {
        refreshTimmer?.invalidate()
        refreshTimmer = nil
    }
    
    /**
     * Load real time data
     */
    @objc func loadData() {
        NetworkActivity.displayActivityIndicator(true)
        if let navController = navigationController {
            IJProgressView.shared.showProgressView(navController.view)
        }
        RealTimeDeparturesService.fetch(siteId) { (rtDepartures, error) -> Void in
            let when = DispatchTime.now() + 0.2
            DispatchQueue.main.asyncAfter(deadline: when) {
                NetworkActivity.displayActivityIndicator(false)
                if error == nil {
                    if let departures = rtDepartures {                        
                        self.isLoading = false
                        self.firstTimeLoad = false
                        self.realTimeDepartures = departures
                        self.setupKeys()
                        self.prepareSegmentView()
                        
                        IJProgressView.shared.hideProgressView()
                        if self.firstTime {
                            UIView.transition(with: self.tableView,
                                              duration: 0.3,
                                              options: .transitionCrossDissolve,
                                              animations: { self.tableView?.reloadData() })
                        } else {
                            self.tableView.reloadData()
                        }
                        self.firstTime = false
                    }
                } else {
                    self.handleLoadDataError()
                }
            }
        }
    }
    
    // MARK: UITableViewController
    
    /**
     * Section count
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isLoading {
            return 0
        }
        
        return calcSectionCount()
    }
    
    /**
     * Row count
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 0
        }
        if section == 0 {
            return 1
        }
        return calcRowCount(section - 1)
    }
    
    /**
     * Cell on index
     */
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tabTypesKeys.count == 0 {
            return createNotFoundCell(indexPath)
        } else if indexPath.section == 0 {
            return createStopPointDeviationCell(indexPath)
        } else if indexPath.row == 0  {
            return createHeaderCell(indexPath)
        }
        return createTripCell(indexPath)
    }
    
    // MARK: SMSegmentViewDelegate
    
    func segmentView(_ segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {
        lastSelected = index
        UserPreferenceStore.sharedInstance.setLastRealTimeTripType(tabTypesKeys[index])
        tableView.reloadData()
    }
    
    // MARK: Private
    
    /**
     * Prepares Segment View
     */
    fileprivate func prepareSegmentView() {
        segmentView.removeFromSuperview()
        segmentView = SMSegmentView(
            frame: CGRect(x: 0, y: 0, width: 100.0, height: 50),
            separatorColour: UIColor.lightGray,
            separatorWidth: 0.0,
            segmentProperties: [
                keySegmentOnSelectionTextColour: UIColor.black,
                keySegmentTitleFont: UIFont.systemFont(ofSize: 12),
                keySegmentOnSelectionColour: UIColor(red: 22/255, green: 173/255, blue: 126/255, alpha: 0.5),
                keySegmentOffSelectionColour: UIColor.clear,
                keyContentVerticalMargin: 10.0 as AnyObject])
        
        var tabCount = 0
        let lastStoredSelected = UserPreferenceStore.sharedInstance.getLastRealTimeTripType()
        
        let busCount = (realTimeDepartures != nil) ? realTimeDepartures!.busses.count : 0
        if busCount > 0 {
            lastSelected = (lastStoredSelected == "BUS") ? tabCount : lastSelected
            tabCount += 1
            tabTypesKeys.append("BUS")
            let _ = segmentView.addSegmentWithTitle(
                nil,
                onSelectionImage: UIImage(named: "BUS"),
                offSelectionImage: UIImage(named: "BUS"))
        }
        
        let metroCount = (realTimeDepartures != nil) ? realTimeDepartures!.metros.count : 0
        if metroCount > 0 {
            lastSelected = (lastStoredSelected == "METRO") ? tabCount : lastSelected
            tabCount += 1
            tabTypesKeys.append("METRO")
            let _ = segmentView.addSegmentWithTitle(
                nil,
                onSelectionImage: UIImage(named: "METRO"),
                offSelectionImage: UIImage(named: "METRO"))
        }
        
        let trainCount = (realTimeDepartures != nil) ? realTimeDepartures!.trains.count : 0
        if trainCount > 0 {
            lastSelected = (lastStoredSelected == "TRAIN") ? tabCount : lastSelected
            tabCount += 1
            tabTypesKeys.append("TRAIN")
            let _ = segmentView.addSegmentWithTitle(
                nil,
                onSelectionImage: UIImage(named: "TRAIN"),
                offSelectionImage: UIImage(named: "TRAIN"))
        }
        
        let tramCount = (realTimeDepartures != nil) ? realTimeDepartures!.trams.count : 0
        if tramCount > 0 {
            lastSelected = (lastStoredSelected == "TRAM") ? tabCount : lastSelected
            tabCount += 1
            tabTypesKeys.append("TRAM")
            let _ = segmentView.addSegmentWithTitle(
                nil,
                onSelectionImage: UIImage(named: "TRAM"),
                offSelectionImage: UIImage(named: "TRAM"))
        }
        
        let localTramCount = (realTimeDepartures != nil) ? realTimeDepartures!.localTrams.count : 0
        if localTramCount > 0 {
            lastSelected = (lastStoredSelected == "LOCAL-TRAM") ? tabCount : lastSelected
            tabCount += 1
            tabTypesKeys.append("LOCAL-TRAM")
            let _ = segmentView.addSegmentWithTitle(
                nil,
                onSelectionImage: UIImage(named: "TRAM"),
                offSelectionImage: UIImage(named: "TRAM"))
        }
        
        let boatCount = (realTimeDepartures != nil) ? realTimeDepartures!.boats.count : 0
        if boatCount > 0 {
            lastSelected = (lastStoredSelected == "SHIP") ? tabCount : lastSelected
            tabCount += 1
            tabTypesKeys.append("SHIP")
            let _ = segmentView.addSegmentWithTitle(
                nil,
                onSelectionImage: UIImage(named: "SHIP"),
                offSelectionImage: UIImage(named: "SHIP"))
        }
        
        if tabCount > 0 {
            let screenWidth = UIScreen.main.bounds.width
            segmentView.delegate = self
            segmentView.selectSegmentAtIndex(lastSelected)
            segmentView.frame.size.width = CGFloat((screenWidth / 4) * CGFloat(tabCount))
            topView.addSubview(segmentView)
            topView.alpha = 1.0
            let frame = CGRect(x: 0, y: 0, width: topView.frame.width, height: 50)
            topView.frame = frame
        }
    }
    
    /**
     * Create header cell
     */
    fileprivate func createHeaderCell(_ indexPath: IndexPath) -> RealTimeHeaderRow {
        let cell = tableView!.dequeueReusableCell(
            withIdentifier: "Header", for: indexPath) as! RealTimeHeaderRow
        
        cell.setData(realTimeDepartures: realTimeDepartures!, indexPath: indexPath,
                     tabTypesKeys: tabTypesKeys, busKeys: busKeys, metroKeys: metroKeys,
                     trainKeys: trainKeys, tramKeys: tramKeys, localTramKeys: localTramKeys,
                     boatKeys: boatKeys, segmentView: segmentView)
        return cell
    }
    
    /**
     * Create trip cell
     */
    fileprivate func createTripCell(_ indexPath: IndexPath) -> RealTimeTripRow {
        let cell = tableView!.dequeueReusableCell(
            withIdentifier: "TripRow", for: indexPath) as! RealTimeTripRow
        
        cell.setData(realTimeDepartures: realTimeDepartures!, indexPath: indexPath,
                     tabTypesKeys: tabTypesKeys, busKeys: busKeys, metroKeys: metroKeys,
                     trainKeys: trainKeys, tramKeys: tramKeys, localTramKeys: localTramKeys,
                     boatKeys: boatKeys, segmentView: segmentView)
        return cell
    }
    
    /**
     * Create not found cell
     */
    fileprivate func createNotFoundCell(_ indexPath: IndexPath) -> UITableViewCell {
        return tableView!.dequeueReusableCell(
            withIdentifier: "NotFoundRow", for: indexPath)
    }
    
    /**
     * Create stop point deviation cell
     */
    fileprivate func createStopPointDeviationCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView!.dequeueReusableCell(
            withIdentifier: "StopPointDeviationRow", for: indexPath) as! RealTimeStopPointDeviationRow
        
        cell.setData(realTimeDepartures: realTimeDepartures, selectedType: tabTypesKeys[segmentView.indexOfSelectedSegment])
        return cell
    }
    
    /**
     * Setup key arrays
     */
    fileprivate func setupKeys() {
        busKeys = realTimeDepartures!.busses.keys.sorted(by: <)
        metroKeys = realTimeDepartures!.metros.keys.sorted(by: <)
        trainKeys = realTimeDepartures!.trains.keys.sorted(by: <)
        tramKeys = realTimeDepartures!.trams.keys.sorted(by: <)
        localTramKeys = realTimeDepartures!.localTrams.keys.sorted(by: <)
        boatKeys = realTimeDepartures!.boats.keys.sorted(by: <)
    }
    
    /**
     * Calculates the needed sections.
     */
    fileprivate func calcSectionCount() -> Int {
        if tabTypesKeys.count == 0 {
            return 1
        }
        
        if let realTimeDepartures = realTimeDepartures {
            if tabTypesKeys.count > segmentView.indexOfSelectedSegment {
                let tabKeys = tabTypesKeys[segmentView.indexOfSelectedSegment]
                switch tabKeys {
                case "BUS":
                    return realTimeDepartures.busses.count + 1
                case "METRO":
                    return realTimeDepartures.metros.count + 1
                case "TRAIN":
                    return realTimeDepartures.trains.count + 1
                case "TRAM":
                    return realTimeDepartures.trams.count + 1
                case "LOCAL-TRAM":
                    return realTimeDepartures.localTrams.count + 1
                case "SHIP":
                    return realTimeDepartures.boats.count + 1
                default:
                    return 0
                }
            }
        }
        return 0
    }
    
    /**
     * Calculates the needed rows.
     */
    fileprivate func calcRowCount(_ section: Int) -> Int {
        if tabTypesKeys.count == 0 {
            return 1
        }
        
        let tabKeys = tabTypesKeys[segmentView.indexOfSelectedSegment]
        switch tabKeys {
        case "BUS":
            if realTimeDepartures!.busses.count == 1 {
                return realTimeDepartures!.busses[busKeys[section]]!.count + 1
            } else if realTimeDepartures!.busses.count == 2 {
                return min(realTimeDepartures!.busses[busKeys[section]]!.count + 1, 8)
            }
            return min(realTimeDepartures!.busses[busKeys[section]]!.count + 1, 5)
        case "METRO":
            return min(realTimeDepartures!.metros[metroKeys[section]]!.count + 1, 4)
        case "TRAIN":
            return min(realTimeDepartures!.trains[trainKeys[section]]!.count + 1, 5)
        case "TRAM":
            return min(realTimeDepartures!.trams[tramKeys[section]]!.count + 1, 5)
        case "LOCAL-TRAM":
            return min(realTimeDepartures!.localTrams[localTramKeys[section]]!.count + 1, 5)
        case "SHIP":
            return min(realTimeDepartures!.boats[boatKeys[section]]!.count + 1, 5)
        default:
            return 0
        }
    }
    
    /**
     * Hadle load data (network) error
     * TODO: Refactoring, the service unavailable is used in many places.
     */
    fileprivate func handleLoadDataError() {
        stopRefreshTimmer()
        let invalidLoadingAlert = UIAlertController(
            title: "Service unavailable".localized,
            message: "Could not reach the search service.".localized,
            preferredStyle: UIAlertController.Style.alert)
        invalidLoadingAlert.addAction(
            UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: { _ in
                let _ = self.navigationController?.popToRootViewController(animated: false)
            }))
        
        present(invalidLoadingAlert, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

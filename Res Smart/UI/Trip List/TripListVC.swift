//
//  TripListVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class TripListVC: UITableViewController {
    
    let cellIdentifier = "TripCell"
    let loadingCellIdentifier = "LoadingCell"
    let loadMoreEarlierIdentifier = "LoadMoreEarlierRow"
    let loadMoreLaterIdentifier = "LoadMoreLaterRow"
    let noTripsFoundCell = "FoundNoTripsCell"
    
    let showDetailsSegue = "ShowDetails"
    let makeRoutineSegue = "MakeRoutine"
    
    var criterions: TripSearchCriterion?
    var routineTrip: RoutineTrip?
    var keys = [String]()
    var trips = Dictionary<String, [Trip]>()
    var selectedTrip: Trip?
    var isLoading = true
    var isLoadingMoreBlocked = false
    var isLoadingMore = false
    var refreshTimer: Timer?
    var headerHight = CGFloat(40)
    
    var loadMoreEarlier: LoadMoreCell?
    var loadMoreLater: LoadMoreCell?
    
    let loadedTime = Date()
    var firstTime = true
    
    var usedCriterions = [TripSearchCriterion]()
    
    /**
     * View is done loading
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StyleHelper.sharedInstance.background
        NotificationCenter.default.addObserver(
            self, selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(didBecomeInactive),
            name: UIApplication.willResignActiveNotification, object: nil)
        
        IJProgressView.shared.showProgressView(navigationController!.view)
        handleMakeRoutineButton()
    }
    
    /**
     * View about to appear
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLoadingMoreBlocked = false
        startRefreshTimmer()
        handleMakeRoutineButton()
        if trips.count == 0 {
            loadTripData(true)
        } else {
            reloadTableData()
            isLoading = false
        }
    }
    
    /**
     * View about to disappear
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRefreshTimmer()
    }
    
    /**
     * Returned to the app.
     */
    @objc func didBecomeActive() {
        let now = Date()
        if now.timeIntervalSince(loadedTime) > (60 * 60) { // 1 hour
            let _ = navigationController?.popToRootViewController(animated: false)
            return
        }
        refreshUI()
        startRefreshTimmer()
    }
    
    /**
     * Backgrounded.
     */
    @objc func didBecomeInactive() {
        stopRefreshTimmer()
    }
    
    /**
     * Start refresh timmer
     */
    func startRefreshTimmer() {
        stopRefreshTimmer()
        self.refreshTimer = Timer.scheduledTimer(
            timeInterval: 10, target: self, selector: #selector(refreshUI), userInfo: nil, repeats: true)
    }
    
    /**
     * Stop refresh timmer
     */
    func stopRefreshTimmer() {
        self.refreshTimer?.invalidate()
        self.refreshTimer = nil
    }
    
    /**
     * Refresh collection view.
     */
    @objc func refreshUI() {
        if navigationController?.topViewController == self {
            self.tableView?.reloadData()
            var flatTrips = [Trip]()
            for group in trips {
                for trip in group.value {
                    flatTrips.append(trip)
                }
            }
            
            for crit in usedCriterions {
                SearchTripService.tripRefresh(crit, tripsToRefresh: flatTrips, callback: {
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
                    }
                })
            }
        }
    }
    
    /**
     * Unwind (back) to this view.
     */
    @IBAction func unwindToTripListVC(_ segue: UIStoryboardSegue) {}
    
    @IBAction func unwindToManageRoutineTripsVC(_ segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        isLoadingMoreBlocked = true
        if segue.identifier == showDetailsSegue {
            let vc = segue.destination as! TripDetailsVC
            vc.trip = selectedTrip!
            
        } else if segue.identifier == makeRoutineSegue {
            let vc = segue.destination as! EditRoutineTripVC
            var routine = routineTrip
            if routine == nil {
                routine = RoutineTrip()
                routine!.criterions = criterions!.copy() as! TripSearchCriterion
            }
            routine?.criterions.searchForArrival = false
            routine?.criterions.date = nil
            routine?.criterions.time = nil
            vc.routineTrip = routine
            vc.isMakeRoutine = true
        }
    }
    
    /**
     * Load more trips when user scrolls
     * to the bottom of the list.
     */
    @objc func loadMoreTrips() {
        isLoadingMore = true
        loadMoreLater?.displaySpinner(1.0)
        
        let trip = trips[keys.last!]!.last!
        criterions!.searchForArrival = false
        criterions?.numTrips = 15
        
        criterions?.time = DateUtils.dateAsTimeString(
            trip.tripSegments.first!.departureDateTime.addingTimeInterval(60))
        loadTripData(true)
    }
    
    /**
     * Load earlier trips when user scrolls
     * to the top of the list.
     */
    @objc func loadEarlierTrips() {
        isLoadingMore = true
        loadMoreEarlier?.displaySpinner(1.0)
        
        let trip = trips[keys.first!]!.first!
        criterions?.searchForArrival = true
        criterions?.numTrips = 3
        
        let dateTuple = DateUtils.dateAsStringTuple(
            trip.tripSegments.last!.arrivalDateTime.addingTimeInterval(-60))
        criterions?.date = dateTuple.date
        criterions?.time = dateTuple.time
        
        loadTripData(false)
    }
    
    // MARK: UITableViewController
    
    /**
     * Number of sections
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isLoading || trips.count == 0 {
            return 1
        }
        return keys.count
    }
    
    /**
     * Item count for section
     */
    override func tableView(
        _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || trips.count == 0 {
            return 1
        }
        
        var count = trips[keys[section]]!.count
        if section == 0 {
            count += 1
        }
        if (section + 1) == trips.count {
            count += 1
        }
        return count
    }
    
    /**
     * Create cells for each data post.
     */
    override func tableView(
        _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            return createLoadingTripCell(indexPath)
        } else if trips.count == 0 {
            return createNoTripsFoundCell(indexPath)
        } else if isLoadMoreEarlierRow(indexPath) {
            return createLoadMoreEarlierCell(indexPath)
        } else if isLoadMoreLaterRow(indexPath) {
            return createLoadMoreLaterCell(indexPath)
        }
        
        return createTripCell(indexPath)
    }
    
    /**
     * Size for headers.
     */
    override func tableView(
        _ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isLoading || trips.count == 0  {
            return 0
        }
        return headerHight
    }
    
    /**
     * Size for footers.
     */
    override func tableView(
        _ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    /**
     * Size for rows.
     */
    override func tableView(
        _ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isLoading {
            return tableView.bounds.height - 49 - 64 - 20
        } else if isLoadMoreEarlierRow(indexPath) || isLoadMoreLaterRow(indexPath) {
            return 40
        }
        return 95
    }
    
    /**
     * User tapped a row.
     */
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        
        if !isLoadMoreEarlierRow(indexPath) && !isLoadMoreLaterRow(indexPath) {
            let key = keys[indexPath.section]
            var rowIdx = indexPath.row
            if indexPath.section == 0 {
                rowIdx = rowIdx - 1
            }
            
            selectedTrip = trips[key]![rowIdx]
            performSegue(withIdentifier: showDetailsSegue, sender: self)
        }
    }
    
    /**
     * View for header
     */
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: headerHight))
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.size.width, height: headerHight))
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.left
        
        if trips.count > 0 {
            let date = DateUtils.convertDateString("\(keys[section]) 00:00:00")
            label.text = DateUtils.friendlyDate(date) + ": " + criterions!.origin!.cleanName + " - " + criterions!.dest!.cleanName
        }
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.addSubview(label)
        
        return view
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
    
    // MARK: UIScrollViewDelegate
    
    /**
     * On scroll
     * Will check if we scrolled to bottom
     */
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height > 100 {
            let bottomEdge = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.height
            var overflow = scrollView.contentOffset.y - bottomEdge
            if scrollView.contentSize.height < scrollView.bounds.height {
                overflow =  scrollView.contentInset.top + scrollView.contentOffset.y
            }
            
            if !isLoadingMore && !isLoadingMoreBlocked {
                if overflow > -100 {
                    loadMoreTrips()
                } else {
                    loadMoreEarlier?.hideSpinner()
                    loadMoreLater?.hideSpinner()
                }
            }
        }
    }
    
    // MARK: Private methods
    
    /**
     * Loading the trip data, and starting background
     * collection of time table data.
     * TODO: Refactoring
     */
    fileprivate func loadTripData(_ shouldAppend: Bool) {
        if let criterions = self.criterions {
            usedCriterions.append(criterions.copy() as! TripSearchCriterion)
            NetworkActivity.displayActivityIndicator(true)
            criterions.numTrips = (criterions.searchForArrival) ? 4 : criterions.numTrips
            SearchTripService.tripSearch(
                criterions, callback: { (trips, slNetworkError) in
                    NetworkActivity.displayActivityIndicator(false)
                    DispatchQueue.main.async {
                        if slNetworkError != nil {
                            self.showNetworkErrorAlert()
                            self.isLoading = false
                            self.reloadTableData()
                            return
                        }
                        self.appendToDictionary(trips, shouldAppend: shouldAppend)
                        if trips.count == 0 {
                            self.navigationItem.rightBarButtonItem = nil
                        }
                        self.isLoading = false
                        self.isLoadingMore = false
                        self.loadMoreEarlier?.hideSpinner()
                        self.loadMoreLater?.hideSpinner()
                        self.updateDateCriterions()
                        if criterions.searchForArrival && self.firstTime {
                            self.tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentSize.height - 480.0)
                        }
                        
                        if shouldAppend && !self.firstTime {
                            IJProgressView.shared.hideProgressView()
                            self.tableView.reloadData()
                        } else {
                            self.reloadTableData()
                        }
                        self.firstTime = false
                    }
            })
            return
        }
        fatalError("Criterions not set in TripListVC")
    }
    
    /**
     * Appends search result to dictionary
     */
    fileprivate func appendToDictionary(_ tripsArr: [Trip], shouldAppend: Bool) {
        var newTripsArr = tripsArr
        if !shouldAppend {
            newTripsArr = newTripsArr.reversed()
        }
        for trip in newTripsArr {
            if let segment = trip.tripSegments.first {
                let destDateString = DateUtils.dateAsDateString(segment.departureDateTime)
                if !keys.contains(destDateString) {
                    if shouldAppend {
                        keys.append(destDateString)
                    } else {
                        keys.insert(destDateString, at: 0)
                    }
                    trips[destDateString] = [Trip]()
                }
                if shouldAppend {
                    trips[destDateString]!.append(trip)
                } else {
                    trips[destDateString]!.insert(trip, at: 0)
                }
            }
        }
    }
    
    /**
     * Checks if a day passed in the search result, and update
     * the search criterions in that case.
     */
    fileprivate func updateDateCriterions() {
        if trips.count > 0 {
            let cal = Calendar.current
            let trip = trips[keys.last!]!.last!
            
            let departDate = trip.tripSegments.last!.departureDateTime
            let departDay = (cal as NSCalendar).ordinality(of: .day, in: .year, for: departDate)
            let criterionDate = DateUtils.convertDateString("\(criterions!.date!) \(criterions!.time!)")
            let criterionDay = (cal as NSCalendar).ordinality(of: .day, in: .year, for: criterionDate)
            
            if departDay != criterionDay {
                criterions?.date = DateUtils.dateAsDateString(departDate)
            }
        }
    }
    
    /**
     * Create trip cell
     */
    fileprivate func createTripCell(
        _ indexPath: IndexPath) -> TripCell {
        let key = keys[indexPath.section]
        var idx = indexPath.row
        if indexPath.section == 0 {
            idx = idx - 1
        }
        
        let trip = trips[key]![idx]
        
        if !trip.isValid {
            let validTuple = trip.checkInvalidSegments()
            let cell = tableView!.dequeueReusableCell(
                withIdentifier: cellIdentifier, for: indexPath) as! TripCell
            cell.setupData(trip)
            let warningText = (validTuple.isCancelled) ? "Cancelled".localized : "Short transfer".localized
            cell.setCancelled(warningText)
            return cell
        }
        
        let cell = tableView!.dequeueReusableCell(
            withIdentifier: cellIdentifier, for: indexPath) as! TripCell
        cell.setupData(trip)
        return cell
    }
    
    /**
     * Create loading cell
     */
    fileprivate func createLoadingTripCell(
        _ indexPath: IndexPath) -> UITableViewCell {
        return tableView!.dequeueReusableCell(
            withIdentifier: loadingCellIdentifier, for: indexPath)
    }
    
    /**
     * Create "No trips found" cell
     */
    fileprivate func createNoTripsFoundCell(
        _ indexPath: IndexPath) -> UITableViewCell {
        return tableView!.dequeueReusableCell(
            withIdentifier: noTripsFoundCell, for: indexPath)
    }
    
    /**
     * Create "Load more" cell
     */
    fileprivate func createLoadMoreEarlierCell(
        _ indexPath: IndexPath) -> UITableViewCell {
        if loadMoreEarlier == nil {
            loadMoreEarlier = tableView!.dequeueReusableCell(
                withIdentifier: loadMoreEarlierIdentifier, for: indexPath) as? LoadMoreCell
            
            loadMoreEarlier!.loadButton.addTarget(
                self, action: #selector(loadEarlierTrips), for: UIControl.Event.touchUpInside)
        }
        
        return loadMoreEarlier!
    }
    
    /**
     * Create "Load more" cell
     */
    fileprivate func createLoadMoreLaterCell(
        _ indexPath: IndexPath) -> UITableViewCell {
        if loadMoreLater == nil {
            loadMoreLater = tableView!.dequeueReusableCell(
                withIdentifier: loadMoreLaterIdentifier, for: indexPath) as? LoadMoreCell
            
            loadMoreLater!.loadButton.accessibilityLabel = "Show more trips".localized
            loadMoreLater!.loadButton.addTarget(
                self, action: #selector(loadMoreTrips), for: UIControl.Event.touchUpInside)
        }
        
        return loadMoreLater!
    }
    
    /**
     * Show a network error alert
     */
    fileprivate func showNetworkErrorAlert() {
        IJProgressView.shared.hideProgressView()
        let networkErrorAlert = UIAlertController(
            title: "Service unavailable".localized,
            message: "Could not reach the search service.".localized,
            preferredStyle: UIAlertController.Style.alert)
        networkErrorAlert.addAction(
            UIAlertAction(title: "OK".localized, style: UIAlertAction.Style.default, handler: nil))
        
        present(networkErrorAlert, animated: true, completion: nil)
    }
    
    /**
     * Check if trip is in past.
     */
    fileprivate func checkInPast(_ trip: Trip) -> Bool{
        let date = trip.tripSegments.first!.departureDateTime
        return (Date().timeIntervalSince1970 >= date.timeIntervalSince1970)
    }
    
    /**
     * Checks if row is a "load more" row.
     */
    fileprivate func isLoadMoreEarlierRow(_ indexPath: IndexPath) -> Bool {
        return (indexPath.section == 0 && indexPath.row == 0)
    }
    
    /**
     * Checks if row is a "load more" row.
     */
    fileprivate func isLoadMoreLaterRow(_ indexPath: IndexPath) -> Bool {
        var rowCount = trips[keys[indexPath.section]]!.count
        if indexPath.section == 0 {
            rowCount = rowCount + 1
        }
        
        return (indexPath.section + 1) == trips.count &&
            (indexPath.row) == rowCount
    }
    
    /**
     * Checks if there should be a "Make routine" buttons.
     */
    fileprivate func handleMakeRoutineButton() {
        if routineTrip != nil && !routineTrip!.isSmartSuggestion {
            navigationItem.rightBarButtonItem = nil
            return
        }
        
        let allRoutines = RoutineTripsStore.sharedInstance.retriveRoutineTripsNoSuggestions()
        for routine in allRoutines {
            let testCrit = routine.criterions
            if testCrit.origin?.siteId == criterions?.origin?.siteId &&
                testCrit.dest?.siteId == criterions?.dest?.siteId {
                navigationItem.rightBarButtonItem = nil
                return
            }
        }
    }
    
    fileprivate func reloadTableData() {
        UIView.transition(with: self.tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }) { (_) in
            DispatchQueue.main.async {
                IJProgressView.shared.hideProgressView()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

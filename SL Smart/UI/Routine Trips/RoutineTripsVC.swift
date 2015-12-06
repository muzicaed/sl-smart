//
//  RoutineTripsVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class RoutineTripsVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellIdentifier = "RoutineTripCell"
    let simpleCellIdentifier = "SimpleRoutineTripCell"
    let loadingCellIdentifier = "LoadingCell"
    let headerCellIdentifier = "HeaderView"
    let showTripListSegue = "ShowTripList"
    let infoCellIdentifier = "InfoCell"
    
    var bestRoutineTrip: RoutineTrip?
    var otherRoutineTrips = [RoutineTrip]()
    var selectedRoutineTrip: RoutineTrip?
    var isShowMore = false
    var isLoading = true
    var isShowInfo = false
    var refreshButton: UIBarButtonItem?
    var lastReload: NSDate?
    var refreshTimer: NSTimer?
    
    
    /**
     * View is done loading
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationListeners()
        setupCollectionView()
        refreshButton = navigationItem.leftBarButtonItem
    }
    
    /**
     * View is about to display.
     */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hardLoadTripData()
    }
    
    /**
     * View is about to disappear.
     */
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    /**
     * Title tap
     */
    func onMoreTap() {
        if !self.isLoading {
            isShowMore = !isShowMore
            self.collectionView?.reloadSections(NSIndexSet(index: 1))
        }
    }
    
    /**
     * Prepares for segue
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let routineTrip = selectedRoutineTrip {
            if segue.identifier == showTripListSegue {
                let vc = segue.destinationViewController as! TripListVC
                let criterions = TripSearchCriterion(
                    origin: routineTrip.origin!, destination: routineTrip.destination!)
                
                let date = NSDate(timeIntervalSinceNow: (60 * 5) * -1)
                criterions.date = Utils.dateAsDateString(date)
                criterions.time = Utils.dateAsTimeString(date)
                
                vc.criterions = criterions
                vc.title = routineTrip.title
            }
        }
    }
    
    /**
     * Triggered when is about to go into backgorund.
     */
    func willResigningActive() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    /**
     * Triggered when is about to go into backgorund.
     */
    func didBecomeActive() {
        hardLoadTripData()
    }
    
    /**
     * On user taps refresh
     */
    @IBAction func onRefreshTap(sender: AnyObject) {
        hardLoadTripData()
    }
    
    /**
     * Unwind (back) to this view.
     */
    @IBAction func unwindToRoutineTripsVC(segue: UIStoryboardSegue) {}
    
    
    // MARK: UICollectionViewController
    
    /**
    * Section count
    */
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    /**
     * Item count for section
     */
    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
            if section == 0 {
                if isLoading || isShowInfo {
                    return 1
                }
                let bestCount = (bestRoutineTrip == nil ? 0 : 1)
                return bestCount
            }
            
            if isShowMore {
                return otherRoutineTrips.count
            }
            
            return 0
    }
    
    /**
     * Create cells for each data post.
     */
    override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            if indexPath.section == 0 {
                if isLoading {
                    return createLoadingTripCell(indexPath)
                } else if isShowInfo {
                    return createInfoTripCell(indexPath)
                }
                
                if let routineTrip = bestRoutineTrip {
                    return createRoutineTripCell(routineTrip, type: cellIdentifier, indexPath: indexPath)
                }
                fatalError("Could not create cell.")
            }
            return createRoutineTripCell(otherRoutineTrips[indexPath.row], type: simpleCellIdentifier, indexPath: indexPath)
    }
    
    /**
     * View for supplementary (header/footer)
     */
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(
            UICollectionElementKindSectionHeader,
            withReuseIdentifier: headerCellIdentifier,
            forIndexPath: indexPath) as! RoutineTripHeader
        
        if indexPath.section == 0 {
            return reusableView
        }
        
        reusableView.gestureRecognizers = [
            UITapGestureRecognizer(target: self, action: Selector("onMoreTap"))
        ]
        
        if isShowMore {
            reusableView.titleLabel.text = "Fler rutiner"
            reusableView.arrowLabel.text = "▲"
        } else {
            reusableView.titleLabel.text = "Visa fler rutiner"
            reusableView.arrowLabel.text = "▼"
        }
        return reusableView
    }
    
    /**
     * Size for items.
     */
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            
            let screenSize = UIScreen.mainScreen().bounds.size
            if indexPath.section == 0 {
                if isLoading {
                    return CGSizeMake(screenSize.width - 10, collectionView.bounds.height - 49 - 64 - 20)
                } else if isShowInfo {
                    return CGSizeMake(screenSize.width - 10, 345)
                }
                return CGSizeMake(screenSize.width - 10, 125)
            }
            
            return CGSizeMake(screenSize.width - 10, 90)
    }
    
    /**
     * Size for headers.
     */
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int) -> CGSize {
            
            if section == 0  {
                return CGSizeMake(0, 0)
            } else if section == 1 && otherRoutineTrips.count == 0 {
                return CGSizeMake(0, 0)
            }
            
            return CGSizeMake(self.collectionView!.frame.size.width, 50)
    }
    
    /**
     * User taps an item.
     */
    override func collectionView(
        collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
            if !isShowInfo {
                if indexPath.section == 0 {
                    selectedRoutineTrip = bestRoutineTrip
                } else {
                    selectedRoutineTrip = otherRoutineTrips[indexPath.row]
                }
                
                addScoreForSelectedRoutineTrip()
                performSegueWithIdentifier(showTripListSegue, sender: self)
            }
    }
    
    // MARK: Private methods
    
    /**
    * Adds score for selected routine trip.
    */
    private func addScoreForSelectedRoutineTrip() {
        if let trip = selectedRoutineTrip {
            var scorePosts = DataStore.sharedInstance.retrieveScorePosts()
            let currentLocation = MyLocationHelper.sharedInstance.currentLocation
            let dayOfWeek = Utils.getDayOfWeek()
            let hourOfDay = Utils.getHourOfDay()
            let originId = trip.origin!.siteId
            let destinationId = trip.destination!.siteId
            
            ScorePostHelper.changeScore(dayOfWeek, hourOfDay: hourOfDay,
                siteId: originId, isOrigin: true, scoreMod: 1,
                location: currentLocation, scorePosts: &scorePosts)
            ScorePostHelper.changeScore(dayOfWeek, hourOfDay: hourOfDay,
                siteId: destinationId, isOrigin: false, scoreMod: 2,
                location: currentLocation, scorePosts: &scorePosts)
            DataStore.sharedInstance.writeScorePosts(scorePosts)
        }
    }
    
    /**
     * Setup collection view properties and layout.
     */
    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 10, 0)
        
        collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        collectionView?.collectionViewLayout = flowLayout
        collectionView?.delegate = self
        
        StandardGradient.addLayer(view)
        
        let wrapper = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let imageView = UIImageView(
            image: UIImage(named: "TrainSplash")?.imageWithRenderingMode(.AlwaysTemplate))
        imageView.tintColor = UIColor.whiteColor()
        imageView.frame.size = CGSizeMake(30, 30)
        imageView.frame.origin.y = 5
        imageView.frame.origin.x = 6
        
        wrapper.addSubview(imageView)
        self.navigationItem.titleView = wrapper
    }
    
    /**
     * Setup notification listeners.
     */
    private func setupNotificationListeners() {
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: Selector("willResigningActive"),
            name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: Selector("didBecomeActive"),
            name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    /**
     * Loading the trip data, and starting background
     * collection of time table data.
     * Will show big spinner when loading.
     */
    private func hardLoadTripData() {
        if DataStore.sharedInstance.isRoutineTripsEmpty() {
            isShowInfo = true
            isLoading = false
            self.refreshButton?.enabled = false
        } else {
            refreshTimer?.invalidate()
            refreshTimer = nil
            otherRoutineTrips = [RoutineTrip]()
            bestRoutineTrip = nil
            selectedRoutineTrip = nil
            isShowMore = false
            isShowInfo = false
            self.isLoading = true
            refreshButton?.enabled = false
            collectionView?.reloadData()
            lastReload = NSDate()
            RoutineService.findRoutineTrip({ routineTrips in
                if routineTrips.count > 0 {
                    self.bestRoutineTrip = routineTrips.first!
                    self.otherRoutineTrips = Array(routineTrips[1..<routineTrips.count])
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tripSearchDone()
                        self.collectionView?.reloadSections(NSIndexSet(index: 1))
                    })
                }
            })
        }
    }
    
    /**
     * Refresh the time table.
     * Will show navbar spinner when loading.
     */
    func refreshTripData() {
        if !isShowInfo {
            refreshTimer?.invalidate()
            refreshTimer = nil
            if NSDate().timeIntervalSinceDate(lastReload!) < 300.0 {
                navigationItem.leftBarButtonItem = createNavSpinner()
                dispatch_async(dispatch_get_main_queue(), {
                    self.tripSearchDone()
                })
            } else {
                hardLoadTripData()
            }
            lastReload = NSDate()
        }
    }
    
    /**
     * Creates a loading spinner in NavBar
     *
     */
    private func createNavSpinner() -> UIBarButtonItem {
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.frame.size.width = 20
        
        return UIBarButtonItem(customView: spinner)
    }
  
    /**
     * On trip search done.
     */
    private func tripSearchDone() {
        self.isLoading = false
        self.refreshButton?.enabled = true
        self.navigationItem.leftBarButtonItem = self.refreshButton
        self.collectionView?.reloadData()
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(
            20, target: self, selector: "refreshTripData", userInfo: nil, repeats: true)
    }
    
    /**
     * Create best trip cell
     */
    private func createRoutineTripCell(trip: RoutineTrip, type: String, indexPath: NSIndexPath) -> RoutineTripCell {
        let cell = collectionView!.dequeueReusableCellWithReuseIdentifier(type,
            forIndexPath: indexPath) as! RoutineTripCell
        cell.setupData(trip)
        return cell
    }
    
    /**
     * Create loading trip cell
     */
    private func createLoadingTripCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView!.dequeueReusableCellWithReuseIdentifier(loadingCellIdentifier,
            forIndexPath: indexPath)
    }
    
    /**
     * Create info trip cell
     */
    private func createInfoTripCell(indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView!.dequeueReusableCellWithReuseIdentifier(infoCellIdentifier,
            forIndexPath: indexPath)
    }
    
    deinit {
        print("Deinit: RoutineTripsVC")
    }
}
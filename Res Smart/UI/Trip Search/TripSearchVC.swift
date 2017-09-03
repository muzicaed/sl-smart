//
//  TripSearchVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class TripSearchVC: UITableViewController, LocationSearchResponder,
DateTimePickResponder, PickLocationResponder, TravelTypesResponder,
PickGenericValueResponder, LinePickerResponder {
  
  let notificationCenter = NotificationCenter.default
  var searchLocationType: String?
  var selectedDate = Date()
  var criterions: TripSearchCriterion?
  var dimmer: UIView?
  var isViaSelected = false
  var isAdvancedMode = false
  
  var searchButton = UIButton(type: .custom)
  
  @IBOutlet weak var viaLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var destinationArrivalSegmented: UISegmentedControl!
  @IBOutlet weak var advancedToggleButton: UIBarButtonItem!
  @IBOutlet weak var locationPickerRow: LocationPickerRow!
  @IBOutlet weak var travelTypePicker:  TravelTypesPickerRow!
  
  @IBOutlet weak var isAlternative: UITableViewCell!
  @IBOutlet weak var maxWalkLabel: UILabel!
  @IBOutlet weak var numberOfChangesLabel: UILabel!
  @IBOutlet weak var changeTimeLabel: UILabel!
  @IBOutlet weak var linesLabel: UILabel!
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.isEditing = true
    criterions = SearchCriterionStore.sharedInstance.retrieveSearchCriterions()
    restoreUIFromCriterions()
    createDimmer()
    createNotificationListners()
    locationPickerRow.delegate = self
    locationPickerRow.prepareGestures()
    prepareSearchButton()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.view.addSubview(searchButton)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    searchButton.removeFromSuperview()
  }
  
  /**
   * Before seque is triggred.
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if let crit = criterions {
      if segue.identifier == "SearchOriginLocation" {
        let vc = segue.destination as! SearchLocationVC
        vc.delegate = self
        vc.searchOnlyForStations = false
        vc.allowCurrentPosition = true
        vc.allowNearbyStations = true
        vc.title = "Choose from".localized
        searchLocationType = "Origin"
        
      } else if segue.identifier == "SearchDestinationLocation" {
        let vc = segue.destination as! SearchLocationVC
        vc.delegate = self
        vc.searchOnlyForStations = false
        vc.allowCurrentPosition = true
        vc.allowNearbyStations = true
        vc.title = "Choose to".localized
        searchLocationType = "Destination"
        
      } else if segue.identifier == "SearchViaLocation" {
        let vc = segue.destination as! SearchLocationVC
        vc.delegate = self
        vc.searchOnlyForStations = true
        vc.title = "Choose via stop".localized
        searchLocationType = "Via"
        
      } else if segue.identifier == "ShowTripList" {
        let vc = segue.destination as! TripListVC
        vc.criterions = criterions?.copy() as? TripSearchCriterion
        SearchCriterionStore.sharedInstance.writeLastSearchCriterions(crit)
        RoutineService.addHabitRoutine(crit)
        
      } else if segue.identifier == "ShowDateTimePicker" {
        let vc = segue.destination as! DateTimePickerVC
        vc.selectedDate = selectedDate
        vc.delegate = self
        UIView.animate(withDuration: 0.35, animations: {
          self.dimmer?.alpha = 0.7
        })
        
      } else if segue.identifier == "ShowTravelTypesPicker" {
        let vc = segue.destination as! TravelTypesVC
        vc.delegate = self
        if let crit = criterions {
          vc.setData(crit)
        }
        
      } else if segue.identifier == "MaxWalkDistance" {
        let vc = segue.destination as! GenericValuePickerVC
        vc.delegate = self
        vc.title = "Walking distance".localized
        vc.setValue(crit.maxWalkDist, valueType: .WalkDistance)
        
      } else if segue.identifier == "NumberOfChanges" {
        let vc = segue.destination as! GenericValuePickerVC
        vc.delegate = self
        vc.title = "No. of transfers".localized
        vc.setValue(crit.numChg, valueType: .NoOfChanges)
        
      } else if segue.identifier == "ChangeTime" {
        let vc = segue.destination as! GenericValuePickerVC
        vc.delegate = self
        vc.title = "Extra transfer time".localized
        vc.setValue(crit.minChgTime, valueType: .TimeForChange)
        
      } else if segue.identifier == "PickLines" {
        let vc = segue.destination as! LinePickerVC
        vc.delegate = self
        vc.incText = crit.lineInc
        vc.excText = crit.lineExc
      }
    }
  }
  
  /**
   * Validate if segue should be performed.
   */
  override func shouldPerformSegue(
    withIdentifier identifier: String, sender: Any?)
    -> Bool {
      if identifier == "ShowTripList" {
        if criterions?.dest == nil || criterions?.origin == nil ||
          (criterions?.origin?.siteId == criterions?.dest?.siteId && criterions?.origin?.siteId != "0") {
          showInvalidLocationAlert()
          return false
        } else if criterions?.via != nil && (
          criterions?.via?.siteId == criterions?.origin?.siteId ||
            criterions?.via?.siteId == criterions?.dest?.siteId) {
          showInvalidViaAlert()
        }
      }
      return true
  }
  
  @IBAction func onAdvancedButtonTap(_ sender: UIBarButtonItem) {
    isAdvancedMode = !isAdvancedMode
    sender.title = (isAdvancedMode) ? "Simple".localized : "Advanced".localized
    criterions?.isAdvanced = isAdvancedMode
    travelTypePicker.updateLabel(criterions!)
    if isAdvancedMode {
      viaLabel.text = "(Choose stop)".localized
    } else {
      resetViaStation()
      criterions?.resetAdvancedTripTypes()
      updateGenericValues()
    }
    
    animateAdvancedToggle()
  }
  
  /**
   * Changed if departure time or arrival time
   */
  @IBAction func onDepartureArrivalChanged(_ sender: UISegmentedControl) {
    if let crit = criterions {
      crit.searchForArrival = (destinationArrivalSegmented.selectedSegmentIndex == 1)
    }
  }
  
  @IBAction func unwindToStationSearchParent(_ segue: UIStoryboardSegue) {}
  
  // MARK: LocationSearchResponder
  
  /**
   * Triggered when location is selected on location search VC.
   */
  func selectedLocationFromSearch(_ location: Location) {
    if let crit = criterions, let locationType = searchLocationType {
      switch locationType {
      case "Origin":
        crit.origin = location
        locationPickerRow.setOriginLabelLocation(location)
      case "Destination":
        crit.dest = location
        locationPickerRow.setDestinationLabelLocation(location)
      case "Via":
        crit.via = location
        viaLabel.text = location.name
        isViaSelected = true
        tableView.reloadData()
      default: break
      }
    }
    searchLocationType = nil
  }
  
  // MARK: DateTimePickResponder
  
  /**
   * Triggered whem date and time is picked
   */
  func pickedDate(_ date: Date?) -> Void {
    if let crit = criterions, let date = date {
      let dateTimeTuple = DateUtils.dateAsStringTuple(date)
      crit.date = dateTimeTuple.date
      crit.time = dateTimeTuple.time
      timeLabel.text = DateUtils.friendlyDateAndTime(date)
      selectedDate = date
    }
    UIView.animate(withDuration: 0.2, animations: {
      self.dimmer?.alpha = 0.0
    })
  }
  
  // MARK: PickLocationResponder
  
  /**
   * Called when user taped on orign or destination row.
   */
  func pickLocation(_ isOrigin: Bool) {
    if isOrigin {
      performSegue(withIdentifier: "SearchOriginLocation", sender: self)
    } else {
      performSegue(withIdentifier: "SearchDestinationLocation", sender: self)
    }
  }
  
  /**
   * User tapped switch location.
   */
  func switchTapped() {
    tableView.beginUpdates()
    if let crit = criterions {
      let oldOrigin = crit.origin
      let oldOriginId = crit.originId
      crit.origin = crit.dest
      crit.originId = crit.destId
      crit.dest = oldOrigin
      crit.destId = oldOriginId
      
      locationPickerRow.setOriginLabelLocation(crit.origin)
      locationPickerRow.setDestinationLabelLocation(crit.dest)
    }
    tableView.endUpdates()
  }
  
  // MARK: PickGenericValueResponder
  
  /**
   * User picked a value using the generic value picker.
   */
  func pickedValue(_ type: GenericValuePickerVC.ValueType, value: Int) {
    if let crit = criterions {
      switch type {
      case .WalkDistance:
        crit.maxWalkDist = value
      case .NoOfChanges:
        crit.numChg = value
      case .TimeForChange:
        crit.minChgTime = value
      }
      updateGenericValues()
    }
  }
  
  // MARK: LinePickerResponder
  
  func pickedLines(_ included: String?, excluded: String?) {
    if let crit = criterions {
      crit.lineInc = included
      crit.lineExc = excluded
      updateGenericValues()
    }
  }
  
  // MARK: TravelTypesResponder
  
  func selectedTravelType(
    _ useMetro: Bool, useTrain: Bool,
    useTram: Bool, useBus: Bool,
    useBoat: Bool
    ) {
    criterions?.useMetro = useMetro
    criterions?.useTrain = useTrain
    criterions?.useTram = useTram
    criterions?.useBus = useBus
    criterions?.useFerry = useBoat
    criterions?.useShip = useBoat
    if let crit = criterions {
      travelTypePicker.updateLabel(crit)
    }
  }
  
  // MARK: UITableViewController
  
  /**
   * Section count
   */
  override func numberOfSections(in tableView: UITableView) -> Int {
    return (isAdvancedMode) ? 6 : 3
  }
  
  /**
   * Row count in section
   */
  override func tableView(
    _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if section == 0 {
      return (isAdvancedMode) ? 2 : 1
    } else if section > 2 {
      return 2
    }
    
    return 1
  }
  
  /**
   * User selected row
   */
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 4 && indexPath.row == 1 {
      if let crit = criterions {
        crit.unsharp = !crit.unsharp
        updateGenericValues()
        tableView.deselectRow(at: indexPath, animated: true)
      }
    } else if indexPath.section == 2 {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  /**
   * Height for rows.
   */
  override func tableView(
    _ tableView: UITableView,
    heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    if indexPath.section == 0 && indexPath.row == 0 {
      return 88
    }
    return 44
  }
  
  /**
   * Can row be edited?
   */
  override func tableView(
    _ tableView: UITableView,
    canEditRowAt indexPath: IndexPath) -> Bool{
    return (indexPath.section == 0 && indexPath.row == 1 && isViaSelected && isAdvancedMode)
  }
  
  /**
   * Editing style
   */
  override func tableView(
    _ tableView: UITableView,
    editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return (indexPath.section == 0 && indexPath.row == 1) ? .delete : .none
  }
  
  /**
   * Green highlight on selected row.
   */
  override func tableView(
    _ tableView: UITableView, willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath) {
    
    let bgColorView = UIView()
    bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
    cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * Edit actions. (Only used for clear Via station)
   */
  override func tableView(
    _ tableView: UITableView,
    editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    return [UITableViewRowAction(
      style: UITableViewRowActionStyle.normal,
    title: "Clear".localized) { (_, _) -> Void in
      self.resetViaStation()
      tableView.reloadData()
      }]
  }
  
  /**
   * Restores UI from criterions.
   */
  @objc func restoreUIFromCriterions() {
    if let crit = criterions {
      isAdvancedMode = crit.isAdvanced
      advancedToggleButton.title = (isAdvancedMode) ? "Simple".localized : "Advanced".localized
      locationPickerRow.setOriginLabelLocation(crit.origin)
      locationPickerRow.setDestinationLabelLocation(crit.dest)
      
      if crit.via != nil {
        viaLabel.text = crit.via!.name
        isViaSelected = true
      }
      
      travelTypePicker.updateLabel(crit)
      updateGenericValues()
      crit.searchForArrival = false
      destinationArrivalSegmented.selectedSegmentIndex = (crit.searchForArrival) ? 1 : 0
      pickedDate(Date())
    }
    tableView.reloadData()
  }
  
  // MARK: Private
  
  /**
   * Animates the table view on advanced toggle.
   */
  fileprivate func animateAdvancedToggle() {
    tableView.beginUpdates()
    if isAdvancedMode {
      tableView.insertRows(
        at: [IndexPath(row: 1, section: 0)], with: .automatic)
      tableView.insertSections(IndexSet(integer: 3), with: .automatic)
      tableView.insertSections(IndexSet(integer: 4), with: .automatic)
      tableView.insertSections(IndexSet(integer: 5), with: .automatic)
    } else {
      tableView.deleteRows(
        at: [IndexPath(row: 1, section: 0)], with: .automatic)
      tableView.deleteSections(IndexSet(integer: 3), with: .automatic)
      tableView.deleteSections(IndexSet(integer: 4), with: .automatic)
      tableView.deleteSections(IndexSet(integer: 5), with: .automatic)
    }
    tableView.endUpdates()
  }
  
  /**
   * Show a invalid location alert
   */
  fileprivate func showInvalidLocationAlert() {
    let invalidLocationAlert = UIAlertController(
      title: "Stop missing".localized,
      message: "\"from\" and \"to\" needs to be two different stations.".localized,
      preferredStyle: UIAlertControllerStyle.alert)
    invalidLocationAlert.addAction(
      UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.default, handler: nil))
    
    present(invalidLocationAlert, animated: true, completion: nil)
  }
  
  /**
   * Show a invalid via location alert
   */
  fileprivate func showInvalidViaAlert() {
    let invalidLocationAlert = UIAlertController(
      title: "Incorrect \"Via stop\"".localized,
      message: "Via can not be the same station as \"from\" or \"to\".".localized,
      preferredStyle: UIAlertControllerStyle.alert)
    invalidLocationAlert.addAction(
      UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.default, handler: nil))
    
    present(invalidLocationAlert, animated: true, completion: nil)
  }
  
  /**
   * Creates a screen dimmer for date/time picker.
   */
  fileprivate func createDimmer() {
    dimmer = UIView(frame: CGRect(origin: CGPoint.zero, size: view.bounds.size))
    dimmer!.isUserInteractionEnabled = false
    dimmer!.backgroundColor = UIColor.black
    dimmer!.alpha = 0.0
    view.addSubview(dimmer!)
  }
  
  /**
   * Resets the via station selector.
   */
  fileprivate func resetViaStation() {
    self.isViaSelected = false
    self.criterions?.via = nil
    self.viaLabel.text = "(Choose stop)".localized
  }
  
  /**
   * Updates generic value picker labels
   */
  fileprivate func updateGenericValues() {
    if let crit = criterions {
      switch crit.maxWalkDist {
      case 1000, 2000:
        maxWalkLabel.text = String(format: "Max %d km".localized, crit.maxWalkDist / 1000)
      default:
        maxWalkLabel.text = String(format: "Max %d m".localized, crit.maxWalkDist)
      }
      
      switch crit.numChg {
      case -1:
        numberOfChangesLabel.text = "No limitations for no. of transfers".localized
      case 0:
        numberOfChangesLabel.text = "No transfers".localized
      case 1:
        numberOfChangesLabel.text = "Högst 1 byte".localized
      default:
        numberOfChangesLabel.text = String(format: "Max %d transfers".localized, crit.numChg)
      }
      
      switch crit.minChgTime {
      case 0:
        changeTimeLabel.text = "No extra time for transfer".localized
      default:
        changeTimeLabel.text = String(format: "%d minutes extra for transfer".localized, crit.minChgTime)
      }
      
      isAlternative.accessoryType = .none
      if crit.unsharp {
        isAlternative.accessoryType = .checkmark
      }
      
      if crit.lineInc == nil && crit.lineExc == nil {
        linesLabel.text = "All lines".localized
      } else if crit.lineInc != nil {
        linesLabel.text = "\("Only use:".localized) \(crit.lineInc!)"
      } else if crit.lineExc != nil {
        linesLabel.text = "\("Don't use:".localized) \(crit.lineExc!)"
      }
    }
  }
  
  /**
   * Add listners for notfication events.
   */
  fileprivate func createNotificationListners() {
    notificationCenter.addObserver(
      self,
      selector: #selector(restoreUIFromCriterions),
      name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
  }

  /**
   * Prepare floating search button
   */
  fileprivate func prepareSearchButton() {
    searchButton.setTitle("Search".localized, for: .normal)
    searchButton.frame = CGRect(x: 0, y: 0, width: 140, height: 50)
    searchButton.frame.origin.x = 10
    searchButton.frame.origin.y = tableView.frame.size.height - searchButton.frame.size.height - 60
    searchButton.backgroundColor = StyleHelper.sharedInstance.mainGreen
    searchButton.clipsToBounds = false
    searchButton.layer.shadowColor = UIColor.black.cgColor
    searchButton.layer.shadowOffset = CGSize(width: 1, height: 1)
    searchButton.layer.shadowOpacity = 0.35
    searchButton.layer.cornerRadius = 6
    searchButton.addTarget(self, action: #selector(onSearchTap), for: .touchUpInside)
    tableView.tableFooterView = UIView(
      frame: CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.frame.size.width, height: 65))
    )
  }
  
  @objc func onSearchTap() {
    performSegue(withIdentifier: "ShowTripList", sender: self)
  }
  
  /**
   * Deinit
   */
  deinit {
    notificationCenter.removeObserver(self)
  }
}

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

class RealTimeVC: UITableViewController {
  
  @IBOutlet weak var topView: UIView!
  
  var realTimeDepartures: RealTimeDepartures?
  
  /**
   * On load
   */
  override func viewDidLoad() {
    tableView.tableFooterView = UIView()
    view.backgroundColor = StyleHelper.sharedInstance.background
    topView.frame.size.height = 0
    loadData()
  }
  
  // MARK: Private
  
  /**
  * Load real time data
  */
  private func loadData() {
    RealTimeDeparturesService.fetch(1002) { (rtDepartures, error) -> Void in
      if error == nil {
        if let departures = rtDepartures {
          dispatch_async(dispatch_get_main_queue(),{
            self.realTimeDepartures = departures
            self.prepareSegmentView()
          })
        }
      }
    }
  }
  
  /**
   * Prepares Segment View
   */
  private func prepareSegmentView() {
    let segmentView = SMSegmentView(
      frame: CGRect(x: 0, y: 0, width: 100.0, height: 0),
      separatorColour: UIColor.darkGrayColor(),
      separatorWidth: 1.0,
      segmentProperties: [
        keySegmentTitleFont: UIFont.systemFontOfSize(12.0),
        keySegmentOnSelectionColour: StyleHelper.sharedInstance.mainGreen,
        keySegmentOffSelectionColour: UIColor.clearColor(),
        keyContentVerticalMargin: 5.0])
    
    var tabCount = 0
    if realTimeDepartures?.busses.count > 0 {
      tabCount++
      segmentView.addSegmentWithTitle(nil,
        onSelectionImage: UIImage(named: "BUS-NEUTRAL"),
        offSelectionImage: UIImage(named: "BUS-NEUTRAL"))
    }
    
    if tabCount > 1 {
      segmentView.selectSegmentAtIndex(0)
      segmentView.frame.size.width = CGFloat(50 * tabCount)
      topView.addSubview(segmentView)
      
      UIView.animateWithDuration(0.3, animations: {
        self.topView.frame.size.height = 44
        segmentView.frame.size.height = 44
      })
    }
  }
}
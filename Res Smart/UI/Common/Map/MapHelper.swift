//
//  MapHelper.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-01-25.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation
import MapKit

class MapHelper {
    
    
    /**
     * Centers and zooms map
     */
    static func setMapViewport(_ mapView: MKMapView, coordinates: [CLLocationCoordinate2D], topPadding: CGFloat) {
        var newCoordinates = coordinates
        let allPolyline = MKPolyline(coordinates: &newCoordinates, count: newCoordinates.count)
        
        mapView.setVisibleMapRect(
            mapView.mapRectThatFits(allPolyline.boundingMapRect),
            edgePadding: UIEdgeInsets(top: topPadding, left: 25, bottom: 75, right: 25),
            animated: true)
    }
}

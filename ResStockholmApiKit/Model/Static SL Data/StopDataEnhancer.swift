//
//  StopDataEnhancer.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-07.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

class StopDataEnhancer {

  static func enhance(stop: StaticStop) {
    
  }
  
  static func pos(lon: String, _ lat: String) -> CLLocation {
    return CLLocation(latitude: Double(lat)!, longitude: Double(lon)!)
  }
 
  
  static let enhanceData = [
    
    // Blue line ////////////////////////////
    
    // Hjulsta
    "3481": (
      ent: [
        (n: "Hjulsta", loc: StopDataEnhancer.pos("59.39618", "17.888"), trnPos: 2, chgTo: [])
      ]
    ),
    // Tensta
    "3471": (
      ent: [
        (n: "Tenstaplan", loc: StopDataEnhancer.pos("59.394832", "17.899057"), trnPos: 0, chgTo: []),
        (n: "Tensta centrum", loc: StopDataEnhancer.pos("59.393958", "17.904228"), trnPos: 2, chgTo: [])
      ]
    ),
    // Rinkeby
    "3461": (
      ent: [
        (n: "Rinkebystråket", loc: StopDataEnhancer.pos("59.38875", "17.92884"), trnPos: 2, chgTo: []),
        (n: "Rinkebytorget", loc: StopDataEnhancer.pos("59.38831", "17.92825"), trnPos: 2, chgTo: [])
      ]
    ),
    // Rissne
    "3451": (
      ent: [
        (n: "Rissne", loc: StopDataEnhancer.pos("59.375649", "17.939901"), trnPos: 0, chgTo: [])
      ]
    ),
    // Duvbo
    "3441": (
      ent: [
        (n: "Duvbo", loc: StopDataEnhancer.pos("59.367822", "17.964942"), trnPos: 2, chgTo: [])
      ]
    ),
    // Sundbybergs centrum
    "3431": (
      ent: [
        (n: "Landsvägen/Pendeltåg", loc: StopDataEnhancer.pos("59.360748", "17.9709"), trnPos: 2, chgTo: ["J35"]),
        (n: "Lysgränd", loc: StopDataEnhancer.pos("59.360748", "17.9709"), trnPos: 2, chgTo: []),
        (n: "Stationsgatan", loc: StopDataEnhancer.pos("59.363126", "17.970453"), trnPos: 0, chgTo: []),
        (n: "Järnvägsgatan", loc: StopDataEnhancer.pos("59.360936", "17.972566"), trnPos: 2, chgTo: [])
      ]
    ),
    // Solna strand
    "3421": (
      ent: [
        (n: "Solna Strand", loc: StopDataEnhancer.pos("59.35451", "17.97336"), trnPos: 0, chgTo: [])
      ]
    ),
    // Huvudsta
    "3411": (
      ent: [
        (n: "Bygatan", loc: StopDataEnhancer.pos("59.349821", "17.985942"), trnPos: 0, chgTo: []),
        (n: "Huvudsta centrum", loc: StopDataEnhancer.pos("59.349821", "17.985942"), trnPos: 0, chgTo: []),
      ]
    ),
    // Västra Skogen
    "3201": (
      ent: [
        (n: "Västra skogen", loc: StopDataEnhancer.pos("59.34765", "18.00349"), trnPos: 2, chgTo: [])
      ]
    ),
    // Stadshagen
    "3161": (
      ent: [
        (n: "S:t Görans sjukhus", loc: StopDataEnhancer.pos("59.33623", "18.01841"), trnPos: 2, chgTo: []),
        (n: "Mariedalsvägen/Hornsberg", loc: StopDataEnhancer.pos("59.33833", "18.01409"), trnPos: 0, chgTo: []),
        (n: "Kellgrensgatan", loc: StopDataEnhancer.pos("59.33686", "18.01671"), trnPos: 2, chgTo: []),
        (n: "Stadshagens idrottsplats", loc: StopDataEnhancer.pos("59.33675", "18.01779"), trnPos: 2, chgTo: [])
      ]
    ),
    // Fridhemsplan
    "1151": (
      ent: [
        (n: "St Eriksgatan 43T", loc: StopDataEnhancer.pos("59.334169", "18.032146"), trnPos: 2, chgTo: []),
        (n: "St Eriksgatan 40A", loc: StopDataEnhancer.pos("59.334324", "18.032580"), trnPos: 2, chgTo: []),
        (n: "St Eriksg./Fleming.", loc: StopDataEnhancer.pos("59.334399", "18.032786"), trnPos: 2, chgTo: []),
        (n: "Drottningholmsvägen", loc: StopDataEnhancer.pos("59.33221", "18.02897"), trnPos: 0, chgTo: ["T17", "T18", "T19"]),
        (n: "Fridhemsgatan", loc: StopDataEnhancer.pos("59.332436", "18.028839"), trnPos: 0, chgTo: []),
        (n: "Mariebergsgatan", loc: StopDataEnhancer.pos("59.334953", "18.025167"), trnPos: 0, chgTo: []),
        (n: "Byte till blåa", loc: StopDataEnhancer.pos("59.333662", "18.029192"), trnPos: 1, chgTo: ["T10", "T11"]),
      ]
    )
  ]
}
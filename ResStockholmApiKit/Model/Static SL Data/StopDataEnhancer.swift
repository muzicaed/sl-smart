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
    
    // T Centralen
    "1051": (
      ent: [
        (n: "Drottningg. vid Åhléns", loc: StopDataEnhancer.pos("59.3324791", "18.0624992"), trnPos: 2, chgTo: []),
        (n: "Sergels Torg/Drottning.", loc: StopDataEnhancer.pos("59.332201", "18.063242"), trnPos: 2, chgTo: []),
        (n: "Sergels Torg", loc: StopDataEnhancer.pos("59.332280", "18.063527"), trnPos: 2, chgTo: []),
        (n: "Klara kyrka", loc: StopDataEnhancer.pos("59.330933", "18.060536"), trnPos: 0, chgTo: []),
        (n: "Vasagatan 22", loc: StopDataEnhancer.pos("59.330669", "18.059553"), trnPos: 0, chgTo: []),
        (n: "Centralplan", loc: StopDataEnhancer.pos("59.330344", "18.059255"), trnPos: 0, chgTo: ["J35", "J36", "J37", "J38"]),
        (n: "Från platformen", loc: StopDataEnhancer.pos("59.331354", "18.0614891"), trnPos: 0, chgTo: ["T10", "T11", "T13", "T14", "T17", "T18", "T18"])
      ]
    ),
    
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
        (n: "Från platformen", loc: StopDataEnhancer.pos("59.333662", "18.029192"), trnPos: 1, chgTo: ["T10", "T11"])
      ]
    ),
    // Rådhuset
    "3131": (
      ent: [
        (n: "Landstingshuset", loc: StopDataEnhancer.pos("59.329917", "18.041868"), trnPos: 0, chgTo: []),
        (n: "Pipersg./Kungsholmsg.", loc: StopDataEnhancer.pos("59.331165", "18.045977"), trnPos: 2, chgTo: []),
        (n: "Hantverkargatan", loc: StopDataEnhancer.pos("59.328724", "18.047276"), trnPos: 2, chgTo: []),
        (n: "Kungsklippan", loc: StopDataEnhancer.pos("59.330273", "18.046814"), trnPos: 2, chgTo: []),
        (n: "Rådhuset/Kungsholmsv.", loc: StopDataEnhancer.pos("59.33036", "18.042094"), trnPos: 0, chgTo: []),
        (n: "Polishuset", loc: StopDataEnhancer.pos("59.330355", "18.041074"), trnPos: 0, chgTo: [])
      ]
    ),    
    // Kungsträdgården
    "3031": (
      ent: [
        (n: "Arsenalsgatan", loc: StopDataEnhancer.pos("59.330678", "18.073851"), trnPos: 0, chgTo: []),
        (n: "Jakobsgatan/Regeringsgatan", loc: StopDataEnhancer.pos("59.330021", "18.068991"), trnPos: 1, chgTo: [])
      ]
    ),
    
    
    // Green line ////////////////////////////
    
    
    // S:t Eriksplan
    "1141": (
      ent: [
        (n: "Sankt Eriksgatan", loc: StopDataEnhancer.pos("59.341703", "18.037748"), trnPos: 2, chgTo: []),
        (n: "Rörstrandsgatan", loc: StopDataEnhancer.pos("59.339777", "18.036418"), trnPos: 0, chgTo: []),
        (n: "Sankt Eriksg./Odeng.", loc: StopDataEnhancer.pos("59.339602", "18.037233"), trnPos: 0, chgTo: []),
        (n: "Gångtunnel", loc: StopDataEnhancer.pos("59.339340", "18.037273"), trnPos: 0, chgTo: [])
      ]
    ),
    // Odenplan
    "1131": (
      ent: [
        (n: "Odenplan", loc: StopDataEnhancer.pos("59.342929", "18.049947"), trnPos: 2, chgTo: []),
        (n: "Karlbergsvägen", loc: StopDataEnhancer.pos("59.343142", "18.049904"), trnPos: 2, chgTo: []),
        (n: "Karlbergsvägen/Västmannagatan", loc: StopDataEnhancer.pos("59.342983", "18.045537"), trnPos: 0, chgTo: []),
        (n: "Karlbergsvägen vid Swedbank", loc: StopDataEnhancer.pos("59.343131", "18.049572"), trnPos: 2, chgTo: [])
      ]
    ),
    
    // Rådmansgatan
    "1121": (
      ent: [
        (n: "Sveavägen/Rådmansgatan", loc: StopDataEnhancer.pos("59.340259", "18.05926"), trnPos: 2, chgTo: []),
        (n: "Sveav./Rådmansg. vid Jensens", loc: StopDataEnhancer.pos("59.340275", "18.058788"), trnPos: 2, chgTo: []),
        (n: "Handelshögskolan vid Pressbyrån", loc: StopDataEnhancer.pos("59.342152", "18.056931"), trnPos: 0, chgTo: []),
        (n: "Rehnsgatan", loc: StopDataEnhancer.pos("59.342374", "18.057346"), trnPos: 0, chgTo: []),
      ]
    ),

  ]
}
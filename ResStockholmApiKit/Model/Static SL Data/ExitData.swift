//
//  ExitData.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-07.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

class ExitData {
  
  static func getExits(stopId: String) -> [StaticExit] {
    if let exitData = enhanceData[stopId] {
      return exitData
    }    
    return [StaticExit]()
  }
  
  static func pos(lat: String, _ lon: String) -> CLLocation {
    return CLLocation(latitude: Double(lat)!, longitude: Double(lon)!)
  }
  
  
  static let enhanceData = [
    
    // T Centralen
    "1051": [
      StaticExit(name: "Drottningg. vid Åhléns", location: ExitData.pos("59.3324791", "18.0624992"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Sergels Torg/Drottning.", location: ExitData.pos("59.332201", "18.063242"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Sergels Torg", location: ExitData.pos("59.332280", "18.063527"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Klara kyrka", location: ExitData.pos("59.330933", "18.060536"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Vasagatan 22", location: ExitData.pos("59.330669", "18.059553"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Centralplan", location: ExitData.pos("59.330344", "18.059255"), trainPosition: 0, changeToLines: ["J35", "J36", "J37", "J38"]),
      StaticExit(name: "Från platformen", location: ExitData.pos("59.331354", "18.0614891"), trainPosition: 0, changeToLines: ["T10", "T11", "T13", "T14", "T17", "T18", "T18"])
    ],
    
    // Blue line ////////////////////////////
    
    // Hjulsta
    "3481": [
      StaticExit(name: "Hjulsta", location: ExitData.pos("59.39618", "17.888"), trainPosition: 2, changeToLines: [])
    ],
    // Tensta
    "3471": [
      StaticExit(name: "Tenstaplan", location: ExitData.pos("59.394832", "17.899057"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Tensta centrum", location: ExitData.pos("59.393958", "17.904228"), trainPosition: 2, changeToLines: [])
    ],
    // Rinkeby
    "3461": [
      StaticExit(name: "Rinkebystråket", location: ExitData.pos("59.38875", "17.92884"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Rinkebytorget", location: ExitData.pos("59.38831", "17.92825"), trainPosition: 2, changeToLines: [])
    ],
    // Rissne
    "3451": [
      StaticExit(name: "Rissne", location: ExitData.pos("59.375649", "17.939901"), trainPosition: 0, changeToLines: [])
    ],
    // Duvbo
    "3441": [
      StaticExit(name: "Duvbo", location: ExitData.pos("59.367822", "17.964942"), trainPosition: 2, changeToLines: [])
    ],
    // Sundbybergs centrum
    "3431": [
      StaticExit(name: "Landsvägen/Pendeltåg", location: ExitData.pos("59.360748", "17.9709"), trainPosition: 2, changeToLines: ["J35", "L22"]),
      StaticExit(name: "Lysgränd", location: ExitData.pos("59.360748", "17.9709"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Stationsgatan", location: ExitData.pos("59.363126", "17.970453"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Järnvägsgatan", location: ExitData.pos("59.360936", "17.972566"), trainPosition: 2, changeToLines: [])
    ],
    // Solna strand
    "3421": [
      StaticExit(name: "Solna Strand", location: ExitData.pos("59.35451", "17.97336"), trainPosition: 0, changeToLines: [])
    ],
    // Huvudsta
    "3411": [
      StaticExit(name: "Bygatan", location: ExitData.pos("59.349821", "17.985942"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Huvudsta centrum", location: ExitData.pos("59.349821", "17.985942"), trainPosition: 0, changeToLines: []),
    ],
    // Västra Skogen
    "3201": [
      StaticExit(name: "Västra skogen", location: ExitData.pos("59.34765", "18.00349"), trainPosition: 2, changeToLines: [])
    ],
    // Stadshagen
    "3161": [
      StaticExit(name: "S:t Görans sjukhus", location: ExitData.pos("59.33623", "18.01841"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Mariedalsvägen/Hornsberg", location: ExitData.pos("59.33833", "18.01409"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Kellgrensgatan", location: ExitData.pos("59.33686", "18.01671"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Stadshagens idrottsplats", location: ExitData.pos("59.33675", "18.01779"), trainPosition: 2, changeToLines: [])
    ],
    // Fridhemsplan TODO: Check blue vs green
    "1151": [
      StaticExit(name: "St Eriksgatan 43T", location: ExitData.pos("59.334169", "18.032146"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "St Eriksgatan 40A", location: ExitData.pos("59.334324", "18.032580"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "St Eriksg./Fleming.", location: ExitData.pos("59.334399", "18.032786"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Drottningholmsvägen", location: ExitData.pos("59.33221", "18.02897"), trainPosition: 0, changeToLines: ["T17", "T18", "T19"]),
      StaticExit(name: "Fridhemsgatan", location: ExitData.pos("59.332436", "18.028839"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Mariebergsgatan", location: ExitData.pos("59.334953", "18.025167"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Från platformen", location: ExitData.pos("59.333662", "18.029192"), trainPosition: 1, changeToLines: ["T10", "T11"])
    ],
    // Rådhuset
    "3131": [
      StaticExit(name: "Landstingshuset", location: ExitData.pos("59.329917", "18.041868"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Pipersg./Kungsholmsg.", location: ExitData.pos("59.331165", "18.045977"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Hantverkargatan", location: ExitData.pos("59.328724", "18.047276"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Kungsklippan", location: ExitData.pos("59.330273", "18.046814"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Rådhuset/Kungsholmsv.", location: ExitData.pos("59.33036", "18.042094"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Polishuset", location: ExitData.pos("59.330355", "18.041074"), trainPosition: 0, changeToLines: [])
    ],
    // Kungsträdgården
    "3031": [
      StaticExit(name: "Arsenalsgatan", location: ExitData.pos("59.330678", "18.073851"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Jakobsgatan/Regeringsgatan", location: ExitData.pos("59.330021", "18.068991"), trainPosition: 1, changeToLines: [])
    ],
    // Akalla
    "3271": [
      StaticExit(name: "Akalla torg", location: ExitData.pos("59.415441", "17.913369"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Sibeliusgången/Nystadsg.", location: ExitData.pos("59.413863", "17.917736"), trainPosition: 2, changeToLines: [])
    ],
    // Husby
    "3261": [
      StaticExit(name: "Bergengatan", location: ExitData.pos("59.408152", "17.928786"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Trondheimsg./Husby C", location: ExitData.pos("59.409998", "17.925889"), trainPosition: 0, changeToLines: [])
    ],
    // Kista
    "3251": [
      StaticExit(name: "Kista Galleria", location: ExitData.pos("59.402282", "17.943689"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Danmarksgatan", location: ExitData.pos("59.40206", "17.94402"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Köpenhamnsgatan", location: ExitData.pos("59.40366", "17.94216"), trainPosition: 0, changeToLines: [])
    ],
    // Hallonbergen
    "3231": [
      StaticExit(name: "Hallonbergen", location: ExitData.pos("59.37541", "17.96929"), trainPosition: 0, changeToLines: [])
    ],
    // Näckrosen
    "3221": [
      StaticExit(name: "Skogsbacken", location: ExitData.pos("59.368445", "17.97963"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Råsunda östra", location: ExitData.pos("59.3668", "17.98431"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Filmstaden", location: ExitData.pos("59.36637", "17.98306"), trainPosition: 2, changeToLines: [])
    ],
    // Solna centrum
    "3211": [
      StaticExit(name: "Skytteholms IP Solnahallen", location: ExitData.pos("59.36089", "17.99664"), trainPosition: 0, changeToLines: ["L22"]),
      StaticExit(name: "Råsunda östra", location: ExitData.pos("59.36129", "17.99782"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Centrumslingan", location: ExitData.pos("59.36101", "17.99845"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Solna centrum", location: ExitData.pos("59.35857", "17.99927"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Buss 177", location: ExitData.pos("59.36125", "17.99694"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Fotbollstadion västra", location: ExitData.pos("59.36158", "17.99623"), trainPosition: 0, changeToLines: [])
    ],
    
    // Green line ////////////////////////////
        
    // S:t Eriksplan
    "1141": [
      StaticExit(name: "Sankt Eriksgatan", location: ExitData.pos("59.341703", "18.037748"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Rörstrandsgatan", location: ExitData.pos("59.339777", "18.036418"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Sankt Eriksg./Odeng.", location: ExitData.pos("59.339602", "18.037233"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Gångtunnel", location: ExitData.pos("59.339340", "18.037273"), trainPosition: 0, changeToLines: [])
    ],
    // Odenplan
    "1131": [
      StaticExit(name: "Odenplan", location: ExitData.pos("59.342929", "18.049947"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Karlbergsvägen", location: ExitData.pos("59.343142", "18.049904"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Karlbergsvägen/Västmannagatan", location: ExitData.pos("59.342983", "18.045537"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Karlbergsvägen vid Swedbank", location: ExitData.pos("59.343131", "18.049572"), trainPosition: 2, changeToLines: [])
    ],
    // Rådmansgatan
    "1121": [
      StaticExit(name: "Sveavägen/Rådmansgatan", location: ExitData.pos("59.340259", "18.05926"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Sveav./Rådmansg. vid Jensens", location: ExitData.pos("59.340275", "18.058788"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Handelshögskolan vid Pressbyrån", location: ExitData.pos("59.342152", "18.056931"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Rehnsgatan", location: ExitData.pos("59.342374", "18.057346"), trainPosition: 0, changeToLines: []),
    ],
    
    ]
}
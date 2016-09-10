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
    // Fridhemsplan
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
    
    // Hässelby strand
    "1331": [
      StaticExit(name: "Hässelby strand", location: ExitData.pos("59.361064", "17.832141"), trainPosition: 0, changeToLines: [])
    ],
    // Hässelby gård
    "1321": [
      StaticExit(name: "Hässelby gård", location: ExitData.pos("59.36695", "17.84337"), trainPosition: 0, changeToLines: [])
    ],
    // Johannelund
    "1301": [
      StaticExit(name: "Johannelund", location: ExitData.pos("59.368079", "17.858158"), trainPosition: 1, changeToLines: [])
    ],
    // Vällingby
    "1311": [
      StaticExit(name: "Vällingbyplan", location: ExitData.pos("59.36308", "17.87257"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Vällingbyplan 13", location: ExitData.pos("59.363142", "17.871657"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Kirunaplan", location: ExitData.pos("59.363410", "17.871785"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Vällingbyplan 15", location: ExitData.pos("59.363534", "17.872303"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Lyckselevägen", location: ExitData.pos("59.3644", "17.86962"), trainPosition: 0, changeToLines: [])
    ],
    // Råcksta
    "1281": [
      StaticExit(name: "Råcksta", location: ExitData.pos("59.35527", "17.88216"), trainPosition: 0, changeToLines: [])
    ],
    // Blackeberg
    "1271": [
      StaticExit(name: "Vinjettgatan (vid Direkten)", location: ExitData.pos("59.348204", "17.883484"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Vinjettgatan (vid 7-Eleven)", location: ExitData.pos("59.348142", "17.883199"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Blackebergs torg", location: ExitData.pos("59.347917", "17.883672"), trainPosition: 2, changeToLines: [])
    ],
    // Islandstorget
    "1261": [
      StaticExit(name: "Islandstorget", location: ExitData.pos("59.346", "17.89299"), trainPosition: 0, changeToLines: [])
    ],
    // Ängbyplan
    "1251": [
      StaticExit(name: "Ängbyplan", location: ExitData.pos("59.342097", "17.906685"), trainPosition: 0, changeToLines: [])
    ],
    // Åkeshov
    "1241": [
      StaticExit(name: "Åkeshovs slott/udarskogen", location: ExitData.pos("59.341873", "17.925514"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Åkeshovs sim- och idrottshall", location: ExitData.pos("59.342628", "17.926168"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Från platformen", location: ExitData.pos("59.335709", "18.077385"), trainPosition: 1, changeToLines: ["T17", "T18", "T19"])
    ],
    // Brommaplan
    "1231": [
      StaticExit(name: "Brommaplan", location: ExitData.pos("59.33835", "17.9388"), trainPosition: 0, changeToLines: [])
    ],
    // Abrahamsberg
    "1221": [
      StaticExit(name: "Abrahemsberg", location: ExitData.pos("59.336434", "17.952626"), trainPosition: 0, changeToLines: [])
    ],
    // Stora mossen
    "1211": [
      StaticExit(name: "Stora Mossen", location: ExitData.pos("59.3343", "17.96672"), trainPosition: 2, changeToLines: [])
    ],
    // Alvik
    "1201": [
      StaticExit(name: "Alviks torg", location: ExitData.pos("59.333042", "17.980167"), trainPosition: 0, changeToLines: ["L22"]),
      StaticExit(name: "Tranebergsvägen", location: ExitData.pos("59.333469", "17.983879"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Från platformen", location: ExitData.pos("59.335709", "18.077385"), trainPosition: 1, changeToLines: ["T17", "T18", "T19"]),
    ],
    // Kristineberg
    "1171": [
      StaticExit(name: "Kristineberg", location: ExitData.pos("59.33289", "18.00303"), trainPosition: 0, changeToLines: [])
    ],
    // Thorildsplan
    "1161": [
      StaticExit(name: "Thorildsplan", location: ExitData.pos("59.33179", "18.01599"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Lärarhögskolan", location: ExitData.pos("59.33112", "18.01606"), trainPosition: 2, changeToLines: [])
    ],
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
    // Hötorget
    "1111": [
      StaticExit(name: "Kungsg vid Telia", location: ExitData.pos("59.33575", "18.063744"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Sergelg/Hötorget", location: ExitData.pos("59.334426", "18.063744"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Sveav/Malmskillnadsg", location: ExitData.pos("59.334393", "18.064903"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Malmskillnadsg", location: ExitData.pos("59.334557", "18.065482"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Kungsg/Sveav vid Adidas", location: ExitData.pos("59.335499", "18.062972"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Hötorget/Konserthuset", location: ExitData.pos("59.335324", "18.063154"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Kungsg vid Cervera", location: ExitData.pos("59.335603", "18.064334"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Sveav/Tunnelg", location: ExitData.pos("59.336587", "18.062854"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Sveav/Olof Palmes gata", location: ExitData.pos("59.336341", "18.062446"), trainPosition: 0, changeToLines: [])
    ],
    
    
    // Red line ////////////////////////////
    
    // Mörby Centrum
    "2301": [
      StaticExit(name: "Golfvägen", location: ExitData.pos("59.39826", "18.03594"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Mörbyplan", location: ExitData.pos("59.39843", "18.03573"), trainPosition: 1, changeToLines: [])
    ],
    // Danderyds sjukhus
    "2251": [
      StaticExit(name: "Danderyds sjukhus", location: ExitData.pos("59.392298", "18.040152"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Mörbyskolan Vendevägen", location: ExitData.pos("59.392161", "18.041686"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Mörbylund Inverness", location: ExitData.pos("59.3899", "18.042115"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Bussterminal", location: ExitData.pos("59.390113", "18.04293"), trainPosition: 2, changeToLines: [])
    ],
    // Bergshamra
    "2241": [
      StaticExit(name: "Bergshamra centrum", location: ExitData.pos("59.38155", "18.0363"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Gamla vägen", location: ExitData.pos("59.379409", "18.038059"), trainPosition: 2, changeToLines: [])
    ],
    // Universitetet
    "2231": [
      StaticExit(name: "Universitetet", location: ExitData.pos("59.36522", "18.05492"), trainPosition: 2, changeToLines: [])
    ],
    // Tekniska högskolan
    "2221": [
      StaticExit(name: "Danderydsgatan", location: ExitData.pos("59.345078", "18.07131"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Tekniska högskolan", location: ExitData.pos("59.345962", "18.071598"), trainPosition: 0, changeToLines: ["L27", "L28", "L29"]),
      StaticExit(name: "Bussar", location: ExitData.pos("59.34561", "18.071697"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Körsbärsvägen", location: ExitData.pos("59.347292", "18.066886"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Odengatan", location: ExitData.pos("59.34663", "18.065717"), trainPosition: 2, changeToLines: [])
    ],
    // Stadion
    "2211": [
      StaticExit(name: "Grev Turegatan", location: ExitData.pos("59.342667", "18.081316"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Musikhögskolan", location: ExitData.pos("59.343503", "18.080928"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Valhallavägen", location: ExitData.pos("59.342864", "18.082017"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Karlavägen/Nybrogatan", location: ExitData.pos("59.339798", "18.081330"), trainPosition: 2, changeToLines: [])
    ],
    // Östermalmstorg
    "2101": [
      StaticExit(name: "Sibyllegatan", location: ExitData.pos("59.33621", "18.079934"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Östermalmstorg/Nybrog.", location: ExitData.pos("59.336418", "18.07884"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Grev Turegatan", location: ExitData.pos("59.33505", "18.074688"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Birger Jarlsgatan", location: ExitData.pos("59.335055", "18.073862"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Birger Jarlsg./Jakobsbergsg.", location: ExitData.pos("59.334809", "18.073701"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Birger Jarlsg./Mäster Samuelsg.", location: ExitData.pos("59.334618", "18.073937"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Från platformen", location: ExitData.pos("59.335709", "18.077385"), trainPosition: 1, changeToLines: ["T13", "T14"])
    ],
    // Gamla stan
    "1021": [
      StaticExit(name: "Riddarholmen", location: ExitData.pos("59.322962", "18.066605"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Munkbroleden Södermalm", location: ExitData.pos("59.323043", "18.067613"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Gamla Stan", location: ExitData.pos("59.323384", "18.068162"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Från platformen", location: ExitData.pos("59.335709", "18.077385"), trainPosition: 1, changeToLines: ["T13", "T14", "T17", "T18", "T19"])
    ],
    // Slussen
    "1011": [
      StaticExit(name: "Götgatan", location: ExitData.pos("59.318165", "18.071415"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Södermalmstorg", location: ExitData.pos("59.319659", "18.072263"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Slussenterminalen", location: ExitData.pos("59.320152", "18.072134"), trainPosition: 2, changeToLines: ["L25", "L26"]),
      StaticExit(name: "Från platformen", location: ExitData.pos("59.335709", "18.077385"), trainPosition: 1, changeToLines: ["T13", "T14", "T17", "T18", "T19"])
    ],
    // Mariatorget
    "2511": [
      StaticExit(name: "Torkel Knutssonsgatan", location: ExitData.pos("59.317251", "18.057747"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Mariatorget", location: ExitData.pos("59.316965", "18.063292"), trainPosition: 0, changeToLines: [])
    ],
    // Zinkensdamm
    "2521": [
      StaticExit(name: "Zinkensdamm", location: ExitData.pos("59.317716", "18.05006"), trainPosition: 1, changeToLines: [])
    ],
    // Hornstull
    "2531": [
      StaticExit(name: "Långholmsgatan/Högalidsgatan", location: ExitData.pos("59.315744", "18.034209"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Högalidsparken", location: ExitData.pos("59.316575", "18.038637"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Hornstull", location: ExitData.pos("59.315744", "18.034209"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Bergsunds strand", location: ExitData.pos("59.315703", "18.03345"), trainPosition: 2, changeToLines: [])
    ],
    // Liljeholmen
    "2601": [
      StaticExit(name: "Liljeholmstorget (inomhus)", location: ExitData.pos("59.310073", "18.022192"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Liljeholmsvägen/Tvärbana", location: ExitData.pos("59.310877", "18.024251"), trainPosition: 1, changeToLines: ["L22"]),
      StaticExit(name: "Trekanten", location: ExitData.pos("59.31056", "18.021601"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Hissbana/Nybohov", location: ExitData.pos("59.308680", "18.016616"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Liljeholmstorget (utomhus)", location: ExitData.pos("59.310192", "18.022118"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Liljeholmsvägen Höger", location: ExitData.pos("59.310832", "18.024180"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Bussterminal", location: ExitData.pos("59.310102", "18.022563"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Från platformen", location: ExitData.pos("59.335709", "18.077385"), trainPosition: 1, changeToLines: ["T13", "T14"])
    ],
    // Aspudden
    "2611": [
      StaticExit(name: "Aspudden", location: ExitData.pos("59.30642", "18.001142"), trainPosition: 1, changeToLines: [])
    ],
    // Örnsberg
    "2621": [
      StaticExit(name: "Örnsberg", location: ExitData.pos("59.305522", "17.989447"), trainPosition: 0, changeToLines: [])
    ],
    // Axelsberg
    "2631": [
      StaticExit(name: "Axelsberg", location: ExitData.pos("59.304540", "17.974860"), trainPosition: 0, changeToLines: [])
    ],
    // Mälarhöjden
    "2641": [
      StaticExit(name: "Mälarhöjden", location: ExitData.pos("59.301058", "17.957035"), trainPosition: 0, changeToLines: [])
    ],
    // Bredäng
    "2651": [
      StaticExit(name: "Bredängstorget", location: ExitData.pos("59.29478", "17.934333"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Bredängshallen", location: ExitData.pos("59.294802", "17.934086"), trainPosition: 0, changeToLines: [])
    ],
    // Sätra
    "2701": [
      StaticExit(name: "Sätra", location: ExitData.pos("59.285545", "17.920396"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Sätra Torg", location: ExitData.pos("59.284952", "17.922394"), trainPosition: 0, changeToLines: [])
    ],
    // Skärholmen
    "2711": [
      StaticExit(name: "Skärholmstorget", location: ExitData.pos("59.2767", "17.90629"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Skärholmsplan", location: ExitData.pos("59.27678", "17.90867"), trainPosition: 2, changeToLines: [])
    ],
    // Vårberg
    "2721": [
      StaticExit(name: "Fjärdholmsgränd", location: ExitData.pos("59.27596", "17.88987"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Vårberg centrum", location: ExitData.pos("59.27575", "17.8893"), trainPosition: 2, changeToLines: [])
    ],
    // Vårby gård
    "2731": [
      StaticExit(name: "Vårby gård", location: ExitData.pos("59.264521", "17.884444"), trainPosition: 2, changeToLines: [])
    ],
    // Masmo
    "2741": [
      StaticExit(name: "Masmo", location: ExitData.pos("59.24979", "17.881376"), trainPosition: 1, changeToLines: [])
    ],
    // Fittja
    "2751": [
      StaticExit(name: "Fittja", location: ExitData.pos("59.247859", "17.861162"), trainPosition: 0, changeToLines: [])
    ],
    // Alby
    "2761": [
      StaticExit(name: "Alby Centrum", location: ExitData.pos("59.238789", "17.84479"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Albyberget", location: ExitData.pos("59.239969", "17.846164"), trainPosition: 0, changeToLines: [])
    ],
    // Hallunda
    "2771": [
      StaticExit(name: "Hallunda torg", location: ExitData.pos("59.24416", "17.82604"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Eriksberg", location: ExitData.pos("59.24265", "17.82613"), trainPosition: 0, changeToLines: [])
    ],
    // Norsborg
    "2781": [
      StaticExit(name: "Bussar", location: ExitData.pos("59.24395", "17.81424"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Norsborgs centrum", location: ExitData.pos("59.24431", "17.81427"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Eriksberg", location: ExitData.pos("59.24305", "17.81436"), trainPosition: 0, changeToLines: [])
    ],
    // Ropsten
    "2131": [
      StaticExit(name: "Bussar", location: ExitData.pos("59.35741", "18.10276"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Gasverksvägen", location: ExitData.pos("59.35745", "18.102304"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Artemisgatan", location: ExitData.pos("59.35557", "18.09972"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Jägmästargatan", location: ExitData.pos("59.35479", "18.09809"), trainPosition: 2, changeToLines: [])
    ],
    // Gärdet
    "2121": [
      StaticExit(name: "Brantingsg./Askrikeg.", location: ExitData.pos("59.34468", "18.09847"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Värtavä./Sandhamnsg.", location: ExitData.pos("59.34781", "18.10143"), trainPosition: 0, changeToLines: [])
    ],
    // Karlaplan
    "2111": [
      StaticExit(name: "Karlaplan Nordväst", location: ExitData.pos("59.338437", "18.090255"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Karlaplan Nordöst", location: ExitData.pos("59.338349", "18.090953"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Valhallav./Värtav.", location: ExitData.pos("59.340292", "18.093849"), trainPosition: 0, changeToLines: []),
      StaticExit(name: "Valhallav./Tessinparken", location: ExitData.pos("59.340729", "18.093013"), trainPosition: 0, changeToLines: [])
    ],
    // Midsommarkransen
    "2811": [
      StaticExit(name: "Tegelbruksv./SL Sporthall", location: ExitData.pos("59.302509", "18.010701"), trainPosition: 1, changeToLines: []),
      StaticExit(name: "Svandammsvägen", location: ExitData.pos("59.30154", "18.012471"), trainPosition: 1, changeToLines: []),
    ],
    // Telefonplan
    "2821": [
      StaticExit(name: "Telefonplan", location: ExitData.pos("59.298182", "17.996750"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Mikrofonvägen", location: ExitData.pos("59.298073", "17.996947"), trainPosition: 2, changeToLines: [])
    ],
    // Hägerstensåsen
    "2831": [
      StaticExit(name: "Personnevägen", location: ExitData.pos("59.294287", "17.976294"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Hägerstensåsen", location: ExitData.pos("59.295558", "17.979448"), trainPosition: 0, changeToLines: [])
    ],
    // Västertorp
    "2841": [
      StaticExit(name: "Västertorpsvägen", location: ExitData.pos("59.29058", "17.96519"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Störtloppsvägen", location: ExitData.pos("59.29215", "17.96854"), trainPosition: 0, changeToLines: [])
    ],
    // Fruängen
    "2851": [
      StaticExit(name: "Fruängsplan", location: ExitData.pos("59.28566", "17.96499"), trainPosition: 2, changeToLines: []),
      StaticExit(name: "Fruängstorget", location: ExitData.pos("59.28586", "17.96479"), trainPosition: 2, changeToLines: [])
    ]
  ]
}
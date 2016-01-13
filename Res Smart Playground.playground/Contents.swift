//: Playground - noun: a place where people can play

import Cocoa


/**
 * Helper. Fixes broken UTF-8 encoding that sometimes
 * occur in the SL Api
 */
func fixBrokenEncoding(str: String) -> String {
  var fixedStr = str.stringByReplacingOccurrencesOfString("Ã¥", withString: "å")
  fixedStr = fixedStr.stringByReplacingOccurrencesOfString("Ã¤", withString: "ä")
  fixedStr = fixedStr.stringByReplacingOccurrencesOfString("Ã¶", withString: "ö")
  fixedStr = fixedStr.stringByReplacingOccurrencesOfString("Ã…", withString: "Å")
  fixedStr = fixedStr.stringByReplacingOccurrencesOfString("Ã„", withString: "Ä")
  fixedStr = fixedStr.stringByReplacingOccurrencesOfString("Ã–", withString: "Ö")
  return fixedStr
}


let test1 = "Brommavägen"
let test2 = "BrÃ¥mmavÃ¤gen"

print(fixBrokenEncoding(test1))
print(fixBrokenEncoding(test2))
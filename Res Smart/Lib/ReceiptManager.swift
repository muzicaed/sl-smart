//
//  ReceiptManager.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2016-01-03.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

class ReceiptManager {
  
  static private let secret = "b45d638c835947888d7d9a6204295b3c"
  static private let appStoreReceiptURL = NSBundle.mainBundle().appStoreReceiptURL
  static private let errorDate = NSDate(timeIntervalSince1970: 0)
  
  /**
   * Validate purchase receipt
   */
  static func validateReceipt(onCompletion: (Bool, NSDate) -> Void) {
    
    validateReceiptInternal(
      appStoreReceiptURL, isProd: true) { (statusCode: Int?, date: NSDate) -> Void in
        guard let status = statusCode else {
          onCompletion(false, date)
          return
        }
        
        if status == 21007 {
          self.validateReceiptInternal(
            appStoreReceiptURL, isProd: false) { (statusCode: Int?, date: NSDate) -> Void in
              guard let statusValue = statusCode else {
                onCompletion(false, date)
                return
              }
              
              // 0 if the receipt is valid
              if statusValue == 0 {
                onCompletion(true, date)
              } else {
                onCompletion(false, date)
              }
          }
          
          // 0 if the receipt is valid
        } else if status == 0 {
          onCompletion(true, date)
        } else {
          onCompletion(false, date)
        }
    }
  }
  
  // MARK: Private methods
  
  /**
  * Get receipt data
  */
  static private func receiptData(appStoreReceiptURL : NSURL?) -> NSData? {
    
    guard let receiptURL = appStoreReceiptURL,
      receipt = NSData(contentsOfURL: receiptURL) else {
        return nil
    }
    
    do {
      let receiptData = receipt.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
      let requestContents = ["receipt-data": receiptData, "password": secret]
      let requestData = try NSJSONSerialization.dataWithJSONObject(requestContents, options: [])
      return requestData
    }
    catch {
      return nil
    }
  }
  
  /**
   * Perform validation
   */
  static private func validateReceiptInternal(
    appStoreReceiptURL : NSURL?, isProd: Bool , onCompletion: (Int?, NSDate) -> Void) {
      
      let serverURL = isProd ? "https://buy.itunes.apple.com/verifyReceipt" : "https://sandbox.itunes.apple.com/verifyReceipt"
      
      guard let receiptData = receiptData(appStoreReceiptURL),
        url = NSURL(string: serverURL)  else {
          onCompletion(nil, errorDate)
          return
      }
      
      let request = NSMutableURLRequest(URL: url)
      request.HTTPMethod = "POST"
      request.HTTPBody = receiptData
      
      let task = NSURLSession.sharedSession().dataTaskWithRequest(request,
        completionHandler: {data, response, error -> Void in
          
          guard let data = data where error == nil else {
            onCompletion(nil, errorDate)
            return
          }
          
          do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options:[])
            guard let statusCode = json["status"] as? Int else {
              onCompletion(nil, errorDate)
              return
            }
            
            var date = errorDate
            if statusCode == 0 {
              if let reciepts = json["latest_receipt_info"] as? Array<[String: String]> {
                if let reciept = reciepts.last {
                  if let timeStr = reciept["expires_date_ms"] {
                    date = NSDate(timeIntervalSince1970: Double(timeStr)! / 1000)
                  }
                }
              }

            }
            onCompletion(statusCode, date)
          }
          catch {
            onCompletion(nil, errorDate)
          }
      })
      task.resume()
  }
}
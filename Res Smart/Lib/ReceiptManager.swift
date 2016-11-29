//
//  ReceiptManager.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2016-01-03.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

class ReceiptManager {
  
  static fileprivate let secret = "b45d638c835947888d7d9a6204295b3c"
  static fileprivate let appStoreReceiptURL = Bundle.main.appStoreReceiptURL
  static fileprivate let errorDate = Date(timeIntervalSince1970: 0)
  
  /**
   * Validate purchase receipt
   */
  static func validateReceipt(_ onCompletion: @escaping (Bool, Date) -> Void) {
    
    validateReceiptInternal(
      appStoreReceiptURL, isProd: true) { (statusCode: Int?, date: Date) -> Void in
        guard let status = statusCode else {
          onCompletion(false, date)
          return
        }
        
        if status == 21007 {
          self.validateReceiptInternal(
            appStoreReceiptURL, isProd: false) { (statusCode: Int?, date: Date) -> Void in
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
  static fileprivate func receiptData(_ appStoreReceiptURL : URL?) -> Data? {
    
    guard let receiptURL = appStoreReceiptURL,
      let receipt = try? Data(contentsOf: receiptURL) else {
        return nil
    }
    
    do {
      let receiptData = receipt.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
      let requestContents = ["receipt-data": receiptData, "password": secret]
      let requestData = try JSONSerialization.data(withJSONObject: requestContents, options: [])
      return requestData
    }
    catch {
      return nil
    }
  }
  
  /**
   * Perform validation
   */
  static fileprivate func validateReceiptInternal(
    _ appStoreReceiptURL : URL?, isProd: Bool , onCompletion: @escaping (Int?, Date) -> Void) {
      
      let serverURL = isProd ? "https://buy.itunes.apple.com/verifyReceipt" : "https://sandbox.itunes.apple.com/verifyReceipt"
      
      guard let receiptData = receiptData(appStoreReceiptURL),
        let url = URL(string: serverURL)  else {
          onCompletion(nil, errorDate)
          return
      }
      
      let request = NSMutableURLRequest(url: url)
      request.httpMethod = "POST"
      request.httpBody = receiptData
      
      let task = URLSession.shared.dataTask(with: request,
        completionHandler: {data, response, error -> Void in
          
          guard let data = data, error == nil else {
            onCompletion(nil, errorDate)
            return
          }
          
          do {
            let json = try JSONSerialization.jsonObject(with: data, options:[])
            guard let statusCode = json["status"] as? Int else {
              onCompletion(nil, errorDate)
              return
            }
            
            var date = errorDate
            if statusCode == 0 {
              if let reciepts = json["latest_receipt_info"] as? Array<[String: String]> {
                if let reciept = reciepts.last {
                  if let timeStr = reciept["expires_date_ms"] {
                    date = Date(timeIntervalSince1970: Double(timeStr)! / 1000)
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

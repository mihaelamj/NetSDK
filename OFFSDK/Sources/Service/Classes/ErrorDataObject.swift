//
//  ErrorDataObject.swift
//  ViewingAPI
//
//  Created by Mihaela Mihaljevic Jakic on 30/05/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

import Foundation

/*"{
 \"error\":\"invalid_request\",
 \"error_description\":\"The grant type was not specified in the request\"}"
 
 {
 "error": 1,
 "error_message": "User already exists"
 }
 
 {
 "error": "expired_token",
 "error_description": "The access token provided has expired"
 }
 */

public final class ErrorDataObject : Decodable {
  public var error : String = "Not an Error"
  public var errorDescription : String = "not Error"
  
  public enum CodingKeys: String, CodingKey {
    case error
    case errorDescription = "error_description"
    case errorMessage = "error_message"
  }
  
  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    var aError : String? = nil
    
    //try fetch error as string
    do {
      aError = try values.decode(String.self, forKey: .error)
    } catch {}
    
    //try fetch error as integer
    do {
      aError = try String(values.decode(Int.self, forKey: .error))
    } catch {}
    
    if let aErr = aError {
      error = aErr
    }
    
    if (values.contains(.errorDescription)) {
      errorDescription = try values.decode(String.self, forKey: .errorDescription)
    } else if (values.contains(.errorMessage)) {
      errorDescription = try values.decode(String.self, forKey: .errorMessage)
    }
  }
  
//  public func isExpiredToken() -> Bool {
//    return error.isAmostEqual(to: "expired_token")
//  }
//  
//  public func isError() -> Bool {
//    return (error == "unknown")
//  }
//  
//  public func isUserAlreadyExists() -> Bool {
//    return error.isAmostEqual(to: "User already exists")
//  }
  
}

//MARK: - Detect error type

//public extension ErrorDataObject {
//
//  public func makeButtonsError() -> ButtonsError {
//    if error.isAmostEqual(to: "expired_token") || errorDescription.isAmostEqual(to: "expired_token") {
//      return ButtonsError.expiredToken
//    } else if error.isAmostEqual(to: "User already exists") || errorDescription.isAmostEqual(to: "User already exists") {
//      return ButtonsError.userAlreadyExists
//    } else if error.isAmostEqual(to: "Error creating a new user") || errorDescription.isAmostEqual(to: "Error creating a new user") {
//      return ButtonsError.createUserError
//    } else if error.isAmostEqual(to: "User does not exist") || errorDescription.isAmostEqual(to: "User does not exist") {
//      return ButtonsError.noUser
//    } else if error.isAmostEqual(to: "Invalid request") || errorDescription.isAmostEqual(to: "Invalid request") {
//      return ButtonsError.invalidRequest
//    } else if error.isAmostEqual(to: "Unknown Error") || error.isAmostEqual(to: "unknown") {
//      return ButtonsError.unknown
//    }
//    return ButtonsError.notError
//  }
//
//}

// MARK: - Description

extension ErrorDataObject : CustomStringConvertible {
  public var description: String {
    return "💣-\(error), \(errorDescription)"
  }
}

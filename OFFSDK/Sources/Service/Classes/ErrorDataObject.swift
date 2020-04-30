//
//  ErrorDataObject.swift
//  ViewingAPI
//
//  Created by Mihaela Mihaljevic Jakic on 30/05/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

import Foundation

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
  
  //MARK: Template -
  
  public func isError() -> Bool {
    return false
  }
  
}

//MARK: - Detect error type

public extension ErrorDataObject {
  
  func makeAPIError() -> APIError {
    if error.isAmostEqual(to: "expired_token") || errorDescription.isAmostEqual(to: "expired_token") {
      return APIError.expiredToken
    } else if error.isAmostEqual(to: "User already exists") || errorDescription.isAmostEqual(to: "User already exists") {
      return APIError.userAlreadyExists
    } else if error.isAmostEqual(to: "Error creating a new user") || errorDescription.isAmostEqual(to: "Error creating a new user") {
      return APIError.createUserError
    } else if error.isAmostEqual(to: "User does not exist") || errorDescription.isAmostEqual(to: "User does not exist") {
      return APIError.noUser
    } else if error.isAmostEqual(to: "Invalid request") || errorDescription.isAmostEqual(to: "Invalid request") {
      return APIError.invalidRequest
    } else if error.isAmostEqual(to: "Unknown Error") || error.isAmostEqual(to: "unknown") {
      return APIError.unknown
    }
    return APIError.notError
  }
  
}

// MARK: - Description

extension ErrorDataObject : CustomStringConvertible {
  public var description: String {
    return "💣-\(error), \(errorDescription)"
  }
}

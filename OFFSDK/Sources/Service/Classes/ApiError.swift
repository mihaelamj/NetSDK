//
//  ApiError.swift
//  BreckWorld
//
//  Created by Mihaela Mihaljevic Jakic on 18/06/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

import Foundation

public enum APIError: String, Error {
  case expiredToken
  case userAlreadyExists
  case invalidRequest
  case createUserError
  case noUser
  case incompleteUser
  case unknown
  case notError
  
  init(error: Error) {
    self = .unknown
  }
  
  var title: String {
    switch self {
    case .expiredToken:
      return "Expired Token"
    case .userAlreadyExists:
      return "User already exists"
    case .invalidRequest:
      return "Invalid request"
    case .createUserError:
      return "Error creating a new user"
    case .noUser:
      return "User does not exist"
    case .incompleteUser:
      return "Incomplete User data"
    case .unknown:
      return "Unknown Error"
    case .notError:
      return "Not an error Error"
    }
  }
  
  var message: String {
    switch self {
    case .expiredToken:
      return "The access token provided has expired."
    case .userAlreadyExists:
      return "User already exists."
    case .invalidRequest:
      return "Invalid request"
    case .createUserError:
      return "Cannot create a new user, an error occurred."
    case .noUser:
      return "User has never been created, need to call register endpoint first."
    case .incompleteUser:
      return "Incomplete User data, need to call register endpoint first."
    case .unknown:
      return "An unknown error has occurred. Please contact support if this persists."
    case .notError:
      return "This is not an error, but a valid Data Object"
    }
  }
}

extension APIError: LocalizedError {
  public var errorDescription: String? {
    return self.message
  }
}

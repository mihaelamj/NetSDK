//
//  NetworkService+Helpers.swift
//  OFFSDK
//
//  Created by Mihaela Mihaljevic Jakic on 27/09/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

import Foundation

extension NetworkService {
  
  // MARK: - Helper
  
  public func jsonHeaders() -> HTTPHeaders {
    return ["Content-Type": "application/json; charset=utf8"]
  }
  
  public func defaultExpectedStatusedFor(method httpMethod: HTTPMethod) -> [HTTPStatusCode] {
    switch httpMethod {
    case .get: return [.ok, .found, .notModified]
    case .post: return [.ok, .created]
    case .put: return [.ok, .created]
    case .patch: return [.ok, .noContent]
    case .delete: return [.accepted, .noContent]
    default:
      return [.ok]
    }
  }

}

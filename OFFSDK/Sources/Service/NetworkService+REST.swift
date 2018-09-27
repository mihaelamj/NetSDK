//
//  NetworkService+REST.swift
//
//  Created by Mihaela Mihaljevic Jakic on 07/05/2018.
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
  
  
// MARK: - GET
  
  func get(path: String, _ result: @escaping DataTaskResultBlock) throws {
    return submitRequest(path: path, data: nil, method: .get, headers: [:], expectedStatuses: [.ok, .found, .notModified], result)
  }
  
// MARK: - POST
  
  func post(path: String, data: Data, _ result: @escaping DataTaskResultBlock) throws {
    return submitRequest(path: path, data: data, method: .post, headers: jsonHeaders(), expectedStatuses: [.ok, .created], result)
  }
  
  func post(path: String, object: Encodable, _ result: @escaping DataTaskResultBlock) throws {
    let data = try object.asData()
    return submitRequest(path: path, data: data, method: .post, headers: jsonHeaders(), expectedStatuses: [.ok, .created], result)
  }
  
// MARK: - PUT
  
  func put(path: String, object: Encodable, _ result: @escaping DataTaskResultBlock) throws {
    let data = try object.asData()
    return submitRequest(path: path, data: data, method: .put, headers: jsonHeaders(), expectedStatuses: [.ok, .created], result)
  }
  
  func put(path: String, data: Data, _ result: @escaping DataTaskResultBlock) throws {
    return submitRequest(path: path, data: data, method: .put, headers: [:], expectedStatuses: [.ok, .created], result)
  }
  
// MARK: - PATCH
  
  func patch(path: String, object: Encodable, _ result: @escaping DataTaskResultBlock) throws {
    let data = try object.asData()
    return submitRequest(path: path, data: data, method: .patch, headers: jsonHeaders(), expectedStatuses: [.ok, .noContent], result)
  }
  
  func patch(path: String, data: Data, _ result: @escaping DataTaskResultBlock) throws {
    return submitRequest(path: path, data: data, method: .patch, headers: [:], expectedStatuses: [.ok, .noContent], result)
  }
  
  // MARK: - DELETE
  
  func delete(path: String, _ result: @escaping DataTaskResultBlock) throws {
    return submitRequest(path: path, data: nil, method: .delete, headers: [:], expectedStatuses: [.accepted, .noContent], result)
  }
  
}

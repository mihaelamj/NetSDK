//
//  Networking+Promise.swift
//
//  Created by Mihaela Mihaljevic Jakic on 07/05/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

import Foundation

extension NetworkService {
  
  // MARK: - GET
  
  func get<T>(path: String) throws -> Promise<T> where T: Decodable {
    let promise = Promise<T>()
    try get(path: path) { (res) in
      do {
        let object = try res.unwrap(to: T.self)
        promise.complete(object)
      } catch {
        promise.fail(error)
      }
    }
    return promise
  }
  
  // MARK: - POST
  
  func post<T>(path: String, data: Data) throws -> Promise<T> where T: Decodable {
    let promise = Promise<T>()
    try post(path: path, data: data) { (res) in
      do {
        let object = try res.unwrap(to: T.self)
        promise.complete(object)
      } catch {
        promise.fail(error)
      }
    }
    return promise
  }
  
  func post<T>(path: String, object: Encodable) throws -> Promise<T> where T: Decodable {
    let promise = Promise<T>()
    try post(path: path, object: object) { (res) in
      do {
        let object = try res.unwrap(to: T.self)
        promise.complete(object)
      } catch {
        promise.fail(error)
      }
    }
    return promise
  }
  
  // MARK: - PUT
  
  func put<T>(path: String, data: Data) throws -> Promise<T> where T: Decodable {
    let promise = Promise<T>()
    try put(path: path, data: data) { (res) in
      do {
        let object = try res.unwrap(to: T.self)
        promise.complete(object)
      } catch {
        promise.fail(error)
      }
    }
    return promise
  }
  
  func put<T>(path: String, object: Encodable) throws -> Promise<T> where T: Decodable {
    let promise = Promise<T>()
    try put(path: path, object: object) { (res) in
      do {
        let object = try res.unwrap(to: T.self)
        promise.complete(object)
      } catch {
        promise.fail(error)
      }
    }
    return promise
  }
  
 // MARK: - PATCH
  
  func patch<T>(path: String, data: Data) throws -> Promise<T> where T: Decodable {
    let promise = Promise<T>()
    try patch(path: path, data: data) { (res) in
      do {
        let object = try res.unwrap(to: T.self)
        promise.complete(object)
      } catch {
        promise.fail(error)
      }
    }
    return promise
  }
  
  func patch<T>(path: String, object: Encodable) throws -> Promise<T> where T: Decodable {
    let promise = Promise<T>()
    try patch(path: path, object: object) { (res) in
      do {
        let object = try res.unwrap(to: T.self)
        promise.complete(object)
      } catch {
        promise.fail(error)
      }
    }
    return promise
  }
  
  // MARK: - DELETE
  
  func delete(path: String) throws -> Promise<Void> {
    let promise = Promise<Void>()
    try delete(path: path) { res in
      switch res {
      case .error(let error):
        promise.fail(error ?? Problem.unknownProblem)
      default:
        promise.complete(Void())
      }
    }
    return promise
  }
  
}

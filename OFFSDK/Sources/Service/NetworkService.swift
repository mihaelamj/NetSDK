//
//  NetworkService.swift
//  VaporCountriesIOS
//
//  Created by Mihaela Mihaljevic Jakic on 03/05/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Helper

private func userAgentData(appTitle : String) -> String {
  var content = appTitle
  if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
    content += "-v\(appVersion) "
  }
  if let bundleID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String {
    content += "\(bundleID) "
  }
  
  #if canImport(UIKit)
  let device = UIDevice.current.model
  let osVersion = UIDevice.current.systemVersion
  #elseif os(OSX)
  let device = "macOS"
  let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
  #else
  let device = "Unknown"
  let osVersion = "Unknown version"
  #endif
  
  content += "\(device), "
  content += "v\(osVersion)"
  return content
}

private func appTitleWithOS(title: String) -> String {
  #if os(iOS)
  let os = "iOS"
  #elseif os(tvOS)
  let os = "tvOS"
  #elseif os(OSX)
  let os = "macOS"
  #else
  let os = "unknown"
  #endif
  return title + " " + os
}

//MARK: Globals -

public enum APIAuthorizationType: String {
  case none
  case basic = "Basic"
  case bearer = "Bearer"
  case queryString
}

/// A dictionary of parameters to apply to a `URLRequest`.
//public typealias Parameters = [String: Any]

/// A dictionary of headers to apply to a `URLRequest`.
public typealias HTTPHeaders = [String: String]

/// A network operation response `URLResponse`.
public typealias DataResponse = (data: Data?, response: URLResponse)

public typealias DataTaskResultBlock = ((_ result: APIResult<DataResponse>) -> ())

public typealias TokenResultBlock = () -> String

// MARK: - Protocol

protocol NetworkServiceProtocol : class {
  // 'class' means only class types can implement it
  func getSessionToken() -> String?
}


//MARK: NetworkService -

open class NetworkService {
  
//  let queue = DispatchQueue(label: "org.mihaelamj.network-service." + UUID().uuidString)
  let session : URLSession
  
/// Base URL
  let baseUrl: URL
  
  //Closure that returns a string token
  public var tokenClosure: TokenResultBlock? = nil
  
  public var authorizationType : APIAuthorizationType = .none
  
  public var tokenStringName : String?
  
  public var userAgent : String?
  
  public var appTitle : String
  
/// URLSession configuration
  let configuration : URLSessionConfiguration
  
/// Dictionary of all active Requests
  var requests = [String: SessionRequest]()
  
/// Array of all Requests that are pending Authentication
  var requestsPendingAuthentication = [SessionRequest]()
  
  weak var delegate : NetworkServiceProtocol?
  
// MARK: - Helper
  
  private func configureSessionForNoCookies(_ sessionConf: URLSessionConfiguration) {
    sessionConf.httpCookieStorage = nil
    sessionConf.httpShouldSetCookies = false
    sessionConf.httpCookieAcceptPolicy = .never
    sessionConf.urlCredentialStorage = nil
  }
  

  
// MARK: - Initialization
  
  init(baseUrl: URL, configuration: URLSessionConfiguration, title: String) {
    self.baseUrl = baseUrl
    self.configuration = configuration
    self.appTitle = appTitleWithOS(title: title)
    self.userAgent = userAgentData(appTitle: self.appTitle)
    self.session = URLSession(configuration: self.configuration)
  }
  

// MARK: - Auth Token
  
  private func getTokenString() -> String? {
    if let aDelegate = self.delegate { //call delegate
      return aDelegate.getSessionToken()
    }
    guard tokenClosure != nil else { return nil }
    let tokenString = tokenClosure!()
    return tokenString
  }
  
  private func getTokenPathPart() -> String? {
    if (authorizationType == .queryString) {
      guard let aTokenString = getTokenString(), let tokenName = tokenStringName else {
        APILogger.instance.logError(domain: .network, message: "NetworkService: Token String and Name should not be nil!")
        return nil
      }
      let fullTokenString = "\(tokenName)=\(aTokenString)" //?access_token=502d0e0000c7aa332926924179c07c2e596df76f
      return fullTokenString
    }
    return nil
    
  }
  
// MARK: - Private Stuff
  
  private func getQueryItems(with path: String, basePath: inout String) -> [URLQueryItem] {
    var queryItems = [URLQueryItem]()
    
    let parts = path.split(separator: "?").map { String($0) }
    
    if parts.count > 0 {
      basePath = parts[0]
    } else {
      basePath = path
    }
    
    if (parts.count > 1) {
      let secondPart = parts[1]
      
      _ = secondPart.split(separator: "&").map { item in
        
        let itemParts = item.split(separator: "=").map {String($0)}
        
        if (itemParts.count > 1) {
          let name = itemParts[0]
          let value = itemParts[1]
          let queryItem = URLQueryItem(name: name, value: value)
          queryItems.append(queryItem)
        }
        
      }
      
    }
    
    return queryItems
  }
  
  private func makeRequest(with path: String) -> URLRequest {
    
    var basePath = path
    
    //get query items
    var queryItems = getQueryItems(with: path, basePath: &basePath)
    
    //check if we need to append token
    if let tokenValue = getTokenString(), let tokenName = tokenStringName {
      let tokenItem = URLQueryItem(name: tokenName, value: tokenValue)
      queryItems.append(tokenItem)
    }
    
    var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)!
    
    debugPrint("\(components)")
    components.path = components.path + basePath
    debugPrint("\(components)")
    
    if queryItems.count > 0 {
      components.queryItems = queryItems
    }
    
    let url = components.url
    
    return URLRequest(url: url!)
  }
  
  private func buildHTTPHeaders( for request: inout URLRequest, headers: HTTPHeaders = [:]) {
    var headers = headers
    
    //check for Auth
    if let aTokenString = getTokenString() {
      switch authorizationType {
      case .basic, .bearer:
        let authValue = authorizationType.rawValue + " " + aTokenString
        headers["Authorization"] = authValue
      case .queryString :
        break
      case .none:
        break
      }
    }
    
    //check for User Agent
    if let aUserAgent = userAgent {
      headers["User-Agent"] = aUserAgent
    }
    
    request.allHTTPHeaderFields = headers
  }
  
  // MARK: - Requests Helpers
  
  private func addRequestToCollection(sessionRequest: SessionRequest) { //save networkRequest in dictionary
    self.requests[sessionRequest.requestIdentifier] = sessionRequest
    APILogger.instance.logDebug(domain: .network, message: "NetworkService: The request with ID \(sessionRequest.requestIdentifier) was added to requests.")
  }
  
  private func removeRequestFromCollections(sessionRequest: SessionRequest) {
    let identifier = sessionRequest.requestIdentifier
    if let value = self.requests.removeValue(forKey: identifier) {
      APILogger.instance.logDebug(domain: .network, message: "NetworkService: The request with ID \(identifier) was removed from requests \(value).")
    }
    if let index = self.requestsPendingAuthentication.firstIndex(of:sessionRequest) {
      self.requestsPendingAuthentication.remove(at: index)
      APILogger.instance.logDebug(domain: .network, message: "NetworkService: The request at index \(index) was removed from Requests Pending Authentication.")
    }
  }
  
  // MARK: - NetworkActivityIndicator
  
  private func requestStarted() {
    NetworkActivityIndicator.shared.push()
  }
  
  private func requestEnded() {
    NetworkActivityIndicator.shared.pop()
  }
  

// MARK: - Base Actions
  
  public func submitRequest(path: String, data: Data? = nil, method: HTTPMethod, headers: HTTPHeaders = [:], expectedStatuses : [HTTPStatusCode], _ result: @escaping DataTaskResultBlock ) {
    
    //build request with path
    var request = makeRequest(with: path)
    
    APILogger.instance.logDebug(domain: .network, message: "NetworkService: Request: Path : \(path)")
    APILogger.instance.logDebug(domain: .network, message: "NetworkService: Request: method : \(method.rawValue)")
    APILogger.instance.logDebug(domain: .network, message: "NetworkService: Request: Full Path: \(request.url!)")
    
    //set body
    if let data = data { request.httpBody = data }
    
    //set method
    request.httpMethod = method.rawValue
    
    //set HTTPHeaders
    buildHTTPHeaders(for: &request, headers: headers)
    
    //make SessionRequest
    let sessionRequest = SessionRequest(request: request, expectedStatuses: expectedStatuses, session: self.session, path:path, resultBlock: result, delegate: self)
    
    //save networkRequest in dictionary
    addRequestToCollection(sessionRequest: sessionRequest)
  }
  
  public func cancelRequest(with identifier: String) {
    if let request = self.requests[identifier] {
      APILogger.instance.logDebug(domain: .network, message: "NetworkService: Request with ID: \(identifier) is about to be cancelled!")
      request.cancel()
      self.requests.removeValue(forKey: identifier)
    }
  }
  
  public func resendRequestsPendingAuthentication() {
    APILogger.instance.logDebug(domain: .network, message: "NetworkService: Resending Requests Pending Authentication!")
    _ = self.requestsPendingAuthentication.map {
      $0.restart()
    }
  }

}

//MAARK: Notification -

extension Notification.Name {
  static let AppNeedsAuthentication = Notification.Name("AppNeedsAuthentication_ButtonAPI")
}

private func sendServiceNeedsAuthenticationNotification(with request: SessionRequest) {
  let nc = NotificationCenter.default
  let userInfo : [String : String]? = nil
  nc.post(name: Notification.Name.AppNeedsAuthentication, object: request, userInfo: userInfo)
}

// MARK: - Request Delegate

extension NetworkService : SessionRequestProtocol {
  
  func sessionRequestDidStart(sessionRequest: SessionRequest) {
    APILogger.instance.logDebug(domain: .app, message: "NetworkService: The request with ID \(sessionRequest.requestIdentifier) did Start!.")
    requestStarted()
  }
  
  func sessionRequestDidComplete(sessionRequest: SessionRequest) {
    removeRequestFromCollections(sessionRequest: sessionRequest)
    APILogger.instance.logDebug(domain: .app, message: "NetworkService: The request with ID \(sessionRequest.requestIdentifier) did End!.")
    requestEnded()
  }
  
  func sessionRequestFailed(sessionRequest: SessionRequest, error: Error?) {
    if let err = error {
      APILogger.instance.logError(domain: .network, message: "NetworkService: sessionRequestFailed: \(err)")
    }
    removeRequestFromCollections(sessionRequest: sessionRequest)
  }
  
  func sessionRequestRequiresAuthentication(sessionRequest: SessionRequest) {
    self.requestsPendingAuthentication.append(sessionRequest)
    APILogger.instance.logDebug(domain: .app, message: "NetworkService: The request with ID \(sessionRequest.requestIdentifier) was added to Requests Pending Authentication.")
    sendServiceNeedsAuthenticationNotification(with: sessionRequest)
  }
}

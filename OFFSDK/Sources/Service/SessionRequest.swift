//
//  NetworkRequest.swift
//  VaporCountriesIOS
//
//  Created by Mihaela Mihaljevic Jakic on 07/05/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

import Foundation

//MARK: Helper -

public enum TaskKind : String {
  case data = "data"
  case upload = "upload"
  case download = "download"
}

func checkResponseStatus(status : NSInteger, expectedStatuses : [HTTPStatusCode]) -> Bool {
  return expectedStatuses.filter({
    $0.rawValue == status
  }).count > 0
}

func statusesString(_ statuses : [HTTPStatusCode]) -> String {
  var all : String = ""
  _ = statuses.map {
    all = all + "\($0.description)"
  }
  return all
}

// MARK: - Protocol

protocol SessionRequestProtocol : class {
  // 'class' means only class types can implement it
  func sessionRequestDidStart(sessionRequest: SessionRequest) 
  func sessionRequestDidComplete(sessionRequest: SessionRequest)
  func sessionRequestRequiresAuthentication(sessionRequest: SessionRequest)
  func sessionRequestFailed(sessionRequest: SessionRequest, error: Error?)
}


// MARK: - Class

public class SessionRequest {
  let request : URLRequest
  let expectedStatuses : [HTTPStatusCode]
  let session : URLSession
  let taskKind : TaskKind = .data
  let requestIdentifier : String
  let path : String
  let resultBlock : DataTaskResultBlock
  weak var delegate : SessionRequestProtocol?
  
  //A trick to use methods in initializer and avoid the error: 'self' used before all stored properties are initialized
  private var _task: URLSessionDataTask!
  var task: URLSessionDataTask {
    return _task
  }
  
// MARK: - Init
  
  init(request: URLRequest, expectedStatuses : [HTTPStatusCode], session : URLSession, path: String, resultBlock : @escaping DataTaskResultBlock, delegate: SessionRequestProtocol? = nil) {
    self.expectedStatuses = expectedStatuses
    self.session = session
    self.request = request
    self.path = path
    self.delegate = delegate
    self.resultBlock = resultBlock
    self.requestIdentifier = path + UUID().uuidString
    self._task = self.makeDataTaskWeak()
    self.task.resume()
    if let delegate = self.delegate { //call delegate
      delegate.sessionRequestDidStart(sessionRequest: self)
    }
  }
  
// MARK: - Base
  
  private func makeDataTaskWeak() -> URLSessionDataTask {
    
    //a hack to make the Swift compiler not deallocate [weak self], really don't know why this shit happens, maybe because of _task and task???
    let mySelf : SessionRequest? = self
    
    let _atask = session.dataTask(with: request) { [weak self] (data, response, error) in
      
      if let response = response as? HTTPURLResponse {
        
        guard let strongSelf = self else {
          APILogger.instance.logError(domain: .network, message: "SessionRequest: Error: self is deallocated!!")
          if (mySelf == nil) {
            APILogger.instance.logError(domain: .network, message: "SessionRequest: mySelf is NIL")
          } else {
            APILogger.instance.logDebug(domain: .network, message: "SessionRequest: mySelf: \(mySelf!)")
          }
          return
        }
        
        let request = strongSelf.request
        
//        Debug.request(request, response: response, data: data)
        
        if (checkResponseStatus(status: response.statusCode, expectedStatuses: (self?.expectedStatuses)!)) {
          APILogger.instance.logDebug(domain: .network, message: "SessionRequest: Success: \(request.httpMethod ?? "no method"),  \(String(describing: request.url!) ), status: \(response.statusCode)")
          
          DispatchQueue.main.async {
            
            var errorObject : ErrorDataObject? = nil
            
            if let data = data {
              //see if the error was returned in the data object
              do {
                errorObject = try JSONDecoder().decode(ErrorDataObject.self, from: data)
              } catch { }
            } else {
              APILogger.instance.logError(domain: .network, message: "SessionRequest: Data part of response should not be nil")
            }
            
            if (errorObject == nil) { //call result block as success
              APILogger.instance.logInfo(domain: .network, message: "SessionRequest: Success")
              strongSelf.resultBlock(MMJResult.success((data: data, response: response)))
              
            } else { //maybe we have an Error object
              
//              let buttonError = errorObject!.makeButtonsError()
              let buttonError = APIError.notError
              if (buttonError == .notError) {
                APILogger.instance.logInfo(domain: .network, message: "SessionRequest: Success")
                strongSelf.resultBlock(MMJResult.success((data: data, response: response)))
              } else {
                //TODO: Check if token has expired
                APILogger.instance.logError(domain: .network, message: "SessionRequest: Received ErrorDataObject instead of data: \(String(describing: errorObject))")
                strongSelf.resultBlock(MMJResult.error(buttonError))
              }
              
            }
            
            if let delegate = strongSelf.delegate { //call delegate
              delegate.sessionRequestDidComplete(sessionRequest: strongSelf)
            }
          }
          
        } else if (response.statusCode == HTTPStatusCode.unauthorized.rawValue) {
          APILogger.instance.logDebug(domain: .network, message: "SessionRequest: Authentication required for: \(request.httpMethod!), \(String(describing: request.url!)), \(statusesString((strongSelf.expectedStatuses)))")
          DispatchQueue.main.async {
            if let delegate = strongSelf.delegate { //call delegate to Authenticate
              delegate.sessionRequestRequiresAuthentication(sessionRequest: strongSelf)
            }
          }
          
        } else {
          APILogger.instance.logError(domain: .network, message: "SessionRequest: Invalid status code \(response.statusCode) for: \(String(describing: request.httpMethod!) ), \(String(describing: request.url!)), \(statusesString((strongSelf.expectedStatuses)))")
          DispatchQueue.main.async {
            
            //call result block as error
            strongSelf.resultBlock(MMJResult.error(Problem.invalidStatusCode))
            
            if let delegate = strongSelf.delegate { //call delegate
              delegate.sessionRequestFailed(sessionRequest: strongSelf, error: error)
            }
          }
          
        }
        
      }
    }
    return _atask
  }

  // MARK: - Public
  
  public func cancel() {
    self.task.cancel()
  }
  
  public func restart() {
    self._task = makeDataTaskWeak()
    self.task.resume()
  }
  
}

extension SessionRequest: Equatable {
  public static func == (lhs: SessionRequest, rhs: SessionRequest) -> Bool {
    return
      lhs.requestIdentifier == rhs.requestIdentifier
  }
}

  

  
  


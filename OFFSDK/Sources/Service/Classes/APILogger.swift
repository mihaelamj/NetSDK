//
//  APILogger.swift
//  OFFSDK
//
//  Created by Mihaela Mihaljevic Jakic on 27/09/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
public typealias Image = UIImage
#endif

#if os(OSX)
import Cocoa
public typealias Image = NSImage
#endif

public enum LoggerDomain : String {
  case app =  "App"
  case view =  "View"
  case layout = "Layout"
  case controller =  "Controller"
  case routing =  "Routing"
  case service =  "Service"
  case network =  "Network"
  case model =  "Model"
  case cache =  "Cache"
  case db =  "DB"
  case io =  "IO"
}

public enum LoggerLevel : Int {
  case error =  0
  case warning =  1
  case important =  2
  case info =  3
  case debug =  4
  case verbose =  5
  case noise =  6
}

public class APILogger  {
  public static let instance = APILogger()
  
  //MARK: Template : to be subclassed -
  
  public func log(level: LoggerLevel, domain: LoggerDomain, message: String, image : Image? = nil) {
    //NSLogger implementation
//    let domain : Logger.Domain = Logger.Domain(rawValue: domain.rawValue)
//    let level : Logger.Level = Logger.Level(rawValue: level.rawValue)
//    Logger.shared.log(domain, level, message ?? "")
//    if let aImage = image {
//      Logger.shared.log(domain, level, aImage)
//    }
  }
  
  public func logInfo(domain: LoggerDomain, message: String, image : Image? = nil) {
    log(level: .info, domain: domain, message: message, image: image)
  }
  
  public func logError(domain: LoggerDomain, message: String, image : Image? = nil) {
    log(level: .error, domain: domain, message: message, image: image)
  }
  
  public func logImportant(domain: LoggerDomain, message: String, image : Image? = nil) {
    log(level: .important, domain: domain, message: message, image: image)
  }
  
  public func logDebug(domain: LoggerDomain, message: String, image : Image? = nil) {
    log(level: .debug, domain: domain, message: message, image: image)
  }
  
  public func logWarning(domain: LoggerDomain, message: String, image : Image? = nil) {
    log(level: .warning, domain: domain, message: message, image: image)
  }

}

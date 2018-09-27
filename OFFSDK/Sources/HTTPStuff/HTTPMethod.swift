//
//  HTTPMethod.swift
//  OFFSDK
//
//  Created by Mihaela Mihaljevic Jakic on 27/09/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

import Foundation

/// See https://tools.ietf.org/html/rfc7231#section-4.3
public enum HTTPMethod: String {
  case options = "OPTIONS"
  case get     = "GET"
  case head    = "HEAD"
  case post    = "POST"
  case put     = "PUT"
  case patch   = "PATCH"
  case delete  = "DELETE"
  case trace   = "TRACE"
  case connect = "CONNECT"
}

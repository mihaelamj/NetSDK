//
//  NetworkAPI.swift
//  OFFSDK
//
//  Created by Mihaela Mihaljevic Jakic on 27/09/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

import Foundation

public class NetworkAPI {

  //INFO: Change with yout NetworkService descendant
//  static let shared = NetworkAPI(service: NetworkService())
  public var netService: NetworkService
  
  //MARK: Init -
  
  public init (service: NetworkService) {
    netService = service
  }
  
  public static let `default`: NetworkAPI = {
    let configuration = URLSessionConfiguration.default
    let testServer = "http://world.openfoodfacts.org/"
    let testSecureServer = "https://ssl-api.openfoodfacts.org/"
    let url = URL(string: testServer)!
    let title = "Test App"
    let service = NetworkService(baseUrl: url, configuration: configuration, title: title)
    return NetworkAPI(service: service)
  }()
  
}

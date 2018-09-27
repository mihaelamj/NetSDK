//
//  NetworkActivityIndicator.swift
//  ViewingAPI
//
//  Created by Mihaela Mihaljevic Jakic on 29/05/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

class NetworkActivityIndicator {
  var count = 0
  let queue = DispatchQueue(label: "com.buttons.networkactivity", qos: .background)
  static let shared = NetworkActivityIndicator()
  
  private init() { }
  
  func push() {
    queue.async {
      self.count += 1
      self.updateActivityIndicatorStatus()
    }
  }
  
  func pop() {
    queue.async {
      self.count -= 1
      self.updateActivityIndicatorStatus()
    }
  }
  
  private func updateActivityIndicatorStatus() {
    #if os(iOS)
    DispatchQueue.main.async {
      UIApplication.shared.isNetworkActivityIndicatorVisible = self.count > 0
    }
    #endif
  }
}


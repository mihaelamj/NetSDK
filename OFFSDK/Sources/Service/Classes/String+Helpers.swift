//
//  String+Helpers.swift
//  OFFSDK
//
//  Created by Mihaela Mihaljevic Jakic on 27/09/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

import Foundation

public extension String {
  
  func removingWhitespaces() -> String {
    return components(separatedBy: .whitespaces).joined()
  }
  
  func isCaseInsensitiveEqualTo(to string: String) -> Bool {
    return self.caseInsensitiveCompare(string) == .orderedSame
  }
  
  func isAmostEqual(to string: String) -> Bool {
    let strippedSelf = self.removingWhitespaces()
    let strippedString = string.removingWhitespaces()
    return strippedSelf.isCaseInsensitiveEqualTo(to: strippedString)
  }

}


//  Created by Mihaela Mihaljevic Jakic on 24/05/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

import Foundation

// MARK: String extension -

extension String : CodingKey {
  public var stringValue: String {
    return self
  }
  public init?(stringValue: String) {
    self.init(stringLiteral: stringValue)
  }
  public var intValue: Int? {
    return nil
  }
  public init?(intValue: Int) {
    return nil
  }
}

// MARK: JSONDecoder -

public func decodeModel<T>(type: T.Type, data: Data) throws -> T? where T: Decodable {
  let model = try JSONDecoder().decode(type, from: data)
  return model
}

public func decodeArray<T>(type: [T].Type, data: Data, key : String? = nil) throws -> [T]? where T: Decodable {
  if let aKey = key {
    let object = try JSONDecoder().decode([String: Array<T>].self, from: data)
    print(object)
    let items = object[aKey];
    return items
  }
  let array = try JSONDecoder().decode(type, from: data)
  return array
}

public func decodeDictionary<T>(type: [String : T].Type, data: Data, key : String? = nil) throws -> [T]? where T: Decodable {
  if let aKey = key {
    let object = try JSONDecoder().decode([String:[String:T]].self, from: data)
    print(object)
    let dict = object[aKey]
    var allItems : [T] = [T]()
    for (_, item) in dict! {
      allItems.append(item)
    }
    return allItems
  }
  
  let dict = try JSONDecoder().decode(type, from: data)
  var alItems : [T] = [T]()
  for (_, item) in dict {
    alItems.append(item)
  }
  return alItems
}

public func decodeCollection<T>(type: T.Type, data: Data, key : String? = nil) throws -> [T]? where T: Decodable {
  var alItems : [T]? = nil
  
  //first try with array
  do {
    try alItems = decodeArray(type: [T].self, data: data, key: key)
    print(alItems ?? "no items")
  } catch {
    debugPrint(error)
  }
  
  //if we got no items
  guard alItems != nil else {
    //try with dictionary
    do {
      try alItems = decodeDictionary(type: [String : T].self, data: data, key: key)
      print(alItems ?? "no items")
    } catch {
      debugPrint(error)
    }
    
    return alItems
  }
  
  return alItems
}

//MARK: Decoder -

public func decodeModel<T>(from decoder: Decoder) throws -> T? where T: Decodable {
  let object = try T(from: decoder)
  return object
}

public func decodeArray<T>(type: [T].Type, from decoder: Decoder, key : String? = nil) throws -> [T]? where T: Decodable {
  if let aKey = key {
    let container = try decoder.container(keyedBy: String.self)
//    debugPrint(container.allKeys)
    let array : [T] = try container.decode(type, forKey:aKey)
    return array
  }
  
//  let array : [T] = try type.init(from: decoder)
  let array : [T] = try [T].init(from: decoder)
  return array
}

public func decodeDictionary<T>(type: [String : T].Type, from decoder: Decoder, key : String? = nil) throws -> [T]? where T: Decodable {
  
  if let aKey = key {
    let container = try decoder.container(keyedBy: String.self)
    debugPrint(container.allKeys)
    let dict = try container.decode(type, forKey:aKey)
    var allItems : [T] = [T]()
    for (_, item) in dict {
      allItems.append(item)
    }
    return allItems
  }
  
//  let dict = try type.init(from: decoder)
  let dict : [String : T] = try [String : T].init(from: decoder)
  var alItems : [T] = [T]()
  for (_, item) in dict {
    alItems.append(item)
  }
  return alItems
}

public func decodeCollection<T>(type: T.Type, from decoder: Decoder, key : String? = nil) throws -> [T]? where T: Decodable {
  var alItems : [T]? = nil
  
  //first try with array
  do {
    try alItems = decodeArray(type: [T].self, from: decoder, key: key)
    print(alItems ?? "no items")
  } catch {
    debugPrint(error)
  }
  
  //if we got no items
  guard alItems != nil else {
    //try with dictionary
    do {
      try alItems = decodeDictionary(type: [String : T].self, from: decoder, key: key)
      print(alItems ?? "no items")
    } catch {
      debugPrint(error)
    }
    
    return alItems
  }
  
  return alItems
}

//INFO: example
//let wallets = try decodeCollection(type: Wallet.self, from: decoder, key: "wallets")
//let myObject : Wallet? = try decodeModel(type: Wallet.self, data: jsonData)






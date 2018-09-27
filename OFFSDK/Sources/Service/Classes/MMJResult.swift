//
//  Result.swift
//  ViewingAPI
//
//  Created by Mihaela Mihaljevic Jakic on 29/05/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic. All rights reserved.
//

import Foundation

public enum MMJResult<Expectation> {
    case error(Error?)
    case success(Expectation)
}

extension MMJResult where Expectation == DataResponse {
    
    public func unwrap() throws -> Expectation {
        switch self {
        case .success(let expectation):
            return expectation
        case .error(let error):
            guard let error = error else {
                throw Problem.unknownProblem
            }
            throw error
        }
    }
    
    public func unwrap<T>(to: T.Type) throws -> T where T: Decodable {
        let object = try unwrap().data!.asObject(to: to)
        return object
    }
    
}

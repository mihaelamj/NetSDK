//
//  Promise.swift
//
//  Created by Ondrej Rafaj on 01/04/2018.
//  Copyright © 2018 Mihaela Mihaljevic Jakic and Ondrej Rafaj. All rights reserved.
//

import Foundation

public class Promise<Expectation> {
    
    public typealias Map<T> = ((Expectation) throws -> T)
    public typealias Success = ((Expectation) throws -> Void)
    public typealias Failure = ((Error) -> Void)
    
    var mapClosure: Map<Any>?
    var mapPromise: Promise<Any>?
    
    var successClosure: Success?
    var errorClosure: Failure?
    
    var fulfilledExpectation: Expectation?
    var fulfilledError: Error?
    
    init() { }
    
    @discardableResult public func then(_ success: @escaping Success) throws -> Self {
        successClosure = success
        if let fulfilledExpectation = fulfilledExpectation {
            try success(fulfilledExpectation)
        }
        return self
    }
    
    @discardableResult public func error(_ error: @escaping Failure) throws -> Promise<Expectation> {
        errorClosure = error
        if let fulfilledError = fulfilledError {
            error(fulfilledError)
        }
        return self
    }
    
    @discardableResult public func map<T>(_ map: @escaping Map<T>) throws -> Promise<T> {
        mapClosure = map
        let promise = Promise<T>()
        
        if let fulfilledExpectation = fulfilledExpectation {
            do {
                let result = try map(fulfilledExpectation)
                promise.complete(result)
            } catch {
                promise.fail(error)
            }
        }
        mapPromise = promise as? Promise<Any>
        return promise
    }
    
    // MARK: Internal interface
    
    func complete(_ expectation: Expectation) {
        fulfilledExpectation = expectation
        do {
            try successClosure?(expectation)
        } catch {
            fail(error)
        }
        
        if let mapPromise = mapPromise, let mapClosure = mapClosure {
            do {
                let result = try mapClosure(expectation)
                mapPromise.complete(result)
            } catch {
                mapPromise.fail(error)
            }
        }
    }
    
    func fail(_ error: Error) {
        fulfilledError = error
        
        errorClosure?(error)
    }
    
}

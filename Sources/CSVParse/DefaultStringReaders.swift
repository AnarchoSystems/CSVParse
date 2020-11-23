//
//  DefaultStringReaders.swift
//  
//
//  Created by Markus Pfeifer on 20.11.20.
//

import Foundation

public struct InvalidNumber<T> : Error {
    let number : T
    let formatter : NumberFormatter
}

public struct IndexOutOfBounds<C : Collection> : Error {
    let collection : C
    let index : C.Index
}

public struct ParseError : Error {
    public let offensiveData : Data
    public init(offensiveData: Data) {
        self.offensiveData = offensiveData
    }
}

public struct NestedStructuresDisallowed : Error{}

@inlinable
public func parseString(from data: Data) throws -> String {
    guard let string = String(data: data, encoding: .utf8) else {
        throw ParseError(offensiveData: data)
    }
    return string
}

@inlinable
public func parseString(from file: URL) throws -> String {
    try String(contentsOf: file, encoding: .utf8)
}

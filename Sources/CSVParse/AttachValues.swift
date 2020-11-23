//
//  AttachValues.swift
//  
//
//  Created by Markus Pfeifer on 21.11.20.
//

import Foundation


public extension CSV {
    
    func detachedFormula<U>(_ transform: (S) -> U) -> CSV<AttachValue<S,U>> {
        CSV<AttachValue<S,U>>(stored: stored.map{AttachValue(given: $0, new: transform($0))})
    }
    
    func concat<U>(fill value: U) -> CSV<AttachValue<S,U>> {
        CSV<AttachValue<S,U>>(stored: stored.map{AttachValue(given: $0,
                                                              new: value)})
    }
    
}


public struct AttachValue<T, U> {
    
    public var given : T
    public var new : U
    
}


extension AttachValue : Decodable where T : Decodable, U : Decodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.given = try container.decode(T.self)
        self.new = try container.decode(U.self)
    }
    
}


extension AttachValue : Encodable where T : Encodable, U : Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(given)
        try container.encode(new)
    }
    
}

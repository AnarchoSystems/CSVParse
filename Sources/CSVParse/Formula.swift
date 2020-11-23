//
//  Formula.swift
//  
//
//  Created by Markus Pfeifer on 20.11.20.
//

import Foundation

public extension CSV {
    
    func formula<U>(key: String,
                    _ transform: @escaping (S) -> U) -> CSV<Formula<S,U>> {
        CSV<Formula<S,U>>(stored: stored.map{Formula(key: key,
                                                     formula: transform,
                                                      underlying: $0)})
    }
    
}

public struct Formula<T, U> {
    
    public var key : String
    public var formula : (T) -> U
    public var underlying : T
    
}


extension Formula : Encodable where T : Encodable, U : Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(underlying)
        var keyedContainer = encoder.container(keyedBy: FormulaKey.self)
        try keyedContainer.encode(formula(underlying), forKey: .init(string: key))
    }
    
}


fileprivate struct FormulaKey : CodingKey {
    
    var stringValue: String
    
    init(string: String){
        self.stringValue = string
    }
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?{
        Int(stringValue)
    }
    
    init?(intValue: Int) {
        stringValue = intValue.description
    }
    
    
    
    
}
